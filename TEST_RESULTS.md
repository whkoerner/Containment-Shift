# Test results — local workforce implementation

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
