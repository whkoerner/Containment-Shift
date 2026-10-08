# Physics and destruction

Status: PLANNED; all interaction and destruction behavior NOT TESTED.

## Authority table

| Entity | Server truth | Client representation / conflict rule |
|---|---|---|
| Player | Locomotion capsule, accepted input, health, inventory | Predicted motor and immediate camera; reconcile; remote bodies interpolate |
| Movable prop | Rigidbody, collisions, damage, resting pose | Interpolated gameplay proxy; optional visual prediction; no client damage callbacks |
| Grabbed prop | Same server Rigidbody plus bounded grab constraint | Local hand/visual smoothing; holding never transfers state authority |
| Two simultaneous grabbers | Server arbitrates a lease by accepted tick, then stable player ID | Slice: one holder, second gets explicit rejection. Later: two bounded force contributions into one server solver, never two owners |
| Vehicle/tool cart | Chassis, seat occupancy, forces, contacts | Driver predicts input/visuals only initially; prediction is a separate later gate |
| Ragdoll | Death transition; simplified corpse collider/pose if gameplay-relevant | Local limbs cosmetic. If limbs can block/damage, they become capped authoritative bodies |
| Structural section | Support state, fracture state, collision replacement | Replicated authored variant; large falling pieces authoritative; dust/shards cosmetic |
| Door | Lock, power, integrity and traversal state | Slice uses motorized/kinematic angle. Later physical hinges still server-owned |
| Machinery | Domain state and valid controls | Gauge/animation binding; interaction requests never directly mutate the machine |
| Monster | AI, path decisions, locomotion, attack timing and damage | Smoothed pose/animation; no client AI decisions |

An input lease includes holder, target, revision and expiry. Release on timeout, disconnect, death, loss of reach, teleport or scene unload. Clamp hand distance, velocity, force, torque and mass eligibility. Sweep held-object movement against geometry; never drag by assigning an unchecked transform. Grab/release/throw transitions acknowledge the accepted revision. Throw derives from bounded server-known motion; clients cannot request arbitrary impulse.

Avoid reciprocal player/prop instability: use a predictable capsule motor, capped server push impulses and a clear policy for standing on moving objects. Do not begin with fully physical active-ragdoll locomotion. Throwing a prop into another held prop and grabbing during a collapse are mandatory adversarial tests.

## Visible body and later third person

Separate PlayerIdentity, Embodiment, Motor, Interactor, VisualRig and CameraRig. One world-space body carries remote animation, injuries and shadow. The local rig can hide the head for camera clipping without hiding it for other players; arms/body pose follow the same accepted actions. Camera bob and IK cannot determine the authoritative interaction origin. Use a validated head/hand socket and reach test, with camera aim only as bounded intent.

Third person can later reuse this representation: add collision-aware camera placement and aiming/animation rules. It is not automatically fair or polished; it exposes corners and may change horror. Make camera mode a lobby policy if that matters. Do not implement it in the first slice, but prohibit first-person camera transforms from becoming the source of damage or reach authority.

## Hybrid destruction contract

Use authored damageable modules with a finite fracture library, not arbitrary runtime CSG/voxel carving. Compare alternatives:

| Method | Use | Boundary |
|---|---|---|
| Authored intact/damaged/breached variants | Walls, doors, windows, machinery | Predictable topology, replication and art cost; primary method |
| Prefractured chunks | Selected columns, floors, slabs, larger props | A few gameplay pieces; most fragments visual-only |
| Structural support graph | Decide when supported sections fail | Load-path approximation, not finite-element engineering |
| Runtime fracture/CSG | Possible later special tool | Requires collider, interior surface, navigation, persistence and network proofs before adoption |
| Whole-world voxels | None in current scope | Changes the entire rendering/physics/content problem; explicitly excluded |

Every module declares stable section IDs, material/damage response, break thresholds, attachment/utility ports, support edges, fracture variant IDs, simplified collision shapes and navigation consequences. Damage progresses Intact → Damaged → Breached/Detached → Settled. Repairs may patch equipment or seal a leak; they do not regenerate a missing concrete wall unless an explicit build mechanic is implemented.

Structural approximation: anchors support a directed, authored support graph with capacities and load contributions. Recompute dirty connected components; disconnected sections lose support, overloaded edges accumulate failure over bounded time. Reject unsupported cycles during authoring. Avoid per-brick stress solvers. Preserve a failing/pending-collapse state while processing queues: queued failures must not secretly remain safe because the frame budget is exhausted.

## Destruction transaction

At a server tick boundary, validate damage → choose stable fracture outcome → commit section revision and severed utility/support edges → replace authoritative colliders → update zone portals and navigation availability → spawn bounded large pieces → emit cosmetic effect event. All changes share a transaction ID and topology revision. Idempotent application prevents duplicate fragments and repeated damage.

Clients apply topology before rendering interpolation into the new geometry. Old snapshots cannot restore intact collision. If a predicted motor crosses a changing collider, clear incompatible prediction history and reconcile using the new topology revision. A navmesh rebuild may be deferred; collision and temporary no-go volumes must be correct immediately.

Settled gameplay rubble retains a simplified authoritative collider and saved pose. Merge or demote only pieces whose loss cannot change cover, traversal, damage or interaction; never delete a player-made barricade merely because it is distant. Publish the demotion/replacement revision. Falling pieces have capped contact damage, one-hit cooldowns and validated collision layers.

Cosmetic fragments cannot damage, block doors, occlude authoritative AI vision, carry items or provide walkable footholds. Their visual seeds may match while trajectories differ. Use local pools, distance/age culling and disabled gameplay collision. If a player must pick up a fragment, it must be an authoritative salvage entity from spawn, not a client-only shard promoted opportunistically.

## Minimum proof

Break a window; breach a wall to create a route; destroy a door; remove one support to drop one slab. Test four players observing from different rooms, a client reconnecting afterward, saving/reloading, and a creature replanning. Repeat with one player under/holding a piece. Confirm that no invisible intact collider remains and that cosmetic debris never determines survival.

All algorithms here are proposed project design. Engine/network physics capabilities are sourced in ARCHITECTURE_DECISION.md and NETWORKING_ARCHITECTURE.md; none of those capabilities establishes that this particular hybrid works yet.
