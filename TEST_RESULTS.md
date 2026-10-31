# Test results — local workforce implementation

## Ollama-first OpenCode overseer

At `72ba0eea119d69870eb764ffa78b1cfe1a12f5f9`, Windows and Ubuntu CI passed
the original 25 runtime tests and 9 overseer tests. Overseer coverage includes
Ollama-before-project startup order, real-response/tool-call validation using
explicit protocol substitutes, queue validation, task retry exhaustion followed
by independent work, dependency blocking, interruption preserving partial edits,
source deletion checkpoints, scope rejection, cancellation of an owned worker,
and cleanup of an observed surviving helper after normal parent exit.
Windows PowerShell 5.1 additionally passed the npm-style OpenCode .cmd launcher
fixture (local model/config plus quotes and newlines preserved in prompt files)
and updater integration (actual prior launcher replaced, reviewed payload
installed, unrelated staged work preserved, repeat update idempotent, custom
controller edits protected). Existing setup/shortcut/checkout/32K checks passed.
[Observed run](https://github.com/whkoerner/Containment-Shift/actions/runs/41151980437).

These are runtime and native launcher/update fixtures. They do not run an actual
local OpenCode/Ollama/Unity/MCP combination or measure GPU context allocation on
the user's laptop. The installed OpenCode must support the documented run flags
and provider/config interface; real tool calls are checked at startup. The
OpenCode permissions/instructions are development boundaries, not an OS sandbox.

## 32K context update

At `09ec898408c9cbe5825b56d5b4be4d49e1334546`, Windows and Ubuntu CI passed
the 25 runtime tests, including checking `options.num_ctx: 32768` in the actual
HTTP request sent to an isolated Ollama-protocol fixture. Windows additionally
passed the stopped-only updater test under built-in PowerShell 5.1: exact old
controller replacement, config preservation, one-file Git commit with unrelated
staged/untracked work preserved, idempotent reapplication, refusal of unknown
controller edits, and refusal while a real child process owns the project lock.
Existing dependency, shortcut, and checkout-preservation checks also passed.
[Observed run](https://github.com/whkoerner/Containment-Shift/actions/runs/41149625838).

Managed-cloud runtime checks: 21 passed; 4 process-ownership tests skipped due
to the process namespace limitation described below. The updater and real 32K
Ollama GPU placement have not been run on the user's own laptop. The user's
posted `ollama ps` output confirms 100% GPU placement at 4096 context only.

## Preserve-edits setup repair 3

At `bc91199fea395d76b11d7bd55cb2e11ea9af8f29`, Windows CI passed quiet Python
selection checks under PowerShell 7 and built-in PowerShell 5.1, plus the real Git
checkout integration test. That test hashes original staged/unstaged/untracked
files, compares the staged diff/HEAD/branch/status before and after, verifies
committed source work is retained, checks a single worktree is reused, rejects
an already-dirty agent worktree, and exercises fresh clone setup. The 24 runtime
tests and shortcut checks also passed. [Observed run](https://github.com/whkoerner/Containment-Shift/actions/runs/41145788837).

Package banner: `preserve-edits-fix-3`. A dirty original checkout is preserved
without automatically copying or publishing its uncommitted edits; the desktop
controls target the separate agent checkout. Actual laptop installation and Unity
gameplay still require local execution.

## Installer regression repair

User-reported Git.Git already-installed/no-upgrade failure reproduced in the
dependency lookup: a PowerShell `Git` helper hid the native Git executable.
Setup now selects Application commands, handles known installed/current WinGet
results before rechecking, and uses explicit named Git argument arrays compatible
with built-in Windows PowerShell 5.1. Native HRESULT handling is explicit.

At `ffcd889ac9b239886f70bc1009adc5e12b91282b`, Windows CI passed the runtime
suite, installer argument/detection checks under PowerShell 7 and PowerShell 5.1,
and real shortcut creation checks. WinGet package responses are simulated via a
native command fixture; no package installation on the user's PC is implied.
[Observed run](https://github.com/whkoerner/Containment-Shift/actions/runs/41143692929).

Packaged setup prints `Setup version: git-detection-fix-2`. Local installation
and actual Unity/Ollama operation remain unverified until the user runs it.

Inspected project baseline: `9946a89a9d7d03172d7ddc6ed3595bd83ad6cb08`.

Cloud command: `python -m unittest discover -s tools/workforce -p test_agent.py -v`

- **20 passed; 4 skipped** in this managed Linux environment.
- Checks cover project completeness and origin, protected old-workspace rejection,
  patch preconditions and path restrictions, rollback, interrupted recovery,
  completed-commit preservation, external-edit preservation, dirty checkout
  protection, unrelated staged files, feedback deduplication and commit-bound
  human acceptance, task dependencies, cleanup boundaries, exclusive locking,
  fresh Unity-evidence requirements, real HTTP requests to a local Ollama-protocol
  test server, and Git/report/resume behavior with explicitly substituted Unity
  and research results.
- The cloud's PID namespace differs from its mounted `/proc`. Non-process tests
  use a standard-subprocess adapter for Git/protocol commands. Four ownership,
  emergency-stop and cancellation checks are skipped here, **not passed**.
- **Windows and Ubuntu CI passed** the 24-test runtime suite at runtime commit
  `1294f829a1904bb7656c9a3772b621cc86968a55`. The Windows job additionally passed
  PowerShell parsing and the isolated installer Git-argument integration check.
  [Observed successful run](https://github.com/whkoerner/Containment-Shift/actions/runs/41139472507).
  These checks exercise runtime infrastructure, not Unity gameplay or installation
  on the user's own computer.
- Windows setup runs the full suite locally and refuses shortcuts if tests fail.
- Python source compiles with `py_compile`; Git whitespace checks run before commit.

## Source finding

The imported controller reads `UnityEngine.InputSystem.Keyboard`/`Mouse` while
`ProjectSettings.asset` saved `activeInputHandler: 0`. This branch changes it to
`2` (Both) and adds an Editor validation gate for `ENABLE_INPUT_SYSTEM` and
serialized player references. See the official Input System installation docs
listed in `THIRD_PARTY_NOTICES.md`.

## Not executed / not verified

- Windows installer and shortcuts on the user's PC.
- Real local Ollama model inference or measured GPU performance.
- Unity compile, authored synthetic movement smoke, or development build.
- Physical WASD/mouse, sprint/jump/collision, Escape, GUI and reconnect.
- Standalone gameplay or host plus independent client/multiplayer ownership.

The authored Unity smoke is a single-host synthetic input check in the existing
scene. It deliberately leaves human input, wall collision and multiplayer as
separate gates. No game content expansion has been marked complete.
