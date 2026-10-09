# PROJECT EXECUTION PLAN — Containment Shift

**Canonical development roadmap • October 8, 2026 • branch `feat/phase1a-graybox-foundation` (draft PR #1).**

## Product, scope and source of truth
The facility is the systemic threat in a **solo-viable, 1–4-player** PC cooperative industrial-disaster/horror/physics-comedy game. A controllable, understandable cascading failure is more important than a broad list of monsters or detailed reactor simulation. Machinery/horror assistance profiles, real physical interaction, replayability and reliable remote play are product pillars.

This file is the **one authoritative ordered task catalog**. [CURRENT_TASKS.md](CURRENT_TASKS.md) selects CURRENT/NEXT/BLOCKED; [NEXT_SESSION.md](NEXT_SESSION.md) provides the copyable engineering handoff. [ROADMAP.md](ROADMAP.md) is an index only. The nine design reviews in [architecture/](architecture/) govern boundaries and vertical-slice gates. In particular, [FIRST_VERTICAL_SLICE.md](architecture/FIRST_VERTICAL_SLICE.md) requires an observed 1/2/3/4-player mission, not marketing screenshots.

**Statuses**: PLANNED = not started; IN PROGRESS = actively in flight; PARTIAL = some subrequirements exist; IMPLEMENTED — UNVERIFIED = code/content authored but required runtime test absent; TESTED = explicitly named acceptance test actually executed, with [TEST_RESULTS.md](TEST_RESULTS.md) evidence; BLOCKED = work needs outside prerequisite; DEFERRED = intentionally postponed. For a mixed task, do not label TESTED until its stated acceptance test passes. CI static passes never imply Unity compilation. All tasks are scoped to one or more game pillars.

**Dependency and gate rule**: tackle only the next ready ID, keep changes in a draft PR until Unity import and standalone proof, and record evidence per gate. Source creation, a scene generator, or a test method *existing* does not pass a runnable gate. UnityProject/ is the project root. No network SDK is installed. FishNet 4.7.3R is a provisional evaluation candidate only, not a verified production dependency.

**Milestones**: P00 foundation → P01-M01 import/scene/build → P01-M02 local interaction checkpoint → P01-M03 networking Gate A → P01-M04 first connected facility mechanism → P02 authoritative physics → P03 causal disasters → P04 playable mission → P05 generation → P06 identity → P07 shipping quality → P08 Steam release. Gate order can be revised by a dated entry in DECISIONS.md when real test evidence justifies it. The vertical slice described by Astra spans several phases; it is not accomplished by Phase 1 alone.

**Task fields** below specify the *observable expected result*, actual implementation boundaries, exact proof and what failing would look like. A task whose prerequisite is blocked remains untested even if source is pre-authored.

## PHASE 0 — Architecture and repository foundation

**Phase exit goal:** Game direction, repository provenance, automation and development policies.

### P00-M01-T01 — GitHub and architecture review
- **Objective:** GitHub and architecture review.
- **Player-visible result:** An agreed bounded 1–4-player industrial facility game direction is documented.
- **Technical implementation:** Audit the repository and preserve all nine Astra decisions.
- **Dependencies:** Repository access.
- **Acceptance criteria:** Repository/main, architecture files and PR state are discoverable.
- **Testing and evidence:** GitHub API readback and branch/review inventory. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Missing files or inaccessible repository.
- **Status:** TESTED | **Priority:** Critical
- **Next task:** P00-M02-T01

### P00-M02-T01 — Authoritative execution tracker
- **Objective:** Authoritative execution tracker.
- **Player-visible result:** An engineer can locate the next measurable checkpoint without prior chats.
- **Technical implementation:** Single execution plan, task board, handoff, AGENTS/README pointers.
- **Dependencies:** P00-M01-T01.
- **Acceptance criteria:** Stable task IDs, explicit gates, statuses and no contradictory secondary roadmap.
- **Testing and evidence:** Readback of all docs in branch after push. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Missing acceptance criteria or links.
- **Status:** IN PROGRESS | **Priority:** Critical
- **Next task:** P00-M02-T02

### P00-M02-T02 — Baseline static repository CI
- **Objective:** Baseline static repository CI.
- **Player-visible result:** Malformed manifest, missing metadata and broken local references fail a dedicated CI job.
- **Technical implementation:** Versioned Python stdlib validator and GitHub Actions workflow, explicitly scoped to static checks.
- **Dependencies:** Repo and Unity text assets.
- **Acceptance criteria:** On push/PR, validator exits nonzero on a broken fixture and zero on valid tree; no Unity-pass claim.
- **Testing and evidence:** Execute local self-test/fixture and inspect actual workflow run when available. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Action shows green without running assertions.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P01-M01-T01

### P00-M03-T01 — Dependency/licensing ledger
- **Objective:** Dependency/licensing ledger.
- **Player-visible result:** Third-party components are auditable before commercial use.
- **Technical implementation:** Record package pin, URL, license and update policy; do not install unproved SDKs.
- **Dependencies:** Repository and design docs.
- **Acceptance criteria:** Unity and networking candidates identified; actual resolved versions tagged only after Editor import.
- **Testing and evidence:** Inspect package lock and legal provenance against vendor release. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Unpinned active dependency or invented license conclusion.
- **Status:** PARTIAL | **Priority:** High
- **Next task:** P01-M01-T01

## PHASE 1 — First playable foundation

**Phase exit goal:** A real Windows-playable industrial graybox, then incrementally proven networking.

### P01-M01-T01 — Import and compile Unity project
- **Objective:** Import and compile Unity project.
- **Player-visible result:** Opening UnityProject produces no compiler errors and project loads.
- **Technical implementation:** Unity 6000.3.25f1; resolve Input System/URP/Test Framework; correct asmdef references and Player Settings.
- **Dependencies:** P00-M02-T01; installed Unity Editor.
- **Acceptance criteria:** Clean Editor import, zero C# errors, package versions resolved and saved as lock file.
- **Testing and evidence:** Open clean checkout; capture Console, Package Manager and Editor.log. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Compile error, missing package or skipped actual import.
- **Status:** BLOCKED | **Priority:** Critical
- **Next task:** P01-M01-T02

### P01-M01-T02 — Verify editor tooling and scene generation
- **Objective:** Verify editor tooling and scene generation.
- **Player-visible result:** An industrial graybox appears with one menu command.
- **Technical implementation:** Test Phase1SceneGenerator, folder creation, saved scene, stable build-scene registration, non-overwrite behavior.
- **Dependencies:** P01-M01-T01.
- **Acceptance criteria:** Editor creates saved Phase1Graybox.unity with valid serialized references and registered build scene.
- **Testing and evidence:** Run generator twice; inspect Scene view and serialized files; reopen Editor. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Unsaved/missing scene, overwritten content, or build-scene list absent.
- **Status:** IMPLEMENTED — UNVERIFIED | **Priority:** Critical
- **Next task:** P01-M01-T03

### P01-M01-T03 — Confirm lighting/render pipeline
- **Objective:** Confirm lighting/render pipeline.
- **Player-visible result:** Working industrial lighting renders without pink materials or missing shaders.
- **Technical implementation:** Validate built-in graybox fallback or configure URP pipeline/renderer assets consistently, record decision.
- **Dependencies:** P01-M01-T02.
- **Acceptance criteria:** Both rooms render, warning light toggles, and chosen active render pipeline is explicit.
- **Testing and evidence:** Editor Play and built Player visual smoke. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Black room, missing pipeline/shaders, invisible props.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P01-M01-T04

### P01-M01-T04 — Build and fresh-install smoke test
- **Objective:** Build and fresh-install smoke test.
- **Player-visible result:** Windows executable launches the same graybox without Editor.
- **Technical implementation:** Set Build Profile scene inclusion and Windows x64 build modules, build from clean checkout.
- **Dependencies:** P01-M01-T02 and P01-M01-T03.
- **Acceptance criteria:** Standalone boots with view, movement and interactable props; logs show no fatal errors.
- **Testing and evidence:** Run actual .exe independently after Editor restart, capture output log. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Editor works but build fails/crashes/scene missing.
- **Status:** BLOCKED | **Priority:** Critical
- **Next task:** P01-M02-T01

### P01-M02-T01 — Movement and camera validation
- **Objective:** Movement and camera validation.
- **Player-visible result:** Player walks, jumps and looks comfortably without leaving world.
- **Technical implementation:** Verify CharacterController contact, gravity, delta time, mouse lock and first-person body clipping.
- **Dependencies:** P01-M01-T02.
- **Acceptance criteria:** WASD/Space/Esc/mouse work; collision blocks walls; no spontaneous sinking or clipping.
- **Testing and evidence:** Play both Editor and standalone; record movement and camera cases. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Passes through wall, inputs stop, view obscured or uncontrollable.
- **Status:** IMPLEMENTED — UNVERIFIED | **Priority:** Critical
- **Next task:** P01-M02-T02

### P01-M02-T02 — Reusable grab, switch and door
- **Objective:** Reusable grab, switch and door.
- **Player-visible result:** Player can identify and operate machines and physical objects.
- **Technical implementation:** Raycast prompts; reach/mass rule; velocity-based hold; drop/throw; hinge door; switch light.
- **Dependencies:** P01-M02-T01.
- **Acceptance criteria:** 12 props can be lifted/released; switch flips light; door opens/closes; blocked or distant target cannot be grabbed.
- **Testing and evidence:** Record physical contacts, stacks, reach, mass limits, door passage and target prompts. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Prop teleports unchecked, door blocked, switch unreachable, interaction through solid wall.
- **Status:** IMPLEMENTED — UNVERIFIED | **Priority:** Critical
- **Next task:** P01-M02-T03

### P01-M02-T03 — EditMode rule verification
- **Objective:** EditMode rule verification.
- **Player-visible result:** Invalid pickup requests reliably fail the four initial assertions.
- **Technical implementation:** Run NUnit InteractionRulesTests and document exact run.
- **Dependencies:** P01-M01-T01.
- **Acceptance criteria:** All four existing tests PASS with real Unity Test Runner log and version.
- **Testing and evidence:** Window > General > Test Runner > EditMode; retain result artifact. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Tests exist but are not actually executed or any fail.
- **Status:** BLOCKED | **Priority:** High
- **Next task:** P01-M02-T04

### P01-M02-T04 — Local prototype checkpoint
- **Objective:** Local prototype checkpoint.
- **Player-visible result:** Someone can play a two-room sandbox from clean source.
- **Technical implementation:** Commit generated scene/.meta/build settings/lock; smoke test from fresh clone.
- **Dependencies:** P01-M01-T04; P01-M02-T01..03.
- **Acceptance criteria:** Fresh checkout builds and player completes grab, throw, open, toggle and collision checklist.
- **Testing and evidence:** Reclone; open/build/run, record SHA and all smoke observations. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Missing generated assets, only works in author's cached Library.
- **Status:** BLOCKED | **Priority:** Critical
- **Next task:** P01-M03-T01

### P01-M03-T01 — Select/install one FishNet release
- **Objective:** Select/install one FishNet release.
- **Player-visible result:** Transport/bootstrap assembly compiles without affecting solo prototype.
- **Technical implementation:** Verify 4.7.3R license and exact immutable artifact, install only FishNet and transport.
- **Dependencies:** P01-M02-T04.
- **Acceptance criteria:** Networking package imports with no C# errors; dependency license/provenance recorded.
- **Testing and evidence:** Clean Unity import; inspect exact package source and license. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Second competing SDK, floating pin or compile failure.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P01-M03-T02

### P01-M03-T02 — Local host authority boot
- **Objective:** Local host authority boot.
- **Player-visible result:** Host starts one server-owned session with one player.
- **Technical implementation:** Session/bootstrap scene, spawn registry and host lifecycle APIs.
- **Dependencies:** P01-M03-T01.
- **Acceptance criteria:** Host starts; one authoritative player created exactly once; stop/restart cleans up.
- **Testing and evidence:** Standalone host process logs and scene teardown. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Duplicate player, orphaned session or no server listener.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P01-M03-T03

### P01-M03-T03 — Connect independent remote client
- **Objective:** Connect independent remote client.
- **Player-visible result:** Two separate processes occupy the same world.
- **Technical implementation:** Client transport, connection handshake, scene synchronization.
- **Dependencies:** P01-M03-T02.
- **Acceptance criteria:** Two running processes; host reports two peers; both load identical graybox.
- **Testing and evidence:** Run host+client simultaneously and capture process IDs/peer logs. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Local mock client only, failed join, incorrect scene.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P01-M03-T04

### P01-M03-T04 — Spawn two independently controlled avatars
- **Objective:** Spawn two independently controlled avatars.
- **Player-visible result:** Each human moves only their own player and sees the other.
- **Technical implementation:** Authority-bound player input and identity mapping; disable local input on remote proxies.
- **Dependencies:** P01-M03-T03.
- **Acceptance criteria:** Host and client move independently; no duplicate input or player objects.
- **Testing and evidence:** Two-process WASD/jump test with observed remote state. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Client controls host avatar or duplicated bodies.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P01-M03-T05

### P01-M03-T05 — Movement synchronization baseline
- **Objective:** Movement synchronization baseline.
- **Player-visible result:** Both players observe smooth bounded remote movement.
- **Technical implementation:** Authoritative motor snapshots, identity/sequence and interpolation; measure divergence.
- **Dependencies:** P01-M03-T04.
- **Acceptance criteria:** Each screen tracks both avatars; recorded update rate and correction behavior.
- **Testing and evidence:** Two-process movement test with video/logs and latency data. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Snapshots missing, escalating positional divergence.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P01-M03-T06

### P01-M03-T06 — Synchronize one door
- **Objective:** Synchronize one door.
- **Player-visible result:** Either participant sees the same authoritative state.
- **Technical implementation:** Door interaction request, range/line-of-sight validation, server revision and replicated state.
- **Dependencies:** P01-M03-T05.
- **Acceptance criteria:** Opening/closing from either process changes one door on both; late state catches up.
- **Testing and evidence:** Compare door state/revision in two process logs. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Local-only toggle, double-toggle, no validation.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P01-M03-T07

### P01-M03-T07 — Network one grabbable
- **Objective:** Network one grabbable.
- **Player-visible result:** One prop is held/moved/released consistently for all players.
- **Technical implementation:** Server Rigidbody, holder lease, held motion constraints, snapshot replication.
- **Dependencies:** P01-M03-T06.
- **Acceptance criteria:** Either player grabs/throws and both clients see the same state after settle.
- **Testing and evidence:** Host/client grab and physics contact, server state logs. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Client controls authoritative body or prop diverges.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P01-M03-T08

### P01-M03-T08 — Contested simultaneous requests
- **Objective:** Contested simultaneous requests.
- **Player-visible result:** One winner and one clean rejection on a shared prop.
- **Technical implementation:** Server arbitration by tick/stable player ID and lease revision.
- **Dependencies:** P01-M03-T07.
- **Acceptance criteria:** Concurrent grabs yield exactly one holder and explicit rejection; no duplication.
- **Testing and evidence:** Two clients grab same item in same window; assert lease invariants. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Two holders, disappearing item, indefinite lock.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P01-M03-T09

### P01-M03-T09 — Disconnect and reconnect
- **Objective:** Disconnect and reconnect.
- **Player-visible result:** Leaving a session releases prop and never duplicates characters.
- **Technical implementation:** Timed lease expiry, player teardown, join baseline, connection cleanup.
- **Dependencies:** P01-M03-T08.
- **Acceptance criteria:** Drop a holding client; prop releases; reconnect produces one avatar and correct door/prop state.
- **Testing and evidence:** Terminate/rejoin client process; count peers/entities and compare revisions. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Ghost lease, duplicated player, stale door state.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P01-M03-T10

### P01-M03-T10 — Host plus three remote clients
- **Objective:** Host plus three remote clients.
- **Player-visible result:** Four independent participants see and affect one consistent room.
- **Technical implementation:** Connection capacity and snapshot/performance diagnostics.
- **Dependencies:** P01-M03-T09.
- **Acceptance criteria:** Host+3 real client processes, four unique avatars, shared door and prop consistent.
- **Testing and evidence:** Four executable instances with process and peer logs. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Four simulated proxies only or one client fails.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P01-M03-T11

### P01-M03-T11 — Record impaired-network behavior
- **Objective:** Record impaired-network behavior.
- **Player-visible result:** Network limitations are measured, not assumed.
- **Technical implementation:** Latency/loss/jitter test settings and diagnostics output.
- **Dependencies:** P01-M03-T10.
- **Acceptance criteria:** Report lag/correction/interaction timings and accepted/rejected actions at named impairments.
- **Testing and evidence:** Repeat host+1/+3 under specified simulated loss/latency and save logs. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** No measurements, runaway jitter or dropped authoritative state.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P01-M04-T01

### P01-M04-T01 — Pure C# facility command boundary
- **Objective:** Pure C# facility command boundary.
- **Player-visible result:** Controls feed authoritative domain commands, never local gameplay truth.
- **Technical implementation:** Stable entity IDs, typed intents, validation, snapshots and events independent of Unity.
- **Dependencies:** P01-M03-T06.
- **Acceptance criteria:** Same command path works in local-host and multi-host mode; invalid target rejected.
- **Testing and evidence:** Domain unit tests for ID/revision/range validation, multi-process observation. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Direct camera/MonoBehaviour world-state mutation on clients.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P01-M04-T02

### P01-M04-T02 — First power/pump/valve model
- **Objective:** First power/pump/valve model.
- **Player-visible result:** Switching one breaker/valve changes actual meter values.
- **Technical implementation:** Small bounded electric/coolant data graph at fixed tick.
- **Dependencies:** P01-M04-T01.
- **Acceptance criteria:** Changing valve reduces verified flow; losing power stops pump and logs cause.
- **Testing and evidence:** Repeatable headless/Unity tests with finite-invariant checks. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Decorative gauges disconnected from graph.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P01-M04-T03

### P01-M04-T03 — Leak and alarms respond causally
- **Objective:** Leak and alarms respond causally.
- **Player-visible result:** Disabling coolant starts meaningful observable industrial failure.
- **Technical implementation:** Finite inventory, heat-load consequence, severity events and alarms.
- **Dependencies:** P01-M04-T02.
- **Acceptance criteria:** Leak reduces inventory/flow; warning appears; isolation changes outcome.
- **Testing and evidence:** Healthy and leaking fixture tests, client meter sync. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Cutscene alarm occurs regardless of actual state.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P02-M01-T01

## PHASE 2 — Networked physics and industrial gameplay

**Phase exit goal:** Responsive, server-owned props, controls and damage across remote peers.

### P02-M01-T01 — Server-owned pickup physics
- **Objective:** Server-owned pickup physics.
- **Player-visible result:** Remote-held objects obey collisions and bounded forces.
- **Technical implementation:** Server motion constraints, collision sweep, max energy and observability.
- **Dependencies:** P01-M03-T11; P01-M04-T01.
- **Acceptance criteria:** Two clients throw against geometry without persistent divergent poses.
- **Testing and evidence:** 2-process contact/throw stress, collision logs. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Unchecked teleport or remote-only collision.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P02-M01-T02

### P02-M01-T02 — Object lease lifecycle
- **Objective:** Object lease lifecycle.
- **Player-visible result:** Locks clear after disconnect, death or unreachable hand.
- **Technical implementation:** Lease generation, expiry, release, conflict acknowledgement.
- **Dependencies:** P02-M01-T01.
- **Acceptance criteria:** Exactly one holder under races; old messages cannot reclaim object.
- **Testing and evidence:** Simultaneous requests, packet reordering, death/disconnect fixtures. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Double ownership/stuck object.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P02-M01-T03

### P02-M01-T03 — Networked machinery actuation
- **Objective:** Networked machinery actuation.
- **Player-visible result:** Both players operate one panel with identical readings.
- **Technical implementation:** Server accepted intents and versioned switch/valve/door state.
- **Dependencies:** P01-M04-T02.
- **Acceptance criteria:** Two processes see identical accepted control state and meter revision.
- **Testing and evidence:** Simultaneous panel use and late-join checks. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Each client shows unrelated state.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P02-M02-T01

### P02-M02-T01 — Damage and repair transactions
- **Objective:** Damage and repair transactions.
- **Player-visible result:** Repairing one object removes one fault with a real consequence.
- **Technical implementation:** Server state machine, repair item consumption and idempotency.
- **Dependencies:** P01-M04-T03; P02-M01-T03.
- **Acceptance criteria:** Exactly one resource consumed per accepted repair; valve/cable resumes service.
- **Testing and evidence:** Duplicate RPC and wrong-tool/out-of-range tests. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Duplicate repair/reward or client applies damage.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P02-M02-T02

### P02-M02-T02 — Physics and network diagnostics
- **Objective:** Physics and network diagnostics.
- **Player-visible result:** Regressions in latency or authority can be reproduced.
- **Technical implementation:** Profiler markers, snapshots stats, peer log capture.
- **Dependencies:** P02-M01-T01.
- **Acceptance criteria:** Measured p95/p99 interactions, host CPU and bytes/sec saved by scenario.
- **Testing and evidence:** 4-process repeatable captures and packet impairment. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Unmeasured performance claim or silent correction storm.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P03-M01-T01

## PHASE 3 — Facility simulation and escalating disasters

**Phase exit goal:** Player-caused and preventable failures with traceable causal propagation.

### P03-M01-T01 — Power graph and breaker rules
- **Objective:** Power graph and breaker rules.
- **Player-visible result:** Power loss disables specific machines and correct protection trips.
- **Technical implementation:** Source/bus/consumer connectivity and capacity/protection evaluation.
- **Dependencies:** P01-M04-T02.
- **Acceptance criteria:** Protected overload trips; isolated load stays off.
- **Testing and evidence:** Pure-domain healthy and degraded breaker fixtures. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Wet surface always causes fire.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P03-M01-T02

### P03-M01-T02 — Coolant pressure and mass balance
- **Objective:** Coolant pressure and mass balance.
- **Player-visible result:** Valves and leaks measurably change flow and heat.
- **Technical implementation:** Bounded tank/pipe/pump flow with conservation.
- **Dependencies:** P03-M01-T01.
- **Acceptance criteria:** Nonnegative inventories, valid pressure, flow drops on shutdown.
- **Testing and evidence:** Seeded conservation + isolation tests. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Fluid created by independent clamps.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P03-M01-T03

### P03-M01-T03 — Thermal machinery failures
- **Objective:** Thermal machinery failures.
- **Player-visible result:** Heat escalates when cooling is lost and recovers when repaired.
- **Technical implementation:** Heat generation/removal, thresholds, failure causality.
- **Dependencies:** P03-M01-T02.
- **Acceptance criteria:** Loss of flow raises temperature; healthy loop stabilizes.
- **Testing and evidence:** Same input sequence yields expected thermal trend. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Heat jumps without cause or ignores repaired flow.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P03-M02-T01

### P03-M02-T01 — Air zones and smoke
- **Objective:** Air zones and smoke.
- **Player-visible result:** Smoke routes through open doors/vents but not closed barriers.
- **Technical implementation:** Zone graph, smoke inventory and bounded transport.
- **Dependencies:** P03-M01-T03.
- **Acceptance criteria:** Opening dampers permits transport; closed room retains separate state.
- **Testing and evidence:** Mass balance and door/damper counterfactuals. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Particles travel through sealed wall.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P03-M02-T02

### P03-M02-T02 — Fire propagation and intervention
- **Objective:** Fire propagation and intervention.
- **Player-visible result:** Exposed fault can ignite combustible material if protections fail.
- **Technical implementation:** Ignition/fuel/oxygen/suppression sites with causal events.
- **Dependencies:** P03-M02-T01; P03-M01-T01.
- **Acceptance criteria:** Good breaker and dead wire avoid fire; damaged protection permits it.
- **Testing and evidence:** Protected/degraded variants, suppression repeat. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Every leak deterministically becomes fire.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P03-M02-T03

### P03-M02-T03 — Authored structural damage
- **Objective:** Authored structural damage.
- **Player-visible result:** One falling section changes pathing and repairs cannot revive lost floor.
- **Technical implementation:** Finite section integrity, support edges and variant replacement.
- **Dependencies:** P03-M02-T02; P02-M01-T01.
- **Acceptance criteria:** Host and all clients agree collider/portal state after one breach.
- **Testing and evidence:** Break while player stands nearby; reconnect and pathfinding. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Invisible intact collider or unbounded falling pieces.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P03-M03-T01

### P03-M03-T01 — Readable multi-system incident chain
- **Objective:** Readable multi-system incident chain.
- **Player-visible result:** Players can understand why one mistake cascades.
- **Technical implementation:** Ordered causal event IDs, alarms, severity ladder and intervention feedback.
- **Dependencies:** P03-M02-T03.
- **Acceptance criteria:** Leak→cooling/short→alarm branch changes when valve/breaker corrected.
- **Testing and evidence:** Replay counterfactual fixtures and inspect incident trace. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Hidden timers override real causes.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P04-M01-T01

## PHASE 4 — Complete first vertical slice

**Phase exit goal:** One bounded mission playable solo and with 2/3/4 people.

### P04-M01-T01 — Mission start and objectives
- **Objective:** Mission start and objectives.
- **Player-visible result:** Player receives clear instructions and accomplishes one repair-and-extract job.
- **Technical implementation:** Lobby→Active→Results run state machine, readable mission UI.
- **Dependencies:** P03-M03-T01.
- **Acceptance criteria:** Ten-to-fifteen-minute mission has success and failure path.
- **Testing and evidence:** Real solo start/complete/fail flow and repeated reset. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Unfinishable objective or no explicit result.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P04-M01-T02

### P04-M01-T02 — One bounded facility level
- **Objective:** One bounded facility level.
- **Player-visible result:** A functional pump annex has distinct landmarks and repair routes.
- **Technical implementation:** Authored 6–8-room layout with service clearances and hazard routing.
- **Dependencies:** P04-M01-T01.
- **Acceptance criteria:** Every required control reachable without impossible simultaneous inputs.
- **Testing and evidence:** Solo run and geometry clearance checks. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Critical panel inaccessible or solo softlock.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P04-M01-T03

### P04-M01-T03 — One threat, death and post-death
- **Objective:** One threat, death and post-death.
- **Player-visible result:** One anomaly threatens player; death is playable in a bounded form.
- **Technical implementation:** Server AI patrol/pursue/attack; fixed camera/spectator capability.
- **Dependencies:** P04-M01-T02.
- **Acceptance criteria:** Creature cannot ignore doors; death and observer mode replicate.
- **Testing and evidence:** Single/multi death and blocked path tests. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Client-only damage or trapped dead-player input.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P04-M01-T04

### P04-M01-T04 — Crew size and difficulty profiles
- **Objective:** Crew size and difficulty profiles.
- **Player-visible result:** Solo and 2/3/4 crews all complete same mission without forced simultaneity.
- **Technical implementation:** Workload/assist policy and Intern/Standard profiles.
- **Dependencies:** P04-M01-T03.
- **Acceptance criteria:** Completed missions at 1,2,3,4; consistent hazard causality.
- **Testing and evidence:** Human sessions by crew size and both difficulties. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Only four-player mode viable or easy mode hides causality.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P04-M01-T05

### P04-M01-T05 — Extraction and incident results
- **Objective:** Extraction and incident results.
- **Player-visible result:** Survivors leave and see a factual report of their actions.
- **Technical implementation:** Extraction conditions, end ledger and compact causal summary.
- **Dependencies:** P04-M01-T04.
- **Acceptance criteria:** Victory/failure/abandon each produce one stable end state.
- **Testing and evidence:** Repeat session reset, disconnect during extraction. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Double win or stranded lobby.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P04-M01-T06

### P04-M01-T06 — Vertical slice review gate
- **Objective:** Vertical slice review gate.
- **Player-visible result:** An outsider plays the one mission without developer guidance.
- **Technical implementation:** QA checklist, recordings and prioritised fixes.
- **Dependencies:** P04-M01-T05.
- **Acceptance criteria:** Independent tester completes and reports understandable cause/effect.
- **Testing and evidence:** Multi-session usability and telemetry-free issue capture. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Developer-only walkthrough required.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P05-M01-T01

## PHASE 5 — Procedural facilities and replayability

**Phase exit goal:** Different valid facility layouts preserve industrial cause and solo routes.

### P05-M01-T01 — Seeded modules and landmarks
- **Objective:** Seeded modules and landmarks.
- **Player-visible result:** The facility changes but retains recognizable destinations.
- **Technical implementation:** Module IDs, socket ports, scoped PRNG and manifest.
- **Dependencies:** P04-M01-T06.
- **Acceptance criteria:** Same seed gives same manifest; variation seen over 3 seeds.
- **Testing and evidence:** Re-run deterministic seed fixtures. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Decor rearrangement changes mission logic unpredictably.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P05-M01-T02

### P05-M01-T02 — Utility/navigation validation
- **Objective:** Utility/navigation validation.
- **Player-visible result:** Every generated level has usable doors, pipes and service access.
- **Technical implementation:** Typed graph validators, route/clearance and fallback manifest.
- **Dependencies:** P05-M01-T01.
- **Acceptance criteria:** 1000 seeds per implemented profile pass or produce documented rejected seed.
- **Testing and evidence:** Headless property tests and in-Editor selected scene checks. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Disconnected pump or sealed objectives.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P05-M01-T03

### P05-M01-T03 — Difficulty-aware incident variety
- **Objective:** Difficulty-aware incident variety.
- **Player-visible result:** Runs differ by fault path not arbitrary impossible combinations.
- **Technical implementation:** Profile-driven fault and load selections with validation.
- **Dependencies:** P05-M01-T02.
- **Acceptance criteria:** Three scenarios present different repair choices; solvability retained.
- **Testing and evidence:** Seed replay, solo path and counterfactual fixtures. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Unexplained instant loss.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P05-M01-T04

### P05-M01-T04 — AI navigation after topology changes
- **Objective:** AI navigation after topology changes.
- **Player-visible result:** Creature reroutes after controlled breaches and barricades.
- **Technical implementation:** Room/portal graph and bounded navmesh rebuilding.
- **Dependencies:** P05-M01-T03.
- **Acceptance criteria:** AI uses legal alternate route or reports no path.
- **Testing and evidence:** Breach/block/floor removal in Unity with timing. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Enemy passes through former collider.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P06-M01-T01

## PHASE 6 — Game identity, horror, and content

**Phase exit goal:** A memorable original tone without sacrificing player clarity.

### P06-M01-T01 — Corporate narrator and incident language
- **Objective:** Corporate narrator and incident language.
- **Player-visible result:** Players hear/read consistent darkly comic industrial advisories.
- **Technical implementation:** Original authored message keys, causal event triggers and cooldowns.
- **Dependencies:** P03-M03-T01.
- **Acceptance criteria:** Alarms reference real incident, subtitles and non-audio cue preserved.
- **Testing and evidence:** Trigger event priorities, mute/audio-off sessions. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Comedic line masks essential safety cue.
- **Status:** PLANNED | **Priority:** Medium
- **Next task:** P06-M01-T02

### P06-M01-T02 — Industrial lighting, art and sound
- **Objective:** Industrial lighting, art and sound.
- **Player-visible result:** Each machine and risk can be visually/aurally identified.
- **Technical implementation:** Scoped reusable industrial kit, light/audio mixing.
- **Dependencies:** P06-M01-T01.
- **Acceptance criteria:** Controls recognizable in darkness and low graphics quality.
- **Testing and evidence:** Lighting and hearing/readability on two hardware profiles. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Only polished screenshot works; no gameplay readability.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P06-M01-T03

### P06-M01-T03 — Threat and animation personality
- **Objective:** Threat and animation personality.
- **Player-visible result:** One creature and player bodies have recognizable motion and sound cues.
- **Technical implementation:** Server threat behavior, client animations, original content.
- **Dependencies:** P06-M01-T02.
- **Acceptance criteria:** Players identify threat state without text overload.
- **Testing and evidence:** Solo and remote reactions, line-of-sight smoke tests. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Cosmetic AI contradicts authoritative actions.
- **Status:** PLANNED | **Priority:** Medium
- **Next task:** P06-M01-T04

### P06-M01-T04 — Adjustable horror and comfort
- **Objective:** Adjustable horror and comfort.
- **Player-visible result:** Horror intensity can change without changing hidden world rules.
- **Technical implementation:** Local gore/shake/audio options, lobby-governed rule variants.
- **Dependencies:** P06-M01-T03.
- **Acceptance criteria:** Lower settings preserve danger cues, colliders and mission parity.
- **Testing and evidence:** Compare gameplay outcomes and accessibility options. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Invisible damage, mandatory jumpscare or nausea effect.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P06-M01-T05

### P06-M01-T05 — Physics comedy and tools
- **Objective:** Physics comedy and tools.
- **Player-visible result:** Physical accidents create emergent funny outcomes without softlocks.
- **Technical implementation:** Reusable props, one fixed repair tool and feedback.
- **Dependencies:** P06-M01-T04.
- **Acceptance criteria:** Players improvise with props while important controls remain recoverable.
- **Testing and evidence:** Solo and four-player object stress/playtests. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Props permanently block extraction with no recovery.
- **Status:** PLANNED | **Priority:** Medium
- **Next task:** P07-M01-T01

## PHASE 7 — Commercial-quality development

**Phase exit goal:** Measured performance, accessibility, recovery and QA across target PCs.

### P07-M01-T01 — Performance baseline
- **Objective:** Performance baseline.
- **Player-visible result:** Normal four-player incident is smooth on specified PCs.
- **Technical implementation:** Instrument rendering/network/physics and bounded cleanup.
- **Dependencies:** P06-M01-T05.
- **Acceptance criteria:** Report frame p95/p99, memory, host tick and bandwidth at reference workload.
- **Testing and evidence:** Profile reference hardware + weaker client. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Targets claimed without profiler.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P07-M01-T02

### P07-M01-T02 — Save, load and corrupt recovery
- **Objective:** Save, load and corrupt recovery.
- **Player-visible result:** World survives crash/relaunch or rejects bad checkpoint safely.
- **Technical implementation:** Versioned snapshots, checksum, backup and validation.
- **Dependencies:** P07-M01-T01.
- **Acceptance criteria:** Damaged world and progress round-trip, corrupt file safely refused.
- **Testing and evidence:** Save/load fixtures, kill during write and schema mismatch. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Duplicate rewards or lost state silently.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P07-M01-T03

### P07-M01-T03 — Accessibility and controller navigation
- **Objective:** Accessibility and controller navigation.
- **Player-visible result:** Controls and safety cues usable without precise mouse.
- **Technical implementation:** Input Action mappings, rebinding, scalable UI, subtitle and controller flows.
- **Dependencies:** P07-M01-T02.
- **Acceptance criteria:** Full mission doable using supported controller with accessible cues.
- **Testing and evidence:** Human keyboard/controller and comfort settings tests. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Controller cannot interact with essential panel.
- **Status:** PLANNED | **Priority:** High
- **Next task:** P07-M01-T04

### P07-M01-T04 — Network resilience and compatibility
- **Objective:** Network resilience and compatibility.
- **Player-visible result:** Host loss/reconnect/version failures are safe and understandable.
- **Technical implementation:** Timeout UX, schema/hash checks, graceful session closure.
- **Dependencies:** P07-M01-T03.
- **Acceptance criteria:** All crew sizes recover or fail visibly without duplicates.
- **Testing and evidence:** Packet loss, join/leave, invalid client version. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Invisible ghost player or state corruption.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P07-M01-T05

### P07-M01-T05 — Release candidate quality gate
- **Objective:** Release candidate quality gate.
- **Player-visible result:** Known regressions are triaged against published acceptance checks.
- **Technical implementation:** QA matrix, build identifiers, crash logs and bug triage.
- **Dependencies:** P07-M01-T04.
- **Acceptance criteria:** No unresolved ship-blocker and independent tester acceptance.
- **Testing and evidence:** Clean-install smoke on target machines. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Only developer machine passes.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P08-M01-T01

## PHASE 8 — Steam preparation and release

**Phase exit goal:** Legally cleared, stable, tested Windows PC launch and measured follow-up.

### P08-M01-T01 — Steam integration verification
- **Objective:** Steam integration verification.
- **Player-visible result:** Real devices can join through the intended online route.
- **Technical implementation:** Steamworks SDK, transport/license inventory and environment configuration.
- **Dependencies:** P07-M01-T05.
- **Acceptance criteria:** Multi-account/two-device invite and online transport validated.
- **Testing and evidence:** Real machines/accounts in Steam test environment. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** LAN-only test counted as Steam success.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P08-M01-T02

### P08-M01-T02 — Store, ratings and legal audit
- **Objective:** Store, ratings and legal audit.
- **Player-visible result:** Store promise matches actually tested game and licensed assets.
- **Technical implementation:** Trademark/title, assets, open-source notices, store media and disclosures.
- **Dependencies:** P08-M01-T01.
- **Acceptance criteria:** Every shipped item has license provenance; screenshots from real game.
- **Testing and evidence:** License checklist, actual store review. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Unlicensed art or false platform claims.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P08-M01-T03

### P08-M01-T03 — Steam depots and release builds
- **Objective:** Steam depots and release builds.
- **Player-visible result:** Signed-off Windows build installs and updates from Steam.
- **Technical implementation:** Build profiles, depots/branches, crash symbol retention.
- **Dependencies:** P08-M01-T02.
- **Acceptance criteria:** Fresh Steam install launches, multiplayer works, update preserves compatible saves.
- **Testing and evidence:** Private branch install/update/rollback smoke tests. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Only local unpackaged exe works.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P08-M01-T04

### P08-M01-T04 — External playtest and launch readiness
- **Objective:** External playtest and launch readiness.
- **Player-visible result:** Players finish stable co-op sessions on real hardware.
- **Technical implementation:** Playtest feedback, issue prioritization, crash regression and final gate.
- **Dependencies:** P08-M01-T03.
- **Acceptance criteria:** Representative solos and 2–4-player sessions pass documented checklist.
- **Testing and evidence:** External network sessions, support/log plan. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Repeated blocker or unhandled safety concern.
- **Status:** PLANNED | **Priority:** Critical
- **Next task:** P08-M01-T05

### P08-M01-T05 — Launch and post-launch support
- **Objective:** Launch and post-launch support.
- **Player-visible result:** Released game has support, patch policy and working rollback.
- **Technical implementation:** Release checklist, monitor opt-in crash reports, urgent patch branch.
- **Dependencies:** P08-M01-T04.
- **Acceptance criteria:** Store download playable and update/rollback exercised.
- **Testing and evidence:** Production install/patch validation. Record timestamp, build SHA, actual result and logs under TEST_RESULTS.md.
- **Failure conditions:** Shipped build cannot be recovered.
- **Status:** DEFERRED | **Priority:** High
- **Next task:** Continue maintenance.

## PR and session completion contract
Every implementation PR cites task IDs and lists code paths, observed player-visible outcomes, exact executed tests, *NOT RUN* tests, dependencies/licensing, blockers and next task. Never merge unverified scene/network code automatically. At every meaningful handoff update README.md, AGENTS.md, CURRENT_TASKS.md, NEXT_SESSION.md, DECISIONS.md, TEST_PLAN.md, TEST_RESULTS.md, NOT_RUN.md, BUGS.md and DEVELOPMENT_LOG.md as applicable. State current commit and PR. Reopen the latest branch ref before changing it; no force pushes. Content expansion waits for actual network physics and one mission to pass.
