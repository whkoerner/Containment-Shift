# Technical risks and evidence register

Review: 2026-10-08. No gameplay implementation was inspected. The game repository became accessible on the user's follow-up and contained only its initial README. This document does not certify feasibility or compliance.

## Status vocabulary

- IMPLEMENTED: behavior exists in an identifiable artifact; attach its commit/path. This alone does not mean tested.
- PARTIAL: enumerate what works and what is missing.
- STUB: interface/placeholder without required behavior; never counts as feature completion.
- PLANNED: approved or proposed design only.
- NOT TESTED: no qualifying execution evidence. Pair with any implementation status as appropriate.
- BLOCKED: identify missing access, environment, dependency or decision and the next action.

Tests use PASS/FAIL/SKIPPED/NOT RUN and retain actual evidence. PASS requires execution of the named assertion in the stated configuration. A successful compiler exit is not a multiplayer test. A single editor window with fake clients is not multi-instance evidence.

## Highest risks

| Priority / risk | Early experiment and pass evidence | Stop or reduce scope if it fails |
|---|---|---|
| P0 — remote grabs feel worse than host | Gate A: measured latency, two real processes, then four; contested grab/throw/contact video and corrections | Stop content production; simplify prop collision/prediction; compare Fusion Host in isolated spike |
| P0 — prediction collides with destruction | Break collider while a remote player stands on/carries against it; verify revision barrier and recovery | Limit destruction during interactions until fixed; never mask disagreement visually |
| P0 — cascades become arbitrary or unstable | Counterfactual fixtures: healthy breaker, closed valve, disconnected vent, redundant pump; bounded mass/heat and causal log | Correct rules before adding hazards; obtain industrial/nuclear review for new models |
| P0 — architecture grows faster than a small team can finish | One mission works end-to-end with 1/2/3/4 players before expanding content | Cut vehicles, broad crafting, advanced nuclear systems and alternate bodies first |
| P1 — host CPU/network saturates during collapse | Profile reference host with scattered clients, active smoke/fire and burst destruction | Reduce gameplay chunk count/active bodies and room count; preserve facility causality |
| P1 — generated infrastructure is invalid | 1,000 seeds/profile plus in-engine clearance checks; saved failing seeds | Keep a smaller authored module grammar and known-valid fallback layouts |
| P1 — navigation cannot keep up | Breach, barricade, floor removal, overlapping rebuild requests | Prefer authored route/link transitions; defer arbitrary new walkable rubble |
| P1 — reconnect/save loses durable state | Reconnect after destruction, mid-repair and after death; save/load compares canonical state | Disable public join-in-progress until baseline correctness works; do not rely on RPC history |
| P1 — Steam works only locally | Different accounts/devices/networks; direct and relayed routes, invites and failure UX | BLOCK external release until resolved; local transport success is insufficient |
| P1 — solo is co-op with missing people | Human mission completion in solo, no simultaneous mandatory tasks; compare all crew sizes | Restructure objectives and travel/workload before monster tuning |
| P1 — content/version changes break saves | Versioned fixtures, content-hash rejection, migration and corruption recovery | Announce prototype incompatibility; do not silently load corrupt/unknown data |
| P1 — dependency terms/maintenance change | Pin source/version/license; clean checkout/build; review custom FishNet terms and adapter ownership | Swap or replace only the affected boundary; retain a minimal baseline build |
| P2 — visual body causes camera nausea/clipping | Stair/crouch/grab/death camera tests with comfort settings | Keep camera independent from physics animation; defer active ragdoll locomotion |
| P2 — horror/gore options change advantage unintentionally | Compare authoritative collision/exposure with every local presentation setting | Preserve cheap hazard cues and same body geometry; lobby-negotiate rule changes |
| P2 — scope explosion from devices/post-death/vehicles | Only one fixed repair tool and one security-camera embodiment in slice | Do not generalize into an arbitrary device language or multi-body catalog |

P0 means a failure threatens the core production plan; P1 blocks commercial readiness; P2 is bounded but must be tracked. Priorities are architectural judgments, not measured probabilities.

## Testing infrastructure from the first commit

Domain tests: graph invariants, mass/energy bounds, profile equivalence where intended, command idempotency, stable IDs, mission transitions, generation and save migration. Use deterministic fixtures and randomized property tests with recorded seeds. A mock networking adapter tests application contracts only; it cannot prove transport behavior.

Unity EditMode tests: definition validation, prefab IDs, missing references, layer matrix and authoring/import rules. PlayMode tests: grab constraints, damage transactions, nav invalidation, runtime views, scene teardown/reload. Standalone tests: the actual built executable with host/client launch arguments, unique output directories, explicit ready/connected handshake, assertions and timeout failure. Record all process IDs and peer identities to show independent connected instances.

CI gates should run domain tests, Unity compilation/EditMode, selected PlayMode and a two-process standalone smoke test when a licensed runner is available. Nightly or explicit pre-merge four-process tests cover packet impairment, join/reconnect and teardown. A graphics-capable Windows test station runs the representative rendering/performance cases; headless CI does not pass rendering or microphone tests. Steam end-to-end uses human-controlled test accounts and multiple machines.

If Unity licensing, native SDK or test-machine access is unavailable, label that job BLOCKED/NOT RUN. Do not replace it with an always-green shell script. Keep CI and Steam credentials in protected secret stores, exclude untrusted PRs from privileged jobs, and never commit build/upload credentials or private keys.

Each evidence record: UTC timestamp, commit, clean/dirty state, editor/package lock hashes, OS/hardware, build backend, test ID, seed/profile/crew size, impairment settings, expected outcome, actual outcome, exit code, logs and optional video/profiler artifact. Network records include connected-peer count and state-baseline equality at a synchronized tick. Compare quantized discrete state and tolerance-bounded continuous values appropriately; do not demand identical interpolated render positions.

Manual gates: first-person comfort, visual clipping, grab feel, industrial plausibility, readable emergency lighting/smoke, controller navigation, subtitles, reduced gore, reduced horror and non-color alarm cues. Record who tested and what failed; developer intuition alone does not pass usability.

## Current evidence ledger

| Item | Actual status in this review |
|---|---|
| Nine architecture Markdown files | IMPLEMENTED documentation; content/package checks described at delivery |
| Official documentation and release research | Completed research, dated 2026-10-08; URLs in relevant files |
| GitHub authentication/repository list | Verified whkoerner/Containment-Shift on follow-up; initial repository contained only README.md |
| GitHub publication | This documentation commit adds the package under docs/architecture; unrelated repositories untouched |
| Unity project, scenes, movement, networking or gameplay | PLANNED; no code compiled or run |
| Automated tests and multiplayer sessions | NOT TESTED / NOT RUN |
| Performance numbers | Proposed budgets only; NOT TESTED |
| Final engine/package compatibility lock | PLANNED; bootstrap/build gate required |

## Reopen decisions only on evidence

Do not migrate engines because one package failed; first isolate motor, transport, prediction and content costs. Do not adopt DOTS because the design mentions thousands of elements; profile the graph loops. Do not expand destruction because visual-only debris benchmarks well. Any changed decision records the failing test, considered alternatives, migration cost and accepted new gate.
