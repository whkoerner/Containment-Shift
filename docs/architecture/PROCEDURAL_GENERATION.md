# Procedural generation and navigation

Status: PLANNED; generator, seed validation and dynamic navigation NOT TESTED.

## Generate a facility specification before placing rooms

Use constrained modular generation with authored landmarks. A seed selects a bounded layout, equipment arrangement, maintenance history and permissible starting faults. Recognizable control rooms, pump halls and evacuation landmarks anchor orientation. Replayability should come from infrastructure choices and failures, not indistinguishable corridors or random hazards without a source.

1. Build a mission dependency graph: required equipment, controls, access, extraction, solo feasibility and optional routes.
2. Allocate functional zones and adjacency: noisy plant spaces, control spaces, utilities, service corridors, containment boundaries and elevation constraints.
3. Embed the room graph using a small module library on a constrained grid. Reserve stairs, utility shafts, corridors, structural supports and maintenance clearance. Reject intersections and inaccessible controls.
4. Route typed infrastructure through reserved trays/shafts/ports. Electrical, supply/return coolant, drains and ventilation remain separate graphs. Require compatible media, capacity, direction, elevation and endpoints; visible pipes must correspond to real graph edges or be explicitly nonfunctional scenery.
5. Place supports and authored destruction masks. Mark protected boundaries and planned breach opportunities. A breach declares what it opens, severs and destabilizes.
6. Place equipment and only then sample source-compatible faults. Degraded protection, combustible materials and leakage paths explain a cascade. Store all chosen faults in the manifest.
7. Validate objective reachability and utility availability under the intended baseline; simulate a short warm-up; check there is no unexplained instantaneous failure.
8. Build navigation/visibility zones, emit immutable manifest and checksum; only then instantiate scene views.

Use scoped PRNG streams for layout, equipment, faults and cosmetics so adding a decorative prop does not reroll the plant. Do not derive stable IDs from runtime hierarchy ordering. Suggested ID inputs: run namespace + module instance ID + authored local entity ID; dynamic spawns use a server monotonic ID allocator. Detect collisions, do not assume a hash cannot collide.

## Connectivity validation is not a single flood fill

| Check | Failure caught |
|---|---|
| Human navigation graph and clearance volumes | Reachable room but unreachable valve; insufficient width/height |
| Equipment service access | Breaker behind a fixed cabinet; no tool approach |
| Supply and return paths, inventories, pressure limits | A pump connected to decorative dead-end plumbing |
| Power source, consumer capacity, protection domains | Emergency equipment on a bus that cannot power it |
| Vent route, fan direction, damper and boundary state | Smoke crossing a sealed wall or fan pushing through no duct |
| Structural anchoring and selected collapse outcomes | Floating floors or unbounded collapse of the entire map |
| Mission state graph with tools/capabilities | Solo requires simultaneous remote actions; repair part locked behind its own broken door |
| Hazard source tags and starting balance | Gas rupture in a room with no gas installation |

Provide editor overlays for every graph and a readable rejection reason with seed and module IDs. Bound generation attempts: e.g. 20 attempts, then select a known-valid fallback manifest and report it in diagnostics. Never loop forever or hide failures by quietly disconnecting utilities.

Only a small failure-scenario set is validated initially. It is impossible to guarantee mission success after every intentional demolition; distinguish an unfair initial softlock from a player-caused failure. Provide visible failure/extraction resolution when required equipment becomes irrecoverable. Destructibility is an explicit contract, not a hidden promise that every wall is breakable.

## Host manifest and reproducibility

The host generates the manifest. Clients can reconstruct modules from it; seed regeneration is an optimization only, and hash disagreement triggers manifest use or an explicit content mismatch error. Never let each client independently choose fracture variants, random faults or module replacements. Save the manifest along with versions, not only the seed.

The slice has one 6–8-room facility kit, two fixed landmarks and three constrained layouts. Three authored layouts are acceptable for the first networking gate; the slice is complete only after bounded generation and property checks work. Later variety can extend the grammar without changing IDs or connectivity contracts.

## Navigation under destruction

Use Unity AI Navigation for local surfaces and links plus a project-owned high-level room/portal graph. The official package supports edit/runtime navmeshes, obstacles and links [1]. That does not mean it rebuilds arbitrary destruction for us.

- Prebake module interiors where geometry is stable, then connect compatible door/stair portals after placement.
- Doors and preauthored breach openings toggle navigation links/traversal conditions. Links alone are sufficient only if both sides already have valid walkable surfaces.
- A collapsed floor immediately disables affected portals and marks a no-go volume. If it creates genuinely new walkable geometry, queue a bounded local surface rebuild from simplified collision meshes.
- Moving props use local avoidance and physics sweeps. Settled large barricades may carve obstacles; do not re-carve every frame for every bottle.
- Coalesce dirty regions, limit rebuild work, and associate results with topology revisions. Discard a completed bake if the underlying topology changed again. While pending, AI waits or finds a known-safe route rather than trusting stale polygons.
- Keep AI/path decisions server-only. Clients need poses and animation, not identical navmesh computation.

Start with one creature radius/height and one locomotion family. Use a small state machine: patrol, investigate, pursue, attack, recover. Perception reads authoritative smoke, line-of-sight geometry and sound events. Plan at staggered intervals; immediate invalidation on destroyed path segments. Detect lack of progress; replan, interact with an allowed door, or abandon pursuit—never teleport through rubble as the generic recovery.

An isolated creature can stay isolated if destruction explains it. Later crawling/flying creatures use additional traversal graphs and explicit capabilities, not hacks to one universal navmesh.

## Required generator/navigation tests

Run 1,000 deterministic seeds for each implemented difficulty/crew profile in pure-data validation. Persist failures and reduced repro cases. This is a planned test count, not evidence of execution. Load at least 20 selected seeds in real Unity scenes to validate colliders, path clearance and representation consistency. Include narrow halls, adjacent fire doors, an upper floor, failed routing and maximum destruction.

On each representative layout, breach an alternate route, block the original with a large prop and remove a walkable floor. The creature must use a valid route or report no route. Record rebuild times, stale-path usage and time to revised path. Target ≤1 second for a small local navigation change; immediate danger blocking is required regardless of bake duration.

[1] https://docs.unity3d.com/Packages/com.unity.ai.navigation@2.0/manual/index.html — checked 2026-10-08; exact compatible package patch must be resolved with Unity 6.3.
