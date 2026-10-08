# Initial stack and implementation handoff

Status: PLANNED. No dependencies installed; no lockfile/build compatibility claim. Research date: 2026-10-08.

## Bootstrap list

| Layer | Initial choice | Exact pin / gate |
|---|---|---|
| Engine | Unity 6.3 LTS | 6000.3.25f1 is a verified candidate; confirm appropriate current 6000.3 patch and record exact version |
| Render | URP, simple lit materials, limited dynamic shadows | Use version resolved for chosen editor; lock after standalone smoke build |
| Language | C# using Unity-supported runtime/language features | Do not assume latest desktop .NET features work in IL2CPP |
| Domain | Plain C# records/structs, typed graph solvers, explicit scheduler | No third-party ECS required |
| Multiplayer | FishNet 4.7.3R spike | Resolve release to exact commit; no floating main dependency |
| Local transport | FishNet default transport | Resolve and document actual bundled dependency/version |
| Steam transport | FishySteamworks + Steamworks.NET | Pin compatible commits/releases after a two-device test; not yet verified together |
| Input | Unity Input System, action maps | Editor-compatible package; keyboard/mouse first, controller paths retained |
| Navigation | Unity AI Navigation | Compatible 2.0-line patch to verify; local surfaces + project portal graph |
| UI | uGUI/TextMeshPro for initial HUD and world controls | Use editor-compatible packages; one UI approach initially |
| Animation | Animator plus small IK/view layer | No paid active-ragdoll dependency until movement proof |
| Audio | Unity Audio + mixers; Steam Voice spike for speech | Codec/routing/mute/device behavior NOT TESTED |
| Localization | Keyed strings; Unity Localization package candidate | Pin package at bootstrap; include pseudo-localization test |
| Save | Versioned explicit DTOs, JSON initially | Verify serializer in both editor and IL2CPP, with no arbitrary type activation |
| Testing | Unity Test Framework plus domain tests and standalone process harness | Resolve compatible versions; real exit codes/log evidence |
| Profiling | Unity Profiler, project markers, transport wire counters | Development and release build measurements |
| Version control | Git, visible .meta, Force Text, Git LFS for large binary assets | Keep Assets/Packages/ProjectSettings; ignore generated Library/Temp/Logs/build outputs |

Sources and rationale: ARCHITECTURE_DECISION.md and NETWORKING_ARCHITECTURE.md. All versions absent from this table are deliberately unresolved, not invented. Install only the first gate's dependencies initially; Steam/voice and localization integration can follow without postponing their design contracts.

## Repository structure to create once target is available

`docs/architecture/` contains this package. `Assets/ContainmentShift/` contains Runtime/{Domain,Application,UnityRuntime,Networking,Platform,Presentation}, Editor, Tests and authored Content. Use assembly definitions to enforce dependency direction. Keep domain tests runnable without launching a rendered mission. Store third-party notices and provenance in a reviewed dependency/asset ledger.

Use small prefabs/modules; avoid one enormous scene and cross-scene references. Commit .meta with every Unity asset. Source text is useful for review, but Unity must import and validate scenes/prefabs—hand-edited YAML is not proof of correct editor wiring. Build deterministic editor import/build scripts where they remove repeated manual setup. Use LFS for meshes, audio and textures rather than compiled/generated caches.

## Instructions for GPT-5.6 Sol High implementation

1. Inspect actual repository state and applicable AGENTS.md first. If a target is missing, request it before writes to GitHub. Do not reuse Rocky or Chordic for this game.
2. Create one small implementation PR per gate/sub-gate. A PR states the behavior added, what it deliberately leaves PLANNED, exact executed tests and NOT RUN items. No automatic merge based on placeholder checks.
3. Start with Gate A from FIRST_VERTICAL_SLICE.md. Do not build monsters, crafting catalogs, mission varieties or final art before the physics/network boundary is demonstrated.
4. Keep networking attributes and Unity types outside Domain. Every state mutation must enter through a named command/solver phase. Avoid static mutable world singletons that survive scene reload.
5. Add diagnostics with each subsystem: IDs, revisions, grab lease, graph connectivity, authority tick, queue depth and state hashes. Debug visualization is more valuable now than polished content.
6. For each change, state IMPLEMENTED/PARTIAL/STUB/PLANNED, then testing status. Do not count a class named FireSystem as fire propagation. Include actual prefab/config wiring in the feature acceptance check.
7. Do not invent SDK APIs. Use documentation for the pinned version, compile, and retain errors. If the environment cannot run Unity, produce reviewable changes and label all Unity/runtime checks BLOCKED or NOT TESTED.
8. Package upgrades require a compatibility PR and targeted regression run. Keep the known-working version available. Avoid paid assets/cloud services unless their concrete need and cost are established.

## Steam/commercial integration checkpoint

Obtain the game's real App ID and Steamworks access before release-path validation. Development sample IDs are not proof of production entitlements. Define build/depot output, internal beta branch, clean-machine install, launch configuration, invites, reconnect and crash reporting. Upload from a protected build environment, not from a credential embedded in the game. Review Steam content disclosures against actual shipped material and preserve licenses for purchased and generated assets.

App IDs may be public identifiers; publishing credentials, Web API secrets and signing keys may not. Offline solo cannot depend on Steam services starting successfully. Shipping multiplayer platform availability and graceful failure messages require separate tests.

## Deliberately deferred

DOTS migration, custom physics engine, arbitrary CSG/voxels, full rigidbody player locomotion, large vehicle systems, host migration, infinite generation, live generative dialogue, arbitrary crafting, planetary physics, extensive monster roster and full nuclear operating procedures. Interfaces should leave reasonable extension points; do not implement empty frameworks for all deferred features.
