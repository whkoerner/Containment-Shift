# Facility simulation and world state

Status: PLANNED; domain implementation, numerical stability, save migrations and engineering review NOT TESTED.

## Use a hybrid, not thousands of Update methods

Start with pure-C# data-oriented managers over typed graphs. Use dense arrays of state, stable-ID→index mappings, adjacency lists, dirty queues and explicit fixed-step phases. GameObjects represent visible/interactable equipment, not every simulated wire segment. ScriptableObjects author definitions and bake into immutable runtime records. Runtime state never mutates definition assets.

ECS is not required to process a few thousand bounded graph elements. Consider Jobs/Burst for measured hot loops later; snapshot inputs and apply completed results in a stable order. DOTS wholesale would add authoring, physics and networking integration risk before demonstrating a bottleneck. Avoid both a monolithic god-manager and a generic scripting language: have small typed solvers with an explicit orchestrator.

| Graph / state | Elements | Initial approximation |
|---|---|---|
| Electrical | Sources, buses, breakers, consumers, typed connections | Connectivity, capacity/load and protection state; no general AC circuit solver |
| Coolant/fluid | Reservoirs, pumps, valves, pipe edges, heat exchangers | Lumped volumes, pressure/head relationships, conductance, bounded flow and heat transport |
| Air/ventilation | Room zones, vents, fans, dampers, door/breach portals | Well-mixed zone mass/heat and optional two-layer smoke later |
| Structure | Anchors, sections, support edges | Connectivity/capacity approximation; authored load paths |
| Equipment/process | Machine state and ports | Input availability, operating mode, damage, heat generation and output rules |
| Hazards | Fire sites, puddles, exposure fields | Bounded local volumes tied to authoritative zones/cells |

Cross-system dependencies are explicit ports and messages: a pump consumes power and moves fluid; a machine transfers heat into its cooling loop; a fan consumes power and moves air. Do not encode these as arbitrary scene references or broadcast events that every component subscribes to.

## Tick contract

At 10 Hz initially: ingest validated commands and accumulated physics contacts → commit graph topology changes → solve electrical availability and protection → solve fluid flow/heat removal → update process heat → update fire/air/wetness → integrate exposure and damage → enqueue resulting failures for the next tick → publish dirty state and causal events. Structural evaluation runs at 2 Hz or from an urgent queue. Contact damage is aggregated once; clients cannot repeat it.

Within a phase read a consistent prior state and write the next buffer. Cross-phase latency is deliberate and documented. New failures cannot recursively trigger an unbounded same-frame event storm. Bound work and report queue age. Coupled feedback can use a small fixed iteration count later, with residual checks and a fallback, not a convergence loop of unlimited length.

Use explicit units: seconds, kg, litres or cubic metres consistently, kPa, kW, degrees C, and documented game-scaled exposure units. Central parameters expose time exaggeration. Preserve nonnegative quantities, reservoir limits and mass balance including sources, sinks, leaks and drains. If requested outflow exceeds available mass, scale outgoing flows together; never clamp each destination independently and create liquid. Heat transfer cannot remove more stored energy than available. Reject NaN/Infinity and invalid content at import and command boundaries.

Deterministic rule evaluation means stable ordering, scoped PRNG streams and repeatable discrete outcomes under the same inputs/build. It does not promise bitwise floating-point agreement across platforms or a deterministic PhysX replay. Only the host solves the facility. Clients interpolate readings and display authoritative outcomes.

## A credible slice cascade

Use a non-reactor industrial cooling loop first. A damaged pressurized water/glycol pipe leaks only when fluid and pressure are present. Inventory loss and/or pressure loss reduces pump flow and cooling capacity. The spill follows authored floor cells/drains; wetting an exposed energized cable tray creates a fault condition if fluid conductivity and enclosure state permit it.

A functioning breaker trips; fire is not guaranteed. The intended dangerous scenario includes an explicitly degraded protection device and combustible cable insulation, so sustained fault heating can ignite it. Losing auxiliary power stops one fan/pump. A separately supplied standby source starts after a delay and transfer interlock, powers an emergency bus, and changes configured door states. Smoke moves only through connected openings/ducts. Heating a vulnerable support may reduce its capacity enough to drop a selected slab.

Test the healthy-breaker counterexample, an empty pipe, de-energized wet equipment, a closed damper and a redundant pump. If every spill produces the same fire regardless of protections, the simulation has failed the premise. Do not imply nuclear reactors explode like nuclear weapons. Future reactor types need explicit shutdown, decay-heat and containment models plus technically informed review; generic coolant is not automatically radioactive or flammable.

## Fire, smoke and fluids

| Phenomenon | Gameplay simulation | Presentation |
|---|---|---|
| Fire | Fuel, heat, ignition threshold, oxygen availability, suppression; sites aggregated per cell/equipment | Pooled particles and a few lights |
| Smoke | Zone concentration/temperature; flow through doors, breaches and vents; bounded exchange conserving smoke mass except explicit sinks | Particles/fog interpolated from density; no simulated particle collisions |
| Spill/water | Shallow floor cells or authored catchment graph; volume, depth bands, wet contacts and drainage | Decals/meshes, splashes and ripples |
| Pressurized leak/steam | Orifice-like bounded discharge, local hazard cone/volume and room heat input | Jet particles/audio; no thousands of fluid rigidbodies |
| Gas | Typed source inventory, transport, flammability range and ignition rule if introduced | Localized effects tied to concentration |
| Radiation/contamination | Later: source strength, distance, authored shielding and transferable contamination reservoirs | Meter/audio/visual cues from authoritative exposure |

No CFD, SPH ocean, per-particle smoke networking or per-pixel fire propagation. Room averaging is coarse: large halls require multiple zones; shut doors may have configured leakage. Cosmetic smoke cannot contradict authoritative visibility: AI vision and player hazard readings use the same zone data. Low effects settings retain a cheap visibility veil and clear hazard cues.

## Difficulty without five separate games

One schema supports optional nodes, control policies and interaction affordances. Lobby locks a versioned SimulationProfile for the run. Intern can automate valve sequencing and standby transfer; Standard exposes simple manual controls; Technician enables selected protection faults; Engineer adds diagnostics and deeper dependencies; Extreme adds more monitored branches and tighter margins. Optional complexity must be present in the validated generation manifest, not spawned unpredictably on a client.

Implement only Intern and Standard in the slice. Higher tiers remain PLANNED. Automation is an explicit server controller issuing the same legal commands as a player, so it cannot grant hidden energy or reverse damage. Compare shared scenarios to ensure simplified modes preserve causal explanations.

Scale crew workload separately: sequentially operable controls, latching actions, portable tools, bounded travel and optional assistance. Never require two simultaneously held switches for the only solo escape. Tune objective work and escalation opportunities for 1/2/3/4 players rather than multiplying monster health. Changes in player count after disconnect cannot silently rewrite the facility; apply a disclosed assistance policy.

## Improvised devices: future contract only

A DeviceDefinition specifies a finite slot list, accepted tags, limits and a behavior state machine. A host-side resolver maps ordered component IDs plus recipe version to a known variant and bounded modifiers. An incorrect lens might select a short-range unstable variant, but cannot invent a new class. Define precedence for conflicting substitutions and reject unsupported combinations before consuming components. Save recipe ID/version, component IDs, resolved variant and internal charge/cooldown state. Property-based tests check conservation of inventory and limits. Slice implements one fixed repair tool, not a crafting catalog.

## Save schema and timeline resets

Use a versioned DTO snapshot, initially inspectable JSON plus compression if needed. Header: save schema, game build, content hash, generator version, profile version, run UUID, timeline epoch, parent checkpoint, authoritative tick and checksum. Payload:

- Seed and independent PRNG stream states; full generated module/port manifest.
- Stable entities, damage variants, graph topology/revisions, support failures, fluid/thermal/electrical/hazard state and pending timed transitions.
- Dynamic object transforms/velocities and durable resting rubble, inventories, machine/device state.
- Player identities mapped to saved slots, embodiment/capabilities, death cause; session leases cleared on restore.
- Mission state, discrete severity 0–5, escalation timers/causes, completion ledger and chosen checkpoint policy.
- Separate meta-progression and accessibility preferences; never roll back local comfort settings.

Capture a coherent tick boundary. Background serialization receives an immutable copy. Write a temp file, verify checksum, atomically replace, retain last known-good backup. Load into staging, validate IDs/limits/content, rebuild graphs/colliders, then expose play. Recreate physics from stored state; do not serialize solver internals. Mid-motion resume may settle slightly differently and needs explicit acceptance tests.

Provide sequential schema migrations with fixture saves and explicit rejection of unknown future schemas. Content changes can remap stable IDs only through authored migrations. Retaining a seed without the manifest and content version is insufficient. Declare run-save breakage during prototype revisions clearly; do not promise perpetual compatibility before a release contract exists.

Severity changes are rule-driven thresholds and objectives, not a planetary simulation. Store the transition cause and presentation state. A timeline reset is an atomic server command: stop accepting old-epoch inputs, select checkpoint, restore run state, increment epoch, apply the explicitly retained meta-state and send a full new baseline. Old packets/rewards cannot apply in the new epoch. Reset meta-progress and checkpoint writes need a transaction journal or equivalent recovery marker to avoid a crash duplicating rewards.

Incident reconstruction uses a bounded causal event log: event ID, parent causes, tick, entity, rule and before/after summary. Present an ordered incident timeline, not a claim of exact video replay. Slice proves save/load of a damaged scene and one reset; full arbitrary physics replay is excluded.
