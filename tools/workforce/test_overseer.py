"""Scheduler/integration fixtures do not claim real OpenCode, Ollama or Unity operation."""
import json
import unittest
from unittest.mock import patch

import agent
import overseer
import test_agent

PROC_MISMATCH = test_agent.PROC_MISMATCH


class OverseerTests(unittest.TestCase):
    git = test_agent.Fixture.git
    tearDown = test_agent.Fixture.tearDown
    def setUp(self):
        test_agent.Fixture.setUp(self)
        self.app.__class__ = overseer.Overseer
        self.app.worker_model = 'fixture:latest'
        self.app.config.update(max_attempts=2, num_ctx=32768)

    def test_queue_validation(self):
        good = {'tasks': [{'id': 'one', 'title': 'Task', 'kind': 'code', 'acceptance': 'compile', 'depends': []}]}
        self.assertEqual(overseer.validate_queue(good)[0]['id'], 'one')
        for changes in [{'id':'../bad'}, {'depends':['missing']}, {'kind':'shell'}, {'title':''}]:
            bad = json.loads(json.dumps(good)); bad['tasks'][0].update(changes)
            with self.assertRaises(ValueError): overseer.validate_queue(bad)

    def test_run_starts_ollama_before_project_validation(self):
        calls = []
        with patch.object(self.app, 'write_owner'), patch.object(self.app, 'bootstrap', side_effect=lambda: calls.append('ollama-ready')), patch.object(self.app, 'validate_project', side_effect=lambda: (calls.append('project-validation'), (_ for _ in ()).throw(RuntimeError('fixture project error')))), patch.object(overseer.signal, 'signal'):
            self.app.run('fixture-order')
        self.assertEqual(calls, ['ollama-ready', 'project-validation'])
        self.assertEqual(self.app.state['status'], 'Blocked')

    def test_bootstrap_requires_actual_model_response(self):
        self.app.config['model'] = 'fixture-base'
        calls = []
        def native(endpoint, body):
            calls.append((endpoint,body))
            if endpoint=='/api/create': return {'status':'success'}
            if endpoint=='/api/chat': return {'message':{'tool_calls':[{'function':{'name':'cs_ready'}}]}}
            return {'response':'READY'}
        with patch.object(agent, 'request_json', return_value={}), patch.object(self.app, 'inventory'), patch.object(self.app, 'native', side_effect=native):
            self.app.bootstrap()
        self.assertTrue(self.app.state['ollama_ready'])
        self.assertEqual(calls[0][1]['from'], 'fixture-base')
        self.assertEqual(calls[0][1]['parameters']['num_ctx'], 32768)
        self.assertEqual(calls[1][1]['options']['num_ctx'], 32768)
        with patch.object(agent, 'request_json', return_value={}), patch.object(self.app, 'inventory'), patch.object(self.app, 'native', side_effect=[{}, {'response':'NO'}]):
            with self.assertRaisesRegex(RuntimeError, 'READY'): self.app.bootstrap()
        with patch.object(agent, 'request_json', return_value={}), patch.object(self.app, 'inventory'), patch.object(self.app, 'native', side_effect=[{}, {'response':'READY'}, {'message':{'content':'pretend tool call'}}]):
            with self.assertRaisesRegex(RuntimeError, 'real tool call'): self.app.bootstrap()

    def test_worker_config_local_model_and_broader_unity_scope(self):
        with patch.object(self.app, 'editor', return_value='Unity.exe'):
            request, result = self.app.worker_request({'id':'one','title':'Fix'}, 1)
        value = agent.read_json(request)
        self.assertEqual(value['model'], 'ollama/fixture:latest')
        self.assertEqual(value['config']['enabled_providers'], ['ollama'])
        self.assertIn('Editor scripts', value['prompt'])
        self.assertEqual(value['config']['permission']['external_directory'], 'deny')
        self.assertFalse(result.exists())

    def test_failure_retries_then_independent_task_runs(self):
        self.app.establish_branch()
        self.app.tasks = [
            {'id':'bad','title':'Bad task','kind':'code','acceptance':'compile','depends':[]},
            {'id':'dependent','title':'Dependent','kind':'code','acceptance':'play','depends':['bad']},
            {'id':'research','title':'Independent research','kind':'research','acceptance':'report','depends':[]}]
        calls = []
        def run(args, log, timeout):
            request = agent.read_json(args[-1])
            calls.append(request['prompt'])
            if 'Independent research' not in request['prompt']:
                raise RuntimeError('fixture compiler failure')
            agent.atomic(self.app.state_dir/'opencode-result.json', {'status':'implemented','summary':'Fixture research only','tests':[]})
            return '{"type":"text"}\n'
        with patch.object(self.app, 'editor', return_value='Unity.exe'), patch.object(self.app, 'live_command', side_effect=run):
            self.app.work_queue()
        self.assertEqual(len(calls), 3)
        self.assertEqual(self.app.state['tasks']['bad']['status'], 'failed')
        self.assertEqual(self.app.state['tasks']['dependent']['status'], 'dependency_blocked')
        self.assertEqual(self.app.state['tasks']['research']['status'], 'researched')
        self.assertIn('fixture compiler failure', self.app.state['tasks']['bad']['error'])

    def test_stop_prevents_next_task_and_preserves_edits(self):
        self.app.establish_branch()
        self.app.tasks = [{'id':'one','title':'One','kind':'code','acceptance':'compile','depends':[]}, {'id':'two','title':'Two','kind':'research','acceptance':'report','depends':[]}]
        def stop(*args):
            self.script.write_text('partial work preserved')
            raise agent.Stopped('fixture stop')
        with patch.object(self.app, 'editor', return_value='Unity.exe'), patch.object(self.app, 'live_command', side_effect=stop):
            with self.assertRaises(agent.Stopped): self.app.work_queue()
        self.assertEqual(self.script.read_text(), 'partial work preserved')
        self.assertNotIn('two', self.app.state['tasks'])
        self.assertEqual(self.app.state['tasks']['one']['status'], 'interrupted')

    def test_checkpoint_commits_deletions_but_refuses_runtime_changes(self):
        self.app.establish_branch()
        self.script.unlink()
        self.app.checkpoint('fixture deletion')
        self.assertEqual(self.git('status', '--porcelain'), '')
        (self.root/'arbitrary.py').write_text('unexpected file')
        with self.assertRaisesRegex(RuntimeError, 'outside development scope'): self.app.checkpoint('must fail')
        self.assertTrue((self.root/'arbitrary.py').exists())

    @unittest.skipIf(PROC_MISMATCH, 'Managed cloud process namespace; native Windows/Ubuntu CI exercises this')
    def test_owned_live_worker_cancelled_and_reaped(self):
        import subprocess, sys, threading, time
        self.app.running = True; self.app.run_id = 'test-owned'
        timer = threading.Timer(.4, self.app.stop_path.touch); timer.start()
        try:
            with self.assertRaises(agent.Stopped):
                self.app.live_command([sys.executable, '-c', 'import time; time.sleep(30)'], self.root/'live.log', 10)
            self.assertEqual(self.app.children, [])
        finally:
            timer.cancel(); self.app.running = False


if __name__ == '__main__': unittest.main()
