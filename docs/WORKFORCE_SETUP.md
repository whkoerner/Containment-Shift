# Containment Shift local workforce

This is the first runnable workforce implementation, based on the imported Unity
project at `9946a89a9d7d03172d7ddc6ed3595bd83ad6cb08`. That project declares Unity
`6000.6.7f1`, NGO `2.13.3`, transport `2.6.0`, and Input System `1.20.1`.

The imported settings had `activeInputHandler: 0` although the player reads
`Keyboard.current` and `Mouse.current`. This branch changes the setting to `2`
(Both). Unity must restart after the backend changes. This is a source-level
repair; it is **not** evidence that this checkout has been played.

## Install

Download the setup ZIP, right-click it, choose **Extract All**, open the extracted
folder, and double-click **SETUP.cmd**. Alternatively, in this Git branch,
double-click **INSTALL_WORKFORCE.cmd**.

The installer detects Git and Python, installs missing versions through Windows
Package Manager, gets this branch, installs the pinned psutil dependency into a
local virtual environment, runs the runtime tests, then creates six desktop
shortcuts. It detects Ollama and installs it only if missing. No paid inference
service is required. No model weights are downloaded automatically.

The default project is Windows Documents/ContainmentShift-Unity, including a
redirected Documents folder. An existing clean checkout is preserved on a new
setup branch before merging this implementation. If that checkout has uncommitted
changes, setup leaves its working files, index and branch intact and uses one
linked Git worktree at Documents/ContainmentShift-Workforce. Committed source work
is integrated with the workforce branch there. Uncommitted edits stay in the
original folder and are not automatically copied, committed or published. Setup
reuses that one worktree on subsequent runs. Merge conflicts are aborted; no
reset or force push is used. A non-Git folder is never replaced.

Keep the original `%LOCALAPPDATA%/ContainmentShiftAgent` workspace as a backup.
This workforce refuses to use it as its development checkout.

If the diagnostic says the Editor is missing, open Unity Hub and install
**6000.6.7f1**, including **Windows Build Support (Mono)**. Install the license in
Unity Hub normally. If your Editor is installed on another drive, set the `unity`
field in `.workforce/config.json` to its full `Editor/Unity.exe` path.

If Ollama is not running, open **Ollama** from the Start menu. The agent lists
installed models and chooses the largest installed coding model below a
conservative available-RAM budget. If no appropriate local model is found, set
`model` to an already installed local coding model in `.workforce/config.json`.
Hardware, free RAM/disk, GPU VRAM and temperature (where nvidia-smi is available)
are recorded before development. Actual throughput is logged per inference.

The first Git push may open Git Credential Manager. Sign in to your own GitHub
account. Credentials stay in Windows/Git tooling. `GH_TOKEN` or `GITHUB_TOKEN`
is optional for a larger research API allowance; never put a token in a document
or Git file. Unauthenticated public GitHub research can hit rate limits, which
become an actionable blocker rather than an endless retry.

## Everyday use

1. Close this project in Unity and stop any older development agent using its own
   controls. This system never kills a process merely because its name is Unity,
   Python, Ollama, or PowerShell.
2. Click **START CONTAINMENT SHIFT AGENT**. The status window opens. Check its
   project path, task, blocker, branch, source commit and last pushed commit.
3. Click **STOP AND SAVE AGENT** when you want to play. Wait for **Stopped** or
   **Blocked**, with **Supervisor alive: False**. Status windows are just controls;
   closing a status window does not stop the supervisor.
4. If shutdown gets stuck, click **EMERGENCY STOP AGENT**. Only the saved PID plus
   creation-time identity and the supervisor run token establish ownership.
5. Click **PLAY CONTAINMENT SHIFT**. The correct Editor opens the existing
   `Annex_Greybox` scene. Click **Play**, then **Host Game**, then inside the Game
   view. Opening Unity is not recorded as a successful playtest.
6. Click **SUBMIT PLAYTEST FEEDBACK**. Describe what worked and failed. Attach
   screenshots, a short video, or a Word/text/Markdown document, and click
   **Save Feedback**. Keep attachment files available until the next Start.
7. If every displayed task criterion worked, choose that task and check the
   personal-confirmation box. Otherwise leave it unchecked and report failures.
   Confirmation is tied to the source commit associated with the pending test.
8. Close Unity and click Start again. Feedback is imported once by content hash
   and pushed to the README-linked **REAL-TIME TESTS** hub on the agent branch.

**VIEW AGENT STATUS** opens controls at any time. Multiple views are safe; an OS
file lock prevents two development supervisors from owning the same project.
Do not edit the project in another tool while an agent task is active.

## What the loop actually does

It validates the actual source folders, exact origin, Editor/package versions and
project locks. It preserves existing edits and refuses to stage them. It checks
out a dedicated `agent/workforce-*` branch from the current clean local source.
It fetches but never silently pulls/merges a remote development branch. Remote
divergence makes a normal push fail and leaves the local commit available.

The dependency queue first researches input/NGO candidates. Research includes a
GitHub repository search, exact revisions, actual license bodies, maintenance
metadata and explicit compatibility gaps. It never executes repository install
scripts or automatically imports an entire package. For licensed-candidate
review it accepts MIT/BSD/Apache/CC0/Unlicense; other licenses stay blocked.

The first foundation attempt verifies the existing player without replacing it.
If that fails, a local Ollama planner/implementer receives bounded source excerpts,
the acceptance criteria, research and exact failure. A second inference reviews
its proposal. The controller accepts only unique, exact substring replacements
in existing `Assets/ContainmentShift/Scripts/*.cs` files. No model-supplied shell
commands, test changes, metadata edits, package installs, new frameworks, active
supervisor changes or new large systems are applied.

Each patch has a durable per-file journal before mutation. Failed verification
rolls it back. Verified source is committed before normal pushes; failed pushes
preserve those commits. Restart recovers interrupted uncommitted agent patches
only when their recorded bytes still match, preserving subsequent external edits.
No stash, force push, reset, bulk deletion or global process-kill command is used.

Tests run against the existing scene without regenerating it:

| Evidence | Meaning |
|---|---|
| Editor compile/prefab check | Editor loaded scripts; input define and serialized references exist |
| Synthetic Editor smoke | Host/owner spawn plus W, sprint, jump and look produce measured changes using virtual Input System devices |
| Windows build | A development executable was produced; no standalone play is implied |
| Human playtest | Physical input, UI, collision and subjective results on the recorded source commit |
| Multiplayer | Requires a separate host/client playtest; synthetic single-host smoke does not establish it |

Automatic tasks have bounded attempts and timeouts. Three failed attempts block
that task. Quiet/Balanced/Maximum modes use one sequential model, with increasing
context/output budgets and 2/4/8 task attempts per run. An 8-hour cap is an upper
bound, not a requirement to waste GPU time. If only human-gated or blocked tasks
remain, the agent exits and saves the handoff. Independent research can finish
while movement awaits human testing; it is labeled research, not game progress.
Low memory/disk or high reported GPU temperature stops further work.

## Configuration and recovery

### 32K context

The current controller requests 32768 context tokens by default. `num_ctx` in
`.workforce/config.json` overrides profile context sizes for every model call;
null explicitly restores the profile default. The allowed range is 1024-131072.
Model support and available memory still determine whether a requested size can
run successfully. Quiet/Balanced/Maximum retain their output and task budgets.
The source-excerpt budget also follows the configured context; the controller
still retrieves relevant files instead of filling the entire window needlessly.

For an already-installed controller from the earlier setup, use the separate
32K update ZIP: **Stop and Save**, wait for **Supervisor alive: False**, close the
old status window, extract the update ZIP, then double-click
**ENABLE_32K_CONTEXT.cmd**. It verifies pinned old/new controller hashes, respects
the same Windows byte-range project lock as Python, compiles the replacement,
retains one original controller/config backup, sets `num_ctx` to 32768, raises
the inference timeout to at least 900 seconds, and commits only the reviewed
controller on the existing `agent/` branch. Other staged/untracked changes stay
untouched. Unknown or staged controller edits block the update. It does not
modify the active supervisor, change shared Ollama settings, or pull model weights.

Use the normal Start shortcut afterward. The dashboard displays the requested
context once inference begins; `ollama ps` shows the allocated CONTEXT and
PROCESSOR split. Verify 32768 and GPU placement again. A 14B model that fitted
entirely on GPU at 4096 tokens may need CPU offloading at 32768. The updater does
not silently lower context or guarantee the larger cache fits the laptop GPU.

This changes the agent's API `options.num_ctx`. Changing a general Ollama setting
alone cannot override a smaller value explicitly sent by an older controller.

Edit `.workforce/config.json` with Notepad while the agent is stopped:

- `profile`: `Quiet`, `Balanced`, or `Maximum`.
- `model`: exact name from your local `ollama list`; blank enables selection.
- `push`: false keeps local commits without attempting a push.
- `max_hours`, `max_attempts`: run/repair budgets.
- `feedback_folders`: optional full paths to folders containing playtest documents.
- `unity`: optional full path to the exact Editor version.

State, inventory, event logs, Unity evidence/logs, proposals and recovery journal
are in ignored `.workforce/`. The dashboard shows blocked errors. Do not delete
the transaction journal while an interrupted patch needs recovery. If a stale
Unity lock remains after a crash, reopen/close the project normally or inspect it
manually; this agent never deletes the lock to force access.

If tests pass but push fails, sign in using GitHub Desktop/Git Credential Manager,
inspect the normal branch state, then run Start again. Local work is still there.
If the checkout contains user edits, commit them yourself before Start. The
agent writes a diagnostic diff but does not treat that diff as a full backup of
untracked files; those files remain untouched in place.

The dashboard's cleanup button removes only week-old regenerable model/command
scratch in `.workforce`. It never deletes Unity caches, feedback, builds, Git
history, original assets, test evidence or recovery checkpoints.

## Missing desktop controls

Shortcuts are created by Windows setup on your computer; downloading the ZIP or
publishing the GitHub branch does not install them. Extract the setup ZIP before
running **SETUP.cmd**. If setup stops earlier, no shortcuts have been installed.
The setup transcript is `%LOCALAPPDATA%/ContainmentShiftWorkforce/setup.log`.

If you already installed the workforce, double-click **FIX_SHORTCUTS.cmd** in the
updated extracted setup folder. It checks required installation files, recreates
and reads back all six shortcuts in Windows' physical Desktop directory, and
opens a fallback controls folder at `.workforce/controls`. Double-click **VIEW
AGENT STATUS** in that folder. This repair does not start workers, change Git
branches, reinstall dependencies, or change the Unity project source. If setup is
incomplete, it names missing files and leaves the error visible.

Setup prints both the resolved Desktop and controls-folder paths. It now creates
controls before attempting an optional Ollama installation, so a failed Ollama
install does not hide the status controls. Success means each saved shortcut's
target, action arguments and working directory have been read back and checked;
it does not establish that the agent or game ran successfully.

### Git already installed / no upgrade available

Setup version `git-detection-fix-2` fixes a dependency lookup error where the
installer's own `Git` PowerShell helper hid the installed Git application. Program
detection now explicitly selects applications and skips Windows Store Python
aliases. Known WinGet responses for an already-installed/current package continue
to a fresh executable lookup after reloading Windows PATH entries. Other install
errors still stop setup and retain the package manager's exit code in the log.

If you received this older error, download the updated ZIP, extract it, and run
**SETUP.cmd** again. The shortcut repair alone cannot install the missing runtime.
The setup version prints near the beginning so you can identify an old download.

### Uncommitted checkout edits / incompatible default Python

Setup `preserve-edits-fix-3` quietly probes Python candidates, preferring the
installed Python 3.12 paths and registry entries before other PATH executables.
It never selects an unsupported executable merely because it appears first in
PATH. A rejected candidate no longer prints an AssertionError.

An existing uncommitted project no longer requires a blanket commit to install
the workforce. Setup uses a separate linked checkout and records its source in
ignored `.workforce/setup-source.json`. The active project is recorded in
`%LOCALAPPDATA%/ContainmentShiftWorkforce/installation.json`; desktop controls and
the shortcut repair use that location. Review uncommitted original edits before
deliberately integrating them later. Setup does not publish them as a checkpoint.

## Explicit limits of this first implementation

The runtime suite passed Windows and Ubuntu CI (24 tests); Windows also passed
setup-script parsing and isolated Git-argument integration. The installer itself,
Unity and real Ollama inference have not run on the user's laptop.
The installer runs runtime tests locally before enabling shortcuts. Unity smoke
and build entry points still require the actual licensed Editor and project
import. The existing input settings repair requires a fresh local gameplay test.

The initial queue covers foundation verification/repair, NGO owner lifecycle,
and interaction research. The remaining game roadmap is still planned; it is
not represented as automatically completed or as unrestricted code generation.
Additional small tasks can be added to version-controlled `tasks.json` with
explicit acceptance, dependencies and research sources.

Automatic package imports, two-client orchestration, notifications inside
ChatGPT, GitHub Issue creation, thermal control, unattended runtime upgrades and
AI self-modification are **not implemented**. Bug IDs and reports provide local
equivalent tracking in GitHub. Self-improvement must be proposed on a separate
branch and installed only while stopped after runtime tests; the active
supervisor cannot edit or replace itself. A model review is not an OS security
sandbox. Run on your development checkout under your own account.

## OpenCode overseer update

The newer launcher starts/reuses local Ollama first and requires a real READY
response at 32768 context. A dedicated Ollama model alias sets context for
OpenCode's OpenAI-compatible requests, without changing global Ollama settings.
Then a local overseer plans an ordered queue and launches actual `opencode run`
workers with the explicitly selected local model. This is distinct from the old
JSON patch-only controller. Existing global/project OpenCode settings are merged
by OpenCode; inline local model settings take precedence. Verify Unity MCP targets
the workforce checkout before using it; no settings are copied from the older
AI-Playable folder.

Extract the OpenCode overseer update ZIP. Stop and Save the current workforce,
wait for Supervisor alive False, close its old status window, and stop the
separate AI-Playable OpenCode session yourself. Double-click
INSTALL_OPENCODE_OVERSEER.cmd, then use the normal Start shortcut. This updates
the controller's 32K support plus three launcher/worker files, with backups and
file-scoped Git commits; it preserves unrelated edits and checks custom versions
before replacement. No reinstall or automatic project migration is involved.

The controller now owns its OpenCode worker and shows live output. Stop cancels
that worker and its identified descendants, checkpoints useful partial work as
unverified, and writes a wrapup. It leaves unrelated OpenCode sessions and an
existing shared Ollama server alone. A server it starts itself is owned and
stopped with its run. Emergency Stop interrupts owned processes immediately.
OpenCode's permissions and instructions are development boundaries, not an OS
sandbox; the worker can run build/tool commands. No worker self-modification of
the supervisor is authorized. Runtime/Editor code, settings, assets and package
configuration can be repaired.

Each task gets up to max_attempts (default 3) and task_timeout (default 1800s).
After exhaustion it is failed for this run and the scheduler considers the next
independent task. Dependent gameplay tasks still require actual human acceptance;
the model cannot waive that gate. Failed tasks can retry on the next Start. Code
claims require separate supervisor-run Unity compile, smoke and build evidence.
Research completion is a worker report, not gameplay proof. The overseer records
outcomes/failures in docs/OVERSEER_REPORT.json plus the existing task board and
reports, and publishes its agent branch at wrapup. The queue is persisted in
.workforce/overseer-queue.json and resumed. It does not invent infinite new work
when all queued tasks are finished or waiting for a person.

Prerequisites: installed OpenCode with run --format/--model/--auto support (the
existing known CLI interface), supported local Ollama model, correct Unity Editor
and a clean dedicated agent checkout. Startup failures remain visible and do not
claim that a worker ran. Real local inference/Unity/MCP/GPU behavior still needs
verification on the user's laptop; fixture tests cannot establish it.
