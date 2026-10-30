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
setup branch before merging this implementation. A dirty checkout is left
untouched and setup stops with an explanation. Save your changes in GitHub
Desktop, then repeat setup. Merge conflicts are aborted; no reset or force push
is used. A non-Git folder is never replaced.

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

## Explicit limits of this first implementation

No Windows/Unity/Ollama inference was executed in the author's cloud session.
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
