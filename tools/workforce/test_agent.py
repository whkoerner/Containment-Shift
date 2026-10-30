"""Runtime regressions; Unity/Ollama substitutes are explicitly labeled in tests."""
import base64
import contextlib
import functools
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import threading
import time
import unittest
from unittest.mock import patch

import agent

# Some managed cloud executors expose a parent-namespace /proc inside a nested
# PID namespace. It cannot exercise psutil ownership. Windows CI and local
# installer run the unadapted suite. This adapter only executes Git/file tests.
PROC_MISMATCH = sys.platform == "linux" and str(agent.os.getpid()) != agent.os.readlink("/proc/self")


class Fixture(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        for directory in ["Assets/ContainmentShift/Scripts", "Assets/ContainmentShift/Scenes", "ProjectSettings", "Packages"]:
            (self.root / directory).mkdir(parents=True)
        self.script = self.root / "Assets/ContainmentShift/Scripts/Motor.cs"
        self.script.write_text("public class Motor { public int speed = 1; }\n")
        (self.root / "Assets/ContainmentShift/Scenes/Annex_Greybox.unity").write_text("fixture scene only\n")
        (self.root / "ProjectSettings/ProjectVersion.txt").write_text("m_EditorVersion: 6000.6.7f1\n")
        (self.root / "ProjectSettings/ProjectSettings.asset").write_text("activeInputHandler: 2\n")
        (self.root / "Packages/manifest.json").write_text('{"dependencies":{}}')
        (self.root / "Packages/packages-lock.json").write_text('{"dependencies":{}}')
        (self.root / ".gitignore").write_text(".workforce/\n")
        self.git("init")
        self.git("config", "user.email", "fixture@example.invalid")
        self.git("config", "user.name", "Runtime Test Fixture")
        self.git("remote", "add", "origin", agent.REMOTE)
        self.git("add", ".")
        self.git("commit", "-m", "fixture baseline")
        self.config = self.root / ".workforce/config.json"
        agent.atomic(self.config, {"project": str(self.root), "push": False})
        self.app = agent.Workforce(self.config)
        if PROC_MISMATCH:
            def fixture_command(args, timeout=60, check=True, interruptible=True):
                result = subprocess.run([str(a) for a in args], cwd=self.root, timeout=timeout,
                                        stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                output = result.stdout.decode("utf-8", "replace").strip()
                if check and result.returncode:
                    raise RuntimeError(output)
                return output, result.returncode
            self.adapter = patch.object(self.app, "command", side_effect=fixture_command)
            self.adapter.start()
            self.addCleanup(self.adapter.stop)

    def tearDown(self):
        self.temp.cleanup()

    def git(self, *args):
        return subprocess.check_output(["git", *args], cwd=self.root, stderr=subprocess.STDOUT).decode().strip()

    def plan(self, path="Assets/ContainmentShift/Scripts/Motor.cs"):
        return {"edits": [{"path": path, "old": "speed = 1", "new": "speed = 2"}]}

    def test_project_validation_and_input_version(self):
        self.app.validate_project()
        self.assertEqual(self.app.version(), "6000.6.7f1")

    def test_wrong_remote_blocks(self):
        self.git("remote", "set-url", "origin", "https://github.com/other/project.git")
        with self.assertRaisesRegex(RuntimeError, "Wrong origin"):
            self.app.validate_project()

    def test_incomplete_project_blocks(self):
        (self.root / "Packages/packages-lock.json").unlink()
        with self.assertRaisesRegex(RuntimeError, "Incomplete"):
            self.app.validate_project()

    def test_old_workspace_is_read_only(self):
        with patch.dict(agent.os.environ, {"LOCALAPPDATA": str(self.root)}):
            agent.atomic(self.config, {"project": str(self.root / "ContainmentShiftAgent/Work/Project")})
            with self.assertRaisesRegex(ValueError, "read-only"):
                agent.Workforce(self.config)

    def test_patch_and_rollback(self):
        before = self.script.read_bytes()
        originals = self.app.apply(self.plan())
        self.assertIn("speed = 2", self.script.read_text())
        self.app.rollback(originals)
        self.assertEqual(self.script.read_bytes(), before)

    def test_unsafe_paths_never_written(self):
        for path in ["../agent.py", "/tmp/damage.cs", "Assets/ContainmentShift/Scripts/../../x.cs",
                     "tools/workforce/agent.py", "Assets/ContainmentShift/Editor/Test.cs",
                     "Assets\\ContainmentShift\\Scripts\\Motor.cs", "C:/temp/file.cs"]:
            with self.subTest(path=path), self.assertRaises(ValueError):
                self.app.apply(self.plan(path))
        self.assertIn("speed = 1", self.script.read_text())

    def test_all_patch_preconditions_checked_before_any_write(self):
        plan = self.plan()
        plan["edits"].append({"path": "Assets/ContainmentShift/Scripts/Motor.cs", "old": "not present", "new": "x"})
        with self.assertRaises(ValueError):
            self.app.apply(plan)
        self.assertIn("speed = 1", self.script.read_text())

    def test_interrupted_patch_recovers(self):
        self.app.apply(self.plan())
        self.app.recover()
        self.assertIn("speed = 1", self.script.read_text())

    def test_recovery_preserves_external_edit(self):
        self.app.apply(self.plan())
        self.script.write_text("human edit\n")
        with self.assertRaisesRegex(RuntimeError, "external edits"):
            self.app.recover()
        self.assertEqual(self.script.read_text(), "human edit\n")

    def test_recovery_never_undoes_a_completed_commit(self):
        self.app.apply(self.plan())
        self.git("add", "Assets")
        self.git("commit", "-m", "verified source")
        self.app.recover()
        self.assertIn("speed = 2", self.script.read_text())
        self.assertEqual(self.git("status", "--porcelain"), "")

    def test_preexisting_work_preserved(self):
        self.script.write_text("human changes\n")
        with self.assertRaisesRegex(RuntimeError, "existing edits"):
            self.app.establish_branch()
        self.assertEqual(self.script.read_text(), "human changes\n")
        self.assertTrue((self.root / ".workforce/preexisting.diff").exists())

    def test_dependency_requires_human_evidence(self):
        self.app.state["tasks"]["foundation-input"] = {"status": "awaiting_human"}
        self.app.state["tasks"]["interaction-research"] = {"status": "researched"}
        self.assertIsNone(self.app.choose())
        self.app.state["tasks"]["foundation-input"]["status"] = "human_verified"
        self.assertEqual(self.app.choose()["id"], "network-ownership")

    def test_feedback_dedup_and_commit_bound_acceptance(self):
        inbox = self.root / ".workforce/feedback-inbox"
        inbox.mkdir()
        self.app.state["tasks"]["foundation-input"] = {"status": "awaiting_human", "code_commit": "abc"}
        agent.atomic(inbox / "human.json", {"comments": "Controls work", "human_confirmed": True, "tested_commit": "wrong"})
        self.assertTrue(self.app.ingest_feedback())
        self.assertEqual(self.app.state["tasks"]["foundation-input"]["status"], "awaiting_human")
        self.assertEqual(self.app.ingest_feedback(), [])
        agent.atomic(inbox / "human2.json", {"comments": "All checks passed", "human_confirmed": True, "tested_commit": "abc"})
        self.app.ingest_feedback()
        self.assertEqual(self.app.state["tasks"]["foundation-input"]["status"], "human_verified")

    def test_negative_feedback_reopens_repair_and_blocks_dependencies(self):
        inbox = self.root / ".workforce/feedback-inbox"
        inbox.mkdir()
        self.app.state["tasks"]["foundation-input"] = {"status": "human_verified", "code_commit": "abc"}
        agent.atomic(inbox / "failure.json", {"comments": "Escape does not work", "human_confirmed": False, "tested_commit": "abc"})
        self.app.ingest_feedback()
        task = self.app.state["tasks"]["foundation-input"]
        self.assertEqual(task["status"], "pending")
        self.assertEqual(task["attempts"], 1)
        self.assertIn("Escape does not work", task["error"])
        self.assertEqual(self.app.choose()["id"], "foundation-input")

    def test_unrelated_staged_files_never_committed(self):
        (self.root / "user.txt").write_text("private user work")
        (self.root / "report.md").write_text("agent report")
        self.git("add", "user.txt")
        revision = self.git("rev-parse", "HEAD")
        with self.assertRaisesRegex(RuntimeError, "Unrelated staged"):
            self.app.publish(["report.md"], "agent")
        self.assertEqual(self.git("rev-parse", "HEAD"), revision)

    def test_cleanup_preserves_evidence_and_feedback(self):
        for name in ["model-output.json", "unity-compile.log", "transaction.json"]:
            path = self.app.state_dir / name
            path.write_text("keep")
            agent.os.utime(path, (0, 0))
        self.app.cleanup()
        self.assertFalse((self.app.state_dir / "model-output.json").exists())
        self.assertTrue((self.app.state_dir / "unity-compile.log").exists())
        self.assertTrue((self.app.state_dir / "transaction.json").exists())

    @unittest.skipIf(PROC_MISMATCH, "Cloud /proc namespace mismatch; requires Windows CI/local verification")
    def test_stale_pid_identity_rejected(self):
        record = agent.record_process(agent.os.getpid())
        record["created"] -= 100
        self.assertIsNone(agent.exact_process(record))

    def test_single_instance_lock(self):
        with agent.InstanceLock(self.app.state_dir / "lock"):
            with self.assertRaises(RuntimeError):
                with agent.InstanceLock(self.app.state_dir / "lock"):
                    pass

    @unittest.skipIf(PROC_MISMATCH, "Cloud /proc namespace mismatch; requires Windows CI/local verification")
    def test_command_timeout_terminates_its_process(self):
        with self.assertRaises(TimeoutError):
            self.app.command([sys.executable, "-c", "import time; time.sleep(30)"], timeout=.25)
        self.assertEqual(self.app.children, [])

    @unittest.skipIf(PROC_MISMATCH, "Cloud /proc namespace mismatch; requires Windows CI/local verification")
    def test_graceful_stop_cancels_command(self):
        self.app.running = True
        self.app.run_id = "test-run"
        timer = threading.Timer(.3, self.app.stop_path.touch)
        timer.start()
        try:
            with self.assertRaises(agent.Stopped):
                self.app.command([sys.executable, "-c", "import time; time.sleep(30)"], timeout=5)
        finally:
            timer.join()
        self.assertEqual(self.app.children, [])

    @unittest.skipIf(PROC_MISMATCH, "Cloud /proc namespace mismatch; requires Windows CI/local verification")
    def test_process_tree_emergency_leaves_unrelated_process_alive(self):
        token = "workforce-test-" + agent.uuid.uuid4().hex
        code = "import subprocess,sys,time; subprocess.Popen([sys.executable,'-c','import time; time.sleep(60)']); time.sleep(60)"
        parent = subprocess.Popen([sys.executable, "-c", code, token])
        unrelated = subprocess.Popen([sys.executable, "-c", "import time; time.sleep(60)"])
        record = agent.record_process(parent.pid, token)
        try:
            time.sleep(.3)
            children = agent.psutil.Process(parent.pid).children(recursive=True)
            self.assertTrue(children)
            agent.terminate_owned(record)
            parent.wait(timeout=5)
            self.assertIsNone(unrelated.poll())
            self.assertIsNone(agent.exact_process(record))
            self.assertTrue(all(not p.is_running() or p.status() == agent.psutil.STATUS_ZOMBIE for p in children))
        finally:
            with contextlib.suppress(Exception):
                parent.kill()
            unrelated.kill()
            unrelated.wait()

    def test_fresh_unity_evidence_required(self):
        with patch.object(self.app, "editor", return_value=sys.executable), patch.object(self.app, "unity_busy", return_value=False), patch.object(self.app, "command", return_value=("", 0)):
            with self.assertRaisesRegex(RuntimeError, "Fresh positive"):
                self.app.verify()

    def test_real_ollama_http_protocol_against_local_fixture(self):
        class Handler(BaseHTTPRequestHandler):
            def do_POST(self):
                body = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
                self.server.seen = body
                response = json.dumps({"message": {"content": '{"approved":true}'}, "eval_count": 7}).encode()
                self.send_response(200)
                self.end_headers()
                self.wfile.write(response)

            def log_message(self, *args):
                pass

        server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        try:
            self.app.config.update(model="fixture-model", ollama=f"http://127.0.0.1:{server.server_port}")
            self.assertEqual(self.app.model("Reviewer", {"fixture": True}), {"approved": True})
            self.assertEqual(server.seen["model"], "fixture-model")
            self.assertFalse(server.seen["stream"])
            self.assertTrue((self.app.state_dir / "events.jsonl").exists())
        finally:
            server.shutdown()
            server.server_close()
            thread.join()

    def test_end_to_end_runtime_with_explicit_unity_research_fixtures(self):
        # Real Git, journal, subprocess infrastructure, report and resume state; no Unity claim.
        self.app.state["branch"] = self.git("branch", "--show-current")
        task = self.app.tasks[0]
        research_path = self.root / "docs/agent-research/foundation-input.json"
        agent.atomic(research_path, [{"fixture": True}])
        with patch.object(self.app, "research", return_value=[{"fixture": True}]), patch.object(self.app, "verify", side_effect=lambda method: {"passed": True, "level": "TEST_DOUBLE_ONLY", "method": method}):
            self.app.run_task(task)
        self.assertEqual(self.app.state["tasks"][task["id"]]["status"], "awaiting_human")
        self.app.publish(self.app.reports(), "fixture handoff")
        resumed = agent.Workforce(self.config)
        self.assertEqual(resumed.state["tasks"][task["id"]]["status"], "awaiting_human")
        self.assertNotEqual(self.git("log", "-1", "--format=%s"), "fixture baseline")
        self.assertTrue((self.root / "AGENT_HANDOFF.md").exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
