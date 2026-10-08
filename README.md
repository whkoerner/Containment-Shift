# Containment Shift

Original commercial-aspiring **1–4-player** PC industrial-disaster, horror and physics-comedy game. The facility itself is the systemic threat.

## Current state (2026-10-08)

**Phase 1A/1B source: IMPLEMENTED — UNVERIFIED. Game playable/build status: NOT TESTED.**
This is source for a *local single-player graybox* and a Unity Editor scene generator, not a compiled playable build. **No multiplayer package is installed yet.** No real Unity import or physics run has occurred.

## Open the first local graybox in Unity

1. Install [Unity Hub](https://unity.com/download) and Unity Editor **6000.3.25f1** (initial candidate), with Windows Build Support for local standalone tests.
2. Clone this repository/branch. In Hub, **Add project from disk** → select the nested **UnityProject/** folder (not the repository root).
3. Wait for package installation and import; resolve Console errors instead of assuming success. The manifest requests Input System **1.20.1**, URP **17.3.0** and Test Framework **1.6.0**. URP is not yet configured as the active render pipeline. **Accept Unity's prompt to enable the new Input System and restart the Editor**; verify Active Input Handling is New or Both under Player Settings.
4. Select **Containment Shift > Generate Phase 1 Graybox Scene** from the Editor menu. This creates and opens `Assets/ContainmentShift/Scenes/Phase1Graybox.unity`, sets it as a build scene and **will not overwrite it** on re-run.
5. Press Play. Click to lock the cursor; **WASD** walk, **Space** jump, **Esc** unlock, **E** use/pick up, **Q** drop, **F** throw. The two-room environment has a door, a warning-light switch and twelve primitive rigidbody props.
6. Run the EditMode suite at **Window > General > Test Runner** and perform the hands-on checks in [docs/TEST_PLAN.md](docs/TEST_PLAN.md).
7. After actually verifying imports and behavior, commit the Unity-generated scene, .meta files and build settings on a separate reviewable PR. Do not commit Unity cache directories.

These local components are not client/server-safe world authority. They demonstrate interaction feel only; networking authority moves through a server command boundary in the next gate.

## Architecture and handoff

- Start with [First Vertical Slice](docs/architecture/FIRST_VERTICAL_SLICE.md) and [Architecture Decision](docs/architecture/ARCHITECTURE_DECISION.md).
- See [Implementation decisions](docs/DECISIONS.md), [Roadmap](docs/ROADMAP.md), [Test plan](docs/TEST_PLAN.md), [Real test results](docs/TEST_RESULTS.md), [Not run](docs/NOT_RUN.md) and [AI agent instructions](AGENTS.md).
- Remaining Astra architecture docs stay under [docs/architecture](docs/architecture). They describe **proposed**, not measured, behavior.

**Engine:** Unity 6.3 LTS / C#; **planned** URP production visuals; **networking candidate:** FishNet 4.7.3R only after Gate A compatibility and multi-instance verification; server-authoritative facility domain independent of scenes.
