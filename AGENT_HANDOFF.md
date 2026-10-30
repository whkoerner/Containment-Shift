# Agent handoff

Latest installer fix: `git-detection-fix-2`. The installed Git executable was
hidden by the setup's own `Git` function because dependency lookup accepted all
command types. Only Application commands are now accepted; WinGet's known
already-installed/current results are followed by executable rechecks, while
real installer failures still stop. Re-run the updated SETUP.cmd after the user
reported missing runtime files. FIX_SHORTCUTS.cmd does not install a runtime.

Project base: `9946a89a9d7d03172d7ddc6ed3595bd83ad6cb08`.
Implementation branch: `feat/local-workforce-20261030`.

Unity source is now present on the import-based branch. Editor is `6000.6.7f1`;
NGO `2.13.3`, transport `2.6.0`, Input System `1.20.1`. Keep NGO.

The concrete input mismatch was the imported project's old-only backend combined
with new-Input-System runtime scripts. Setting changed from 0 to 2. No Unity
execution was possible in the cloud session, so this is not gameplay acceptance.

Runtime: `tools/workforce/agent.py`. Windows install: `INSTALL_WORKFORCE.cmd`.
Detailed operation and remaining capabilities: `docs/WORKFORCE_SETUP.md`.
Regression evidence: `TEST_RESULTS.md`. Initial tasks: `tools/workforce/tasks.json`.

Full runtime suite: Windows and Ubuntu CI passed 24 tests for
`1294f829a1904bb7656c9a3772b621cc86968a55`, including the real process tests.
Windows additionally passed PowerShell parsing and installer argument forwarding.
This does not establish local Unity or model functionality.

Desktop-control repair: Windows setup now verifies the saved shortcuts and opens
`.workforce/controls` as a fallback. `FIX_SHORTCUTS.cmd` in the updated setup ZIP
recreates them for an existing installation or identifies missing setup files.
Setup writes `%LOCALAPPDATA%/ContainmentShiftWorkforce/setup.log`. Do not assume
the user's setup completed merely because the code/ZIP was delivered.

Next action: user extracts setup ZIP and double-clicks SETUP.cmd. Windows runtime
tests must pass before installer creates controls. Start then checks the actual
machine, installed model, exact Editor, source/locks and clean Git state. It first
tries compile, synthetic movement and build against the existing scene. Small
repairs can be proposed by local Ollama after failures, then reviewed and tested.

Do not overwrite the old `%LOCALAPPDATA%/ContainmentShiftAgent` workspace. Do not
rewrite controller/scene/prefab or switch networking without current evidence.
Do not mark the authored Unity smoke/build, local Ollama or Windows setup as
executed based on the cloud test suite. Source/code progress and human acceptance
are separate. No automatic runtime self-upgrade is enabled.
