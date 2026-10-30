# Working Unity controls baseline — October 30, 2026

## Confirmed evidence
- A Windows Unity Editor `6000.6.7f1` batch build completed: `Build Finished, Result: Success.` and `[CS REPAIR BUILD] SUCCESS (compile/build only)` in `UnityBuild.log` supplied in the development conversation.
- After the input-backend repair, the game's screenshot showed `inputMode=BOTH`, `keyboard=NEW`, `mouse=NEW`, `paused=False`, spawned owner/controller/camera active, and an updated player position.
- **User playtest report:** Host/Play Solo, WASD, mouse look, Escape, Resume, Disconnect and reconnect work.
- **Not verified:** two-machine multiplayer, client input ownership, standalone runtime imported from *this GitHub checkout*, Unity Editor import of the GitHub checkout, production readiness. Do not mark these as passing without new evidence.

## Branch purpose
This branch is for importing the complete **current local AI Unity working copy** into a separate clean Git checkout. The GitHub branch is not an up-to-date Unity project until the `Assets/`, `Packages/`, and `ProjectSettings/` folders are added and pushed by the local sync tool. The earlier `feat/phase1a-graybox-foundation` prototype remains untouched.

The source project is local to the owner's Windows computer:
`%LOCALAPPDATA%\ContainmentShiftAgent\Work-20261030-045915\Project`.

Unity engine version: **6000.6.7f1**. Networking: **Netcode for GameObjects**, not FishNet. Input mode: **Both** (new Input System and legacy fallback).

## What belongs in Git
Track the original `Assets/`, `Packages/`, `ProjectSettings/`, every Unity `.meta` GUID, scenes, prefab/asset files and project settings. Exclude `Library/`, `Temp/`, `Logs/`, build outputs, user settings and AI agent workspace state.

Never replace .meta GUIDs or modify original NightKit or local agent history. A successful build does not equal working gameplay or validated remote multiplayer.

## Open in Unity Editor
After the local sync succeeds, the standalone project checkout is in **Documents/ContainmentShift-Unity** (resolved using Windows Documents location). In **Unity Hub → Add → Add project from disk**, select that folder, choose editor **6000.6.7f1**, then open a `.unity` scene from the Project panel.

Use the **Hierarchy** for scene objects, **Scene** for layout, **Inspector** for serialized movement settings/components, **Project** for scripts/assets, and double-click a C# script to open it in your configured external code editor (e.g. VS Code). Unity's Inspector is visual, but C# code is still text, not node-based visual scripting.

### Later movement tuning
Look for the `PlayerMovementSettings` ScriptableObject assigned to `CoopPlayerMotor.movementSettings`. Keep existing prefab/script references and edit numeric fields in the Inspector, test in Play Mode, then save and commit. Do not change behavior until controls pass again after the GitHub import.
