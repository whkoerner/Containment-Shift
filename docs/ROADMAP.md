# Incremental roadmap — statuses recorded 2026-10-08

| Checkpoint | Scope | Status |
|---|---|---|
| Phase 1A source | Unity folder, package/editor manifest, source-based scene generator, capsule motor, camera, gravity | IMPLEMENTED — UNVERIFIED |
| Phase 1A runnable | Unity compilation, generated scene saved, first-person movement confirmed in editor and Windows build | BLOCKED: requires installed Unity |
| Phase 1B source | Reusable raycast interaction, bounded rigidbody held object, drop/throw, hinged door, switch | IMPLEMENTED — UNVERIFIED |
| Phase 1B behavior | Actual reach/collision, prop contacts, input, responsive grab feel | NOT RUN |
| Gate A networking spike | FishNet release pin, host & 1/3 clients, authoritative held prop, door state, reconciliation, contested/disconnect tests | PLANNED |
| Phase 1D causal domain | Pump / pipe / valve / leak / warning, typed commands & finite resource invariants | DEFERRED until authority setup |
| First complete slice Gates B–D | One mission, destructible authored pieces, one creature, save/reconnect, Steam route and all crew sizes | PLANNED |

Next highest-priority task: in Unity 6000.3.25f1 import this branch, fix any concrete errors, run EditMode tests, generate and validate the graybox scene, then commit the generated scene+meta and build a Windows standalone. Only then implement FishNet Gate A.

