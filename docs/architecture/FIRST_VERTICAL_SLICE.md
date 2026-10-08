# First vertical slice — prove the dangerous assumptions

Status: PLANNED. All gates below are NOT RUN / NOT TESTED. This is an implementation acceptance contract, not a report of working gameplay.

## The playable slice

One small aging pump/research annex, 6–8 connected rooms, two recognizable landmarks, one upper platform, and three valid constrained layouts using the same modules. Target a 10–15 minute mission after onboarding. Final art, broad crafting and a reactor simulation are excluded.

Objective: stabilize an overheating experimental heat-load unit, restore an extraction control and leave. Players can isolate the damaged coolant branch, use one fixed repair tool, restore safe electrical service and restart cooling. A degraded protection device enables the bad branch of the cascade. Several valid action orders should succeed; reckless actions can make the facility unrecoverable. Irrecoverable objectives produce an explicit failure/extraction decision, not endless waiting.

Mission chain: Lobby → Loading/Manifest → Ready → Active → Extraction or Failed → Results → Lobby. Host decides transitions and rewards once. Offline solo follows the same chain without online login. Results explain the principal causal chain from the incident log.

## Slice contents and completion evidence

| Required feature | Bounded implementation | Evidence required |
|---|---|---|
| Solo/2/3/4 players | Same authority/domain path | Actual completed sessions at every count; four independent processes connect |
| Movement/body | Capsule motor, visible body, remote animation | Stairs/crouch/reach/camera clipping and reconciliation video |
| Grabbing/props | 12–24 normal movable props, stress pool up to budget | Remote grab/throw/drag/push, contested grabs, disconnect release |
| Destruction | One wall breach, door, window, support and falling slab | Same collision/traversal state on all peers and reconnect |
| Pipe/leak | One loop with inventory, pump, valve and damaged branch | Isolating valve changes real flow/leak state |
| Electricity | Breaker, exposed fault site, protected/degraded variants | Wet energized fault differs from safe/de-energized fixture |
| Fire/smoke | One cable fire, adjacent air zones, fan/damper | Spread follows connections; closed damper changes outcome |
| Repair | One tool and consumable patch | Server validates proximity/tool/state; duplicate requests consume once |
| Cascade | Leak → cooling loss/wet fault → outage/fire → smoke/door changes; optional slab collapse | Causal log and counterfactual tests, not a pre-timed cutscene |
| Creature | One server-owned patrol/investigate/pursue/attack creature | Replans after breach and handles blocked path without teleporting |
| Death | One authoritative lethal condition plus creature attack | Health/death/result agree for host and clients |
| Post-death | One fixed security-camera embodiment | Dead player switches powered cameras and requests one legal alarm/control action through capability checks |
| Mission/results | One success and one failure path | Both reach results and restart without leaked session state |
| Generation | Small grammar, three recognizable variants | Connectivity/property tests plus in-engine clearance/navigation |
| Persistence | Save/load damaged world and reset to one checkpoint | Snapshot comparison; stale old-epoch input rejected |
| Online seam | Steam two-device link and four-account final validation; basic proximity voice | Real connection/route/audio evidence, independent of local tests |

The camera embodiment is a prototype of interactive death, not every cause-specific body. Death-cause mapping can be data-driven but only one outcome is implemented. Solo death ends the run and opens the incident timeline. In co-op, camera access is limited by power and capabilities; it cannot instantly repair equipment or replace all live-player tasks. Decide all-live-players-dead behavior explicitly: fail after a short final-state grace period; camera ghosts cannot keep a hopeless run alive indefinitely.

## Gate A — network physics before content

Build one grey room, a visible-body capsule motor, 12 props, grabbing, a door and authoritative state diagnostics. Start FishNet on the selected Unity 6.3 patch. Run host + one remote process, then host + three remote processes. Compile a standalone Windows build and later its IL2CPP variant. No full facility yet.

Test profiles, configured and measured: LAN baseline; 100 ms RTT / 20 ms jitter / 1% random loss; 200 ms RTT / 40 ms jitter / 3% loss; then a short 500 ms delivery stall. State whether jitter is one-way or RTT in the harness; here use one-way delay variation and verify observed RTT. Apply impairments independently per client, not one global fake ping.

Test walk/crouch/steps, grab/release/throw 100 times, two clients requesting one object on the same tick, prop stacks, contact with another held prop, disconnect while holding and respawn/reconnect. Use reliable command IDs and state assertions, not visual inspection alone.

Proposed acceptance: zero duplicate holders/inventory changes and no permanently divergent collision states; under the 100 ms profile, p95 local player reconciliation distance <0.15 m and no unexplained correction >0.5 m during ordinary walking. Exclude intentional teleports but log them. Held-object correction/latency is recorded separately: no persistent oscillation after release, no repeated wall tunneling and both testers rate basic manipulation usable. These targets may be revised from evidence before production, never silently loosened to mark a failure green.

At 200 ms, temporary visual disagreement is expected; the requirement is bounded recovery, useful feedback and no broken mission state. No visible local action may cause authoritative damage twice. A 500 ms stall must recover or disconnect clearly, not leave a permanent grab lease.

Timebox the **decision** to roughly five focused engineering days, not a guarantee of completion. If FishNet's supported approach cannot satisfy core feel and performance, build the same minimal scene in a separate Fusion Host 2.1 spike and compare measured corrections, CPU and implementation burden. No package shopping without a reproducible failure. Freeze the chosen stack only after this gate.

## Gate B — one causal chain plus destruction

Add the pipe/pump/valve, a wet electrical fault, one fire, two smoke zones, emergency door state and the authored wall/slab transaction. Domain fixtures must distinguish healthy protections, empty pipe, isolated branch, closed damper and failed redundancy. Add one repair interaction. Test cause/state replication, reconnect and save/load before making a prettier facility.

Pass when at least two different player interventions change the chain for valid reasons; duplicate/out-of-order network messages cannot repeat damage or resources; reconnect reproduces destroyed geometry and current hazards. Destroy a collider during predicted movement, invalidate its history and show recovery. Unit tests alone do not pass this gate.

## Gate C — mission, death and all crew sizes

Build the annex from the small module kit; add the one creature, objective state machine, death/camera embodiment and incident results. Implement Intern and Standard using the same schemas. Human testers complete success and failure cases with 1, 2, 3 and 4 players; no mandatory simultaneous interaction excludes solo. Record task times, idle periods, repeated confusion and number of unrecoverable softlocks.

Require three complete sessions at each crew size across the supported slice profiles, plus a 30-minute four-player stress soak. This is a minimum evidence sample, not statistical proof of balance. Have players split rooms so interest management cannot hide distant simulation faults. Run lobby→mission→results→lobby repeatedly and inspect leaked objects, audio sessions and handlers.

## Gate D — generation, recovery, performance and Steam

Run the 1,000-seed-per-profile data suite and 20 in-engine representative layouts described in PROCEDURAL_GENERATION.md. Profile the worst slice state against PERFORMANCE_BUDGETS.md on actual reference hardware. Test save interruption/corruption recovery, mismatched content rejection, reconnection after death and destruction, and checkpoint reset with delayed old packets.

Run separate Steam accounts/devices on different networks. Two-player online proof comes early in this gate; completion requires a real four-account session with invites, disconnect, voice mute/PTT and a mission result. Network path evidence must distinguish direct/relay; a localhost harness is not NAT validation. Test offline solo with Steam unavailable and controller menu/gameplay completion before declaring either supported.

## Cross-cutting automated assertions

- Every run transition and reward is idempotent by run/epoch/result ID.
- World baseline at the same authoritative tick contains the same entity IDs, revisions, discrete states and quantized continuous state; rendered interpolation is excluded.
- Repairs require resources and consume once; stopped pumps do not create flow; broken edges cannot carry their intact capacity.
- A closed air path prevents that path's smoke transfer; cosmetic quality does not change exposure.
- No client callback can commit damage or spawn authoritative salvage.
- All death/leave paths release leases and do not duplicate embodiment on reconnect.
- A newer topology revision cannot be overwritten by an older snapshot/nav bake.
- Generation and saves reject malformed IDs, invalid graph connections, oversized payloads and unknown incompatible versions with actionable errors.

## Evidence and go/no-go

Every gate stores its build, commit, package/editor pins, process/peer count, seeds, logs, measured metrics and manual findings using TECHNICAL_RISKS.md. An unavailable test environment is BLOCKED; unexecuted tests remain NOT RUN. The architecture review itself passes none of these gameplay gates.

**Go to limited production only when A–D are evidenced, a remote player finds interactions usable, solo is enjoyable enough to repeat, and a collapse fits measured host/network budgets.** If the chain is technically correct but unreadable or unfun, iterate the same mission before producing content. If it requires whole-world rollback, pervasive per-fragment replication or repeated complete navmesh rebuilds, reduce interaction/destruction scope or reopen the relevant architecture decision.

Do not add more monsters, biomes, vehicles, replacement bodies, nuclear systems or Engineer/Extreme tiers to rescue an unproven foundation. The deliverable is one small complete game loop that survives real remote players and destructive behavior.
