# Containment Shift

Original commercial-aspiring **1–4-player**, fully solo-viable PC cooperative industrial-disaster, horror and physics-comedy game. **The facility itself is the systemic threat.**

**Status (2026-10-08): Phase 1A/1B source IMPLEMENTED — UNVERIFIED; no confirmed playable Unity build.** Local input, controller, prop interactions, switch and door C# scripts plus a scene **generator** exist in the draft PR. **The generated scene has not been saved by Unity; multiplayer is not implemented.** Main remains architecture-only.

## First-time Unity validation (required gate)
1. Install Unity Hub and Editor **6000.3.25f1** with Windows Build Support (IL2CPP on Windows; install Mono backend if your test workflow needs it). Clone or checkout `feat/phase1a-graybox-foundation` (draft PR #1).
2. In Hub **Add > Add project from disk**, select this repository's **UnityProject/** subdirectory. Wait for package import. Open **Window > General > Console**. Resolve actual errors and record them. If prompted, enable the **new Input System** and restart. Confirm under **Edit > Project Settings > Player > Other Settings > Active Input Handling** (New or Both).
3. In Editor select **Containment Shift > Generate Phase 1 Graybox Scene**. Check `Assets/ContainmentShift/Scenes/Phase1Graybox.unity`, its scene .meta and Build Profiles scene list. If active Build Profile overrides the global scene list, enable this scene there too.
4. Press **Play**. Mouse click to lock, **WASD** move, **Space** jump, **Esc** unlock, **E** pick up/use, **Q** drop, **F** throw. Inspect walls, door, light switch and 12 physics objects. Record failures.
5. Open **Window > General > Test Runner > EditMode**; run `InteractionRulesTests` and save the actual four results. Restart Editor to confirm serialization. Build a Windows x64 standalone through **File > Build Profiles** and launch it independently; retain player logs. Do not claim PASS for unexecuted steps.
6. Commit generated `.unity`/`.meta`, packages lock and `ProjectSettings/EditorBuildSettings.asset` only after real import/verification. Do not commit Library/ or built executables.

## Authoritative development docs
- **[PROJECT_EXECUTION_PLAN.md](docs/PROJECT_EXECUTION_PLAN.md)** — detailed phases, stable task IDs, prerequisites, acceptance and failure conditions.
- **[CURRENT_TASKS.md](docs/CURRENT_TASKS.md)** — one CURRENT task; NEXT/BLOCKED/COMPLETED/DEFERRED.
- **[NEXT_SESSION.md](docs/NEXT_SESSION.md)** — exact session handoff, live-state verification and test instructions.
- [TEST_PLAN.md](docs/TEST_PLAN.md), [TEST_RESULTS.md](docs/TEST_RESULTS.md), [NOT_RUN.md](docs/NOT_RUN.md), [BUGS.md](docs/BUGS.md), [DECISIONS.md](docs/DECISIONS.md), [DEVELOPMENT_LOG.md](docs/DEVELOPMENT_LOG.md), [AGENTS.md](AGENTS.md) and nine preserved [architecture reviews](docs/architecture).

**Engine direction:** Unity 6.3 LTS / C#, candidate Input System 1.20.1, URP 17.3.0 (installed manifest but **not active render pipeline**), Test Framework 1.6.0. FishNet 4.7.3R is an **uninstalled provisional candidate** pending real two/four-process tests. Do not assume package compatibility from manifest text.
