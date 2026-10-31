"""Ollama-first overseer driving owned OpenCode workers. No interactive session is hijacked."""
import argparse
import contextlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import time
import uuid

import agent

HERE = Path(__file__).resolve().parent


def validate_queue(value):
    tasks = value.get('tasks')
    if not isinstance(tasks, list) or not 1 <= len(tasks) <= 12:
        raise ValueError('Overseer must return 1 to 12 tasks')
    ids = set()
    for task in tasks:
        if not isinstance(task, dict) or not re.fullmatch(r'[a-z0-9][a-z0-9-]{0,63}', str(task.get('id', ''))):
            raise ValueError('Invalid task identifier')
        if task['id'] in ids or not isinstance(task.get('title'), str) or not task['title'].strip():
            raise ValueError('Duplicate or empty task')
        if task.get('kind') not in {'code', 'research', 'foundation'} or not isinstance(task.get('acceptance'), str):
            raise ValueError('Task kind/acceptance missing')
        deps = task.get('depends', [])
        if not isinstance(deps, list) or any(d not in ids for d in deps):
            raise ValueError('Dependencies must refer to earlier tasks')
        ids.add(task['id'])
        task['depends'] = deps
    return tasks


class Overseer(agent.Workforce):
    def live_command(self, args, log, timeout=1800, env=None):
        """Own the exact worker and its descendants; keep visible progress while waiting."""
        self.check_stop()
        with Path(log).open('wb') as output:
            process = subprocess.Popen([str(a) for a in args], cwd=self.project, stdout=output,
                stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL, env=env,
                creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0)
            record = None
            started = time.monotonic()
            try:
                try:
                    record = agent.record_process(process.pid)
                except agent.psutil.NoSuchProcess:
                    process.wait(timeout=1)
                if record:
                    self.children.append(record)
                    self.write_owner()
                last = 0
                while process.poll() is None:
                    self.check_stop()
                    if time.monotonic() - started > timeout:
                        raise TimeoutError(f'Worker exceeded {timeout}s; see {log}')
                    if time.monotonic() - last > 1:
                        self.save(worker_seconds=round(time.monotonic()-started), live_log=str(log))
                        last = time.monotonic()
                    time.sleep(.15)
                if process.returncode:
                    raise RuntimeError(f'Worker exited {process.returncode}: ' + Path(log).read_text(errors='replace')[-6000:])
            except BaseException:
                if record:
                    agent.terminate_owned(record)
                elif process.poll() is None:
                    process.kill()
                with contextlib.suppress(subprocess.TimeoutExpired):
                    process.wait(timeout=5)
                raise
            finally:
                if record in self.children:
                    self.children.remove(record)
                self.write_owner()
        return Path(log).read_text(encoding='utf-8', errors='replace')

    def native(self, endpoint, body, timeout=900):
        # Use the existing cancellable model-worker process for every slow HTTP call.
        source, result = self.state_dir/'bootstrap-input.json', self.state_dir/'bootstrap-output.json'
        result.unlink(missing_ok=True)
        agent.atomic(source, {'url': self.config['ollama']+endpoint, 'body': body, 'timeout': timeout})
        self.live_command([sys.executable, HERE/'agent.py', 'model-worker', '--input', source, '--output', result],
                          self.state_dir/'bootstrap.log', timeout+15)
        value = agent.read_json(result)
        if value.get('error'):
            raise RuntimeError('Ollama: '+str(value['error']))
        return value

    def bootstrap(self):
        self.save(phase='Starting Ollama', model_activity='Checking local server', live_log='')
        url = self.config['ollama']
        if url not in {'http://127.0.0.1:11434', 'http://localhost:11434'}:
            raise ValueError('Overseer requires local Ollama at port 11434')
        try:
            agent.request_json(url+'/api/tags', timeout=2)
        except Exception:
            executable = shutil.which('ollama')
            candidate = Path(os.environ.get('LOCALAPPDATA', ''))/'Programs/Ollama/ollama.exe'
            if not executable and candidate.is_file():
                executable = str(candidate)
            if not executable:
                raise RuntimeError('Ollama executable was not found. Install/open Ollama first.')
            self.ollama_output = (self.state_dir/'ollama-server.log').open('ab')
            self.ollama_process = subprocess.Popen([executable, 'serve'], stdout=self.ollama_output,
                stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL,
                creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0)
            self.ollama_record = agent.record_process(self.ollama_process.pid)
            self.children.append(self.ollama_record)
            self.write_owner()
            deadline = time.monotonic()+30
            while True:
                self.check_stop()
                try:
                    agent.request_json(url+'/api/tags', timeout=1)
                    break
                except Exception:
                    if time.monotonic() > deadline:
                        raise RuntimeError('Ollama did not become ready; see .workforce/ollama-server.log')
                    time.sleep(.2)
        self.inventory()
        self.config['num_ctx'] = max(32768, int(self.config.get('num_ctx') or 32768))
        self.config['inference_timeout'] = max(900, self.config['inference_timeout'])
        base = self.config['model']
        # OpenAI-compatible calls cannot set num_ctx. Use a dedicated model alias
        # with that parameter; the base model and shared server settings stay intact.
        alias = 'containment-workforce-'+agent.digest((base+str(self.config['num_ctx'])).encode())[:12]+':latest'
        self.save(phase='Loading local model at 32K', model_activity='Waiting for READY', requested_context=self.config['num_ctx'])
        self.native('/api/create', {'model': alias, 'from': base, 'parameters': {'num_ctx': self.config['num_ctx']}, 'stream': False})
        ready = self.native('/api/generate', {'model': alias, 'prompt': 'Reply with READY only.',
            'stream': False, 'keep_alive': '10m', 'options': {'num_ctx': self.config['num_ctx'], 'num_predict': 16}})
        if not re.fullmatch(r'\s*READY[.!]?\s*', ready.get('response', ''), re.IGNORECASE):
            raise RuntimeError('Model did not answer READY: '+str(ready.get('response', ''))[:400])
        self.worker_model = alias
        self.config['model'] = alias
        self.save(phase='Ollama ready; planning queue', model_activity='READY confirmed', ollama_ready=True, worker_model=alias)

    def plan_queue(self):
        previous = agent.read_json(self.state_dir/'overseer-queue.json', {})
        if previous.get('tasks'):
            self.tasks = validate_queue(previous)
            return
        plan = self.model('Overseer planner', {'project': str(self.project), 'files': self.context(),
            'starting_tasks': self.tasks, 'feedback': self.state.get('recent_feedback', []),
            'mission': 'Develop the existing Unity co-op horror game. Prefer existing open-source GitHub solutions; inspect license and Unity/package compatibility. Start with broken input, then owner networking, interactions and a playable milestone. Schedule independent research after failures. Do not stop the whole queue on one task failure. No gameplay acceptance may be invented.',
            'required_response': {'tasks': [{'id': 'foundation-input', 'title': 'Repair and test movement', 'kind': 'foundation', 'depends': [], 'acceptance': 'Specific measured criteria'}]},
            'rules': 'Return 3 to 8 ordered tasks. Dependencies refer only to earlier task IDs. Include at least one independent research task. Tasks are work instructions, never commands. Keep existing task IDs for existing work.'})
        self.tasks = validate_queue(plan)
        agent.atomic(self.state_dir/'overseer-queue.json', {'tasks': self.tasks})

    def require_opencode(self):
        # The Windows shim resolves npm .cmd installs without shell string interpolation.
        output = self.command(['powershell.exe', '-NoProfile', '-Command',
            '$c=Get-Command opencode -CommandType Application -All -ErrorAction Stop | Select-Object -First 1; & $c.Source run --help; exit $LASTEXITCODE'], timeout=30)[0]
        for flag in ['--format', '--model', '--auto']:
            if flag not in output:
                raise RuntimeError('Installed OpenCode does not support '+flag+'; this adapter needs the CLI used by START_CONTAINMENT_AGENT.cmd')

    def worker_request(self, task, attempt):
        result = self.state_dir/'opencode-result.json'
        result.unlink(missing_ok=True)
        config = {'model': 'ollama/'+self.worker_model, 'small_model': 'ollama/'+self.worker_model,
            'enabled_providers': ['ollama'], 'autoupdate': False,
            'provider': {'ollama': {'npm': '@ai-sdk/openai-compatible', 'name': 'Local Ollama',
                'options': {'baseURL': self.config['ollama']+'/v1'},
                'models': {self.worker_model: {'name': self.worker_model, 'limit': {'context': self.config['num_ctx'], 'output': 4096}}}}},
            'permission': {'*': 'allow', 'external_directory': 'deny',
                'edit': {'*': 'allow', 'tools/workforce/*': 'deny', '.git/*': 'deny'}, 'task': 'deny'}}
        prompt = ('Execute this task in the CURRENT project using actual tools. Read AGENTS.md/AGENT_MISSION.md if present. '
            'Use existing GitHub/open-source solutions first; record exact source revision, license, dependencies and Unity compatibility before importing. '
            'You may create/repair Unity runtime and Editor scripts, project settings, scene/prefab assets, tests, package configuration and docs as needed. '
            'Do not touch other project folders, tools/workforce, .git, supervisor/config/stop controls, or launch background/daemon processes. '
            'Do not commit, push, change branches, or claim human verification. The supervisor checkpoints your work. '
            'If using Unity MCP, confirm it targets this EXACT project; otherwise use the configured Editor in batch mode. Close any Unity instance you started before returning. '
            'Inspect errors and implement/test the change; do not just provide advice. Preserve useful partial work on failure. '
            'Write '+str(result)+' as JSON with status (implemented or blocked), summary, tests (actual results only), and failure (empty on success). '
            'Project: '+str(self.project)+' Editor: '+self.version()+' Editor executable: '+str(self.editor())+
            '\nTask: '+json.dumps(task)+'\nAttempt: '+str(attempt)+
            '\nPrevious failure: '+str(self.state['tasks'].get(task['id'], {}).get('error', ''))[-7000:])
        request = self.state_dir/'opencode-request.json'
        agent.atomic(request, {'config': config, 'model': 'ollama/'+self.worker_model, 'prompt': prompt})
        return request, result

    def checkpoint(self, message):
        paths = set(self.git('diff', '--name-only', '-z', 'HEAD').split('\0'))
        paths.update(self.git('ls-files', '--others', '--exclude-standard', '-z').split('\0'))
        paths.discard('')
        allowed = {'DEVELOPMENT_PROGRESS.md', 'AGENT_HANDOFF.md', 'TEST_RESULTS.md', 'TASK_BOARD.json', 'THIRD_PARTY_NOTICES.md'}
        outside = [p for p in paths if not p.startswith(('Assets/', 'Packages/', 'ProjectSettings/', 'docs/')) and p not in allowed]
        if outside:
            raise RuntimeError('Worker changed files outside development scope; preserved for review: '+', '.join(sorted(outside)))
        staged = set(self.git('diff', '--cached', '--name-only', '-z').split('\0'))-{''}
        if staged-paths:
            raise RuntimeError('Unexpected staged files preserved; review index')
        if paths:
            self.git('add', '-A', '--', *sorted(paths), interruptible=False)
            self.git('diff', '--cached', '--check', interruptible=False)
            self.git('commit', '-m', message, interruptible=False)
        revision = self.git('rev-parse', 'HEAD', interruptible=False)
        self.save(last_commit=revision)
        return revision

    def work_queue(self):
        for task in self.tasks:
            self.check_stop()
            state = self.state['tasks'].setdefault(task['id'], {})
            if state.get('status') in {'human_verified', 'awaiting_human', 'researched', 'failed'}:
                continue
            missing = [d for d in task['depends'] if self.state['tasks'].get(d, {}).get('status') not in {'human_verified', 'researched'}]
            if missing:
                state.update(status='dependency_blocked', error='Waiting for verified dependencies: '+', '.join(missing))
                self.save()
                continue
            for attempt in range(1, int(self.config['max_attempts'])+1):
                self.check_stop()
                state.update(attempts=attempt, status='working')
                self.save(current_task=task['title'], phase=f'OpenCode attempt {attempt}/{self.config["max_attempts"]}', model_activity='OpenCode worker active', error='')
                log = self.state_dir/f'opencode-{task["id"]}-{attempt}.jsonl'
                try:
                    request, result_file = self.worker_request(task, attempt)
                    text = self.live_command(['powershell.exe', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', HERE/'Run-OpenCode.ps1', '-RequestFile', request], log, int(self.config.get('task_timeout', 1800)))
                    for line in text.splitlines():
                        with contextlib.suppress(ValueError):
                            event = json.loads(line)
                            if event.get('type') == 'error':
                                raise RuntimeError('OpenCode error: '+json.dumps(event)[-3000:])
                    report = agent.read_json(result_file, {})
                    if report.get('status') != 'implemented' or not report.get('summary'):
                        raise RuntimeError('Worker did not produce an implemented result: '+json.dumps(report)[-4000:])
                    state['worker_report'] = report
                    if task['kind'] != 'research':
                        state['automated'] = [self.verify('Compile'), self.verify('MovementSmoke'), self.verify('Build')]
                    state.update(status='researched' if task['kind']=='research' else 'awaiting_human', error='')
                    state['code_commit'] = self.checkpoint('feat: '+task['title'])
                    break
                except agent.Stopped:
                    state.update(status='interrupted', error='Stopped; partial edits preserved, no test acceptance claimed')
                    raise
                except Exception as exc:
                    state.update(status='failed' if attempt==int(self.config['max_attempts']) else 'retrying', error=str(exc))
                    self.log('opencode_task_failed', task=task['id'], attempt=attempt, error=str(exc), log=str(log))
                    # Checkpoint failed work explicitly as unverified before next task.
                    self.checkpoint('wip: unverified attempt '+str(attempt)+' '+task['id'])
                finally:
                    self.save(model_activity='Idle')
                    self.checkpoint_reports()

    def checkpoint_reports(self):
        self.reports()
        self.checkpoint('chore: overseer task outcomes and failures')

    def review_queue(self):
        self.save(phase='Overseer reviewing task outcomes')
        review = self.model('Overseer outcome reviewer', {'tasks': self.state['tasks'],
            'rules': 'Summarize concrete failures, actual evidence, remaining manual tests and the next useful work. Never promote a verification status. Return JSON.',
            'required_response': {'summary':'', 'failures':[], 'needs_human_test':[], 'next_steps':[]}})
        path = self.project/'docs/OVERSEER_REPORT.json'
        agent.atomic(path, {'time':agent.now(), 'review':review, 'outcomes':self.state['tasks']})
        self.checkpoint('docs: overseer review of failed and completed work')

    def run(self, run_id):
        self.run_id = run_id
        with agent.InstanceLock(self.state_dir/'instance.lock'):
            self.running = True
            self.write_owner()
            self.save(status='Running', started=agent.now(), error='', ollama_ready=False)
            signal.signal(signal.SIGTERM, lambda *_: self.stop_path.touch())
            signal.signal(signal.SIGINT, lambda *_: self.stop_path.touch())
            try:
                self.bootstrap()  # Actual inference happens before Unity validation/testing.
                self.validate_project()
                self.recover()
                self.establish_branch()
                self.require_opencode()
                self.ingest_feedback()
                # A failure is final for this run, and can be retried on the next Start.
                for state in self.state['tasks'].values():
                    if state.get('status') == 'failed':
                        state['status'] = 'pending'
                self.checkpoint('test: import human playtest feedback')
                self.plan_queue()
                self.work_queue()
                self.review_queue()
                self.save(status='Stopped', phase='Queue finished; see task outcomes and human test requests')
            except agent.Stopped:
                self.save(status='Stopped', phase='Stopped; partial work saved for resume')
            except Exception as exc:
                self.save(status='Blocked', phase='Startup or checkpoint needs attention', error=str(exc))
                self.log('overseer_blocked', error=str(exc))
            finally:
                self.running = False
                for child in list(self.children):
                    agent.terminate_owned(child)
                if hasattr(self, 'ollama_output'):
                    self.ollama_output.close()
                try:
                    if self.branch_established:
                        self.checkpoint_reports()
                        # Reuse explicit report-only publication; no blanket staging/pushing.
                        self.publish(self.reports(), 'chore: publish overseer wrapup')
                except Exception as exc:
                    self.save(error=str(exc), phase='Work preserved; checkpoint/publication needs attention')
                self.owner_path.unlink(missing_ok=True)

    def start(self):
        if self.active():
            return 'Overseer already running; see live task output below'
        if any(agent.exact_process(c) for c in agent.read_json(self.owner_path, {}).get('children', [])):
            raise RuntimeError('An owned worker survived; use Emergency Stop before Start')
        self.stop_path.unlink(missing_ok=True)
        with (self.state_dir/'supervisor.log').open('ab') as output:
            subprocess.Popen([sys.executable, str(HERE/'overseer.py'), 'run', '--config', str(self.config_path), '--run-id', uuid.uuid4().hex],
                cwd=self.project, stdin=subprocess.DEVNULL, stdout=output, stderr=output,
                **({'creationflags': subprocess.CREATE_NEW_PROCESS_GROUP | subprocess.DETACHED_PROCESS} if os.name=='nt' else {'start_new_session': True}))
        return 'Starting Ollama, then overseer, then OpenCode workers'


def dashboard(app):
    import tkinter as tk
    from tkinter import ttk, messagebox
    window = tk.Tk()
    window.title('Containment Shift - Ollama + OpenCode Overseer')
    window.geometry('1100x760')
    controls = ttk.Frame(window); controls.pack(fill='x')
    def action(call):
        try: messagebox.showinfo('Overseer', str(call()))
        except Exception as exc: messagebox.showerror('Action needed', str(exc))
    for label, call in [('Start', app.start), ('Stop and Save', app.stop), ('Emergency Stop', lambda: app.stop(True)), ('Play Game', app.play), ('Feedback', lambda: agent.dashboard(app, True))]:
        ttk.Button(controls, text=label, command=lambda call=call: action(call)).pack(side='left', padx=4, pady=6)
    view = tk.Text(window, wrap='word'); view.pack(fill='both', expand=True)
    def refresh():
        try:
            s = agent.read_json(app.state_path, {})
            live = bool(app.active())
            text = f'Project: {app.project}\nSupervisor alive: {live} | Status: {s.get("status", "Stopped")}\nPhase: {s.get("phase", "")}\nTask: {s.get("current_task", "")}\nOllama READY: {s.get("ollama_ready", False)} | Model: {s.get("worker_model", "")} | Context: {s.get("requested_context", "not requested")}\nWorker elapsed: {s.get("worker_seconds", 0)}s | Updated: {s.get("updated", "")}\nBlocker: {s.get("error", "")}\n\n'
            for key, value in s.get('tasks', {}).items():
                text += key+': '+str(value.get('status', 'pending'))+' | '+str(value.get('error', ''))[-700:]+'\n'
            log = Path(s.get('live_log') or app.state_dir/'supervisor.log')
            text += '\nLIVE OUTPUT: '+str(log)+'\n'
            if log.is_file():
                with log.open('rb') as stream:
                    stream.seek(max(0, log.stat().st_size-18000))
                    text += stream.read().decode('utf-8', 'replace')
            view.configure(state='normal'); view.delete('1.0', 'end'); view.insert('1.0', text); view.configure(state='disabled')
        except (OSError, ValueError, agent.psutil.Error): pass
        window.after(1000, refresh)
    refresh(); window.mainloop()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('action'); parser.add_argument('--config', required=True); parser.add_argument('--run-id')
    args = parser.parse_args()
    app = Overseer(args.config)
    if args.action == 'run': app.run(args.run_id)
    elif args.action == 'start': print(app.start()); dashboard(app)
    elif args.action == 'status': dashboard(app)
    elif args.action == 'feedback': agent.dashboard(app, True)
    elif args.action == 'stop': print(app.stop())
    elif args.action == 'emergency': print(app.stop(True))
    elif args.action == 'play': print(app.play())
    elif args.action == 'doctor': print(app.inventory())
    elif args.action == 'cleanup': print(app.cleanup())


if __name__ == '__main__':
    try: main()
    except Exception as exc:
        print('ACTION NEEDED:', exc, file=sys.stderr); sys.exit(1)
