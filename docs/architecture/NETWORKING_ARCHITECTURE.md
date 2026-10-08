# Networking architecture

Status: PLANNED; SDK integration, Steam connectivity, voice and multiplayer NOT TESTED. Review: 2026-10-08.

## Candidate decision

Use **FishNet 4.7.3R as the initial spike candidate**, pinned to its resolved release commit at bootstrap. The official release listing currently labels 4.7.3R latest [1]. This does not establish compatibility with our Unity patch, controller or transport. Select the production stack only after Gate A in FIRST_VERTICAL_SLICE.md.

| Candidate | Verified capability | Fit / cost to this project | Decision |
|---|---|---|---|
| Unity Netcode for GameObjects | Current 2.11 documentation distinguishes anticipation from full prediction/reconciliation [2] | First-party GameObject integration; Unity Transport/Relay route exists [3]. Responsive player/prop interaction would need extra prediction engineering | Credible for slower interactions; not first choice for this physics-heavy brief |
| FishNet | PredictionRigidbody API and transport abstraction documented [4,5]; FishySteamworks adapter exists [6] | Fits C#/GameObjects and lets us evaluate prediction without committing to a hosted service. Integration/maintenance and custom license need review | Provisional first choice |
| Mirror | Server-authoritative model, replaceable transports; Steam adapter listed [7]. Its prediction guide still warns that its prediction work is experimental [8] | Solid candidate for snapshot/interpolation architecture. Do not mistake a physics demo for a proven prediction solution | Fallback if server-only prop physics is sufficient; not preferred for prediction-dependent design |
| Photon Fusion 2.1 | Host/client-server physics supports Forecast and a prediction/resimulation addon [9] | Strong physics alternative; hosted-service dependency and CCU/traffic economics [10]. Resimulation has CPU costs; Forecast is approximation | Primary fallback if FishNet spike fails; use Host, not Shared mode |
| Netcode for Entities | Server-authoritative prediction framework for DOTS [11] | Larger data/authoring migration than this four-player slice justifies | Revisit only if measured workloads require DOTS |
| Photon Quantum | Deterministic ECS/predict-rollback model [12] | Would change simulation/physics authoring rather than simply replace a transport | Not appropriate as a low-risk substitution here |

These are capability checks, not comparative benchmark results. Current FishNet license is custom, not MIT; its game-use grant and third-party notices must be retained and reviewed [13]. Do not copy vendor marketing claims about maximum object counts into our capacity plan. Do not install all candidates in the production project.

Fusion 2.1 matters to this comparison: older advice that treats every responsive Fusion physics object as a mandatory full-world rollback cost is incomplete. Its Forecast approach trades accuracy for cost. It still needs our grab, topology-change and performance tests [9]. Steam authentication/lobbies do not imply Fusion traffic uses Steam relay.

## Topology and clocks

One listen server owns the world; up to three remote clients. Offline solo runs the same server/application path through a local session adapter. No live host migration in the slice: host loss ends the session clearly; the host can later resume a committed checkpoint. Seamless migration is a separate product requirement, not a free consequence of networking middleware.

Initial targets: 60 Hz player input and authoritative physics, 20 Hz object snapshots, 10 Hz facility integration, 2 Hz structural evaluation plus immediate dirty marking. One scheduler defines phase order. Feed networking prediction from the same physics clock; do not allow both Unity auto-simulation and an SDK to advance the same scene. Gate A must verify the exact SDK hooks. Clamp catch-up and report overload rather than silently changing simulated elapsed time.

Local camera/animation updates every rendered frame. Predict the local locomotion motor; reconcile from server state and acknowledged input sequence. Start props server-simulated with interpolated collision proxies and a visual-only held-object presentation. A predicted hand target is not proof that arbitrary collisions can be predicted cheaply. If feel fails, test a bounded held-object prediction island using the package-supported path, not a custom global rollback engine.

## Ownership versus authority

Connection ownership identifies who may submit input. It never grants world-state authority. The server validates player/embodiment capability, range, occlusion, object revision, cooldown, input rate and finite numeric values. Even the host player's requests use the same command path. A malicious host is outside the trust model; this is cooperative play, not a competitive anti-cheat system.

Each command contains session epoch, sender-derived player identity, command sequence, target stable ID, expected revision, verb and bounded arguments. Never trust a client-provided player ID. Deduplicate irreversible requests; acknowledge accepted/rejected outcomes. Timestamp windows cannot allow backdated destruction or repair.

## Replication contract

| Data | Delivery / contents |
|---|---|
| Player inputs | Unreliable sequenced batches with bounded recent-input redundancy and server acknowledgments |
| Continuous props/players/creatures | Unreliable sequenced snapshots; tick, pose, velocity, sleep state, object revision; bounded interpolation/extrapolation |
| Durable transitions | Reliable ordered, idempotent commits: destroyed section, door mode, pipe state, inventory, death, mission result |
| Facility values | Quantized dirty deltas, 2–10 Hz by relevance; periodic full-state resync; alerts/threshold changes reliable |
| Cosmetic events | Best effort, event ID and visual seed; never the sole carrier of durable state |
| Initial/reconnect state | Chunked reliable snapshot with byte limits, checksum and resume/restart policy |

No per-pipe NetworkObject requirement. Batch static facility entities by zone into replication records. Promote only actively moving/interacting entities to networked views. Interest management suppresses views and traffic, not remote simulation. Persist all damage even if nobody watches the room. Sleeping props send change/wake notifications and baseline state, not 20 identical transforms per second.

The snapshot is authoritative, not the event history. A late joiner needs destroyed-section bitsets, current collision states, dynamic objects, facility graph revisions, embodiment and mission state—not replay of every fracture RPC.

Bootstrap sequence: protocol/content compatibility → host manifest → local module construction → snapshot at tick T → apply buffered commits after T → acknowledge ready → enable player control. Buffer limits and sequence gaps trigger a fresh baseline. Duplicate/out-of-order messages cannot spawn duplicate loot, heal a destroyed object or award results twice. Reject incompatible builds with a useful message.

## Steam, NAT and voice

Local iteration uses FishNet's default transport; lock the specific transport version after the spike. Steam prototype uses FishySteamworks + Steamworks.NET. The adapter README documents peer-to-peer relay and separate-device/account constraints for testing [6]. Valve provides modern networking APIs and relaying facilities [14]; middleware compatibility must still be measured. Lobbies, authentication, invites and transport are distinct integrations. Do not treat a lobby join as a game connection.

Prove two machines on different networks early, then four authenticated accounts/devices for the release-path gate. Local four-process tests cannot prove Steam NAT traversal. Log direct/relay route and connection failures without retaining raw IP addresses. Non-Steam relay is deferred behind an ISessionService boundary; Unity Relay is not assumed to plug directly into FishNet.

For a Steam-only slice, start a small voice spike with Steam Voice capture/compression and explicit unreliable audio routing. Valve's API does not transmit the captured audio for us [15]. Add bounded jitter buffering, per-user mute/volume, push-to-talk, device selection, microphone permission feedback, distance falloff and zone/door occlusion. A maintained voice middleware may replace this spike if integration cost is high; no particular package compatibility is claimed. Voice can fail independently without ending the mission. Text/ping communication remains usable.

Voice routes use alive/dead capability channels; a ghost cannot leak forbidden tactical information through an accidentally global channel. Do not record voice. Budget audio separately from reliable gameplay traffic so a talker cannot starve a repair or death event.

## Save, reconnect and results

Host owns run saves and authoritative rewards. Session identity differs from platform identity. Reconnect replaces a disconnected player's embodiment once, restores inventory and releases abandoned grabs. For the slice, test reconnect from snapshot; public mid-mission joining may stay disabled. Results are committed once by run ID + epoch + result ID. Reconnect after results must not duplicate progression.

## Sources checked 2026-10-08

[1] https://github.com/FirstGearGames/FishNet/releases

[2] https://docs.unity3d.com/Packages/com.unity.netcode.gameobjects@2.11/manual/advanced-topics/client-anticipation.html

[3] https://docs.unity.com/relay — integration route documentation; exact SDK pairing to verify at bootstrap.

[4] https://fish-networking.gitbook.io/docs/guides/features/prediction/predictionrigidbody

[5] https://fish-networking.gitbook.io/docs/guides/high-level-overview/transports

[6] https://github.com/FirstGearGames/FishySteamworks

[7] https://mirror-networking.gitbook.io/docs/manual/transports

[8] https://mirror-networking.gitbook.io/docs/manual/general/client-side-prediction

[9] https://doc.photonengine.com/fusion/v2/manual/physics/physics-overview

[10] https://www.photonengine.com/Fusion/Pricing

[11] https://docs.unity.com/multiplayer/netcode/netcode

[12] https://doc.photonengine.com/quantum/v3/manual/quantum-ecs/dsl

[13] https://github.com/FirstGearGames/FishNet/blob/main/LICENSE.md

[14] https://partner.steamgames.com/doc/features/multiplayer/networking

[15] https://partner.steamgames.com/doc/features/multiplayer
