# Missing validation / blockers (2026-10-08)

- BLOCKED: Unity 6000.3.25f1 not installed/available in execution environment; no actual Editor import.
- NOT RUN: package resolution/lock, scene serialization, actual C# compilation, Editor or player runtime, local input + gravity + physics, real UI.
- NOT RUN: NUnit EditMode tests (authored, not executed), PlayMode tests (not authored), Windows build / IL2CPP, prefab/scene references and console scan.
- NOT RUN: URP renderer asset configuration (dependency in manifest only). No final pipeline settings/quality validation.
- PLANNED: FishNet installation/pin/license review, transport, networked player ownership, host/client session startup, networked grab, world state, 4-process physics tests and Steam connectivity.
- NOT RUN: multiplayer authority, simultaneous grab race, disconnect/reconnect, jitter/loss/delay, late join, save/load, performance.
- PLANNED: pure C# facility graph and causal cooling chain after Gate A.
- NOTE: The generated scene is NOT checked into this branch until Unity creates and validates it. README explicitly describes generation.

