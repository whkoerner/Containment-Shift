# Local verification procedure (no tests claimed by this plan)

1. Install **Unity Hub**, Unity **6000.3.25f1** with **Windows Build Support (IL2CPP)** on a compatible PC.
2. Clone branch feat/phase1a-graybox-foundation and open its **UnityProject** subdirectory in Unity Hub.
3. Check Console and Package Manager. Confirm Input System 1.20.1 and URP 17.3.0 resolve; inspect actual Packages/packages-lock.json before committing.
4. In Unity choose **Containment Shift > Generate Phase 1 Graybox Scene**. The command must create Assets/ContainmentShift/Scenes/Phase1Graybox.unity and register it in the build scenes. If the menu/compiler fails, log the error; do not mark pass.
5. Press Play. Mouse click to lock; WASD, Space, Escape; look at a prop, press E, Q to drop, F to throw. Walk into walls and the door. E on door swings door. E on switch toggles red light. Confirm 12 rigidbody props.
6. Open **Window > General > Test Runner**, EditMode and run InteractionRulesTests. Capture four real pass/fail results and Unity version.
7. Restart Editor and verify scene persists without lost scripts/materials/colliders or missing references; generator must refuse overwrite.
8. Use Build Profiles to produce a Windows standalone. Run exe and repeat mouse/keyboard, collision, grab, switch and door checks.
9. Before merging, commit the editor-generated .unity file, its .meta, build-scene metadata and any required project settings and package lock from a clean import. Confirm no Library, Temp, binaries or credentials are staged.
10. Multiplayer validation is separate: host+1 and host+3 real standalone processes, ownership conflict, reconnect, packet impairment, synchronization and Steam route must each be recorded when implemented. A solo playtest does not prove any of them.

Capture timestamp UTC, exact commit, editor, OS/hardware, console errors, outcome and logs in TEST_RESULTS.md. Never use an unconditional green assertion.

