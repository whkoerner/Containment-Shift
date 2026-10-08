# Performance budgets

Status: PLANNED starting targets, NOT TESTED. These are allocation hypotheses, not engine limits or shipping minimum requirements.

## Reference workload and machines

Provisional reference PC: Ryzen 5 5600-class six-core CPU, RTX 3060 12 GB-class GPU, 16 GB RAM, SSD, Windows x64, 1080p medium. This is a proposed reproducible test machine, not a market survey. Confirm available hardware and record exact CPU/GPU/driver/OS/build in captures. Include a slower client and constrained home upload before setting store requirements.

Target 60 rendered fps with host + three remote players, all four players in separate affected rooms, maximum slice hazards and a collapse. Measure the rendering host, not only a headless server or four minimized windows on one PC. Four local processes validate networking logic; they do not measure normal per-machine performance.

| Resource | First slice envelope | Later stress hypothesis, only after profiling |
|---|---:|---:|
| Active authoritative dynamic bodies, including chunks | 64 peak; 24 normal | 128 peak |
| Resident movable/sleeping prop records | 100 | 300 |
| Simultaneous grab constraints | 4, single-holder | 4 plus a separately tested two-person carry |
| Frequently synchronized entities per client | 80 peak incl. players/AI/props | 160 |
| Static facility data entities | 256 | 2,000 nodes / 6,000 edges |
| Creatures | 1 mission, 4 stress | 8 active |
| Active fire sites | 4 mission, 16 stress | 32 aggregated sites |
| Smoke/air zones | 8–16 | 64 |
| Shallow spill cells | 256 | 1,024 |
| Structural state sections | 64 | 512 |
| Simultaneously falling large pieces | 8, inside body cap | 16, inside body cap |
| Local cosmetic debris | 150 nearby | 300 with pools/LOD |
| Visible dynamic lights | 8, at most 2 shadowed | 12, at most 4 shadowed |
| Network continuous snapshot rate | 20 Hz | Tune 10–30 Hz by importance |
| Facility solver rate | 10 Hz | Same until stability/playability requires more |
| Physics/player tick | 60 Hz | Do not lower without movement tests |

Sleeping is not a license to spawn unlimited bodies. Contact pairs, convex complexity, stacks, CCD and solver iterations often dominate body count. Use simple collision shapes, discrete collisions by default, CCD only where needed, capped angular speeds, stable object masses and collision-layer filtering. Avoid using render meshes as moving colliders.

## Time and memory envelopes

At 60 fps the whole frame has 16.67 ms. Initial host main-thread allocations: physics ≤3 ms, facility ≤1 ms averaged with ≤3 ms on its active tick, AI/navigation scheduling ≤1.5 ms, networking/serialization ≤1 ms, remaining gameplay/presentation submission ≤5 ms. These are inclusive per-frame targets to measure without double-counting profiler categories. Reserve headroom; a physics spike and graph tick can coincide.

Target GPU ≤13 ms at the reference quality. Main-thread and GPU time overlap; do not add them as if sequential. Proposed steady-play p95 frame time ≤16.7 ms and p99 ≤25 ms, with no repeated collapse stalls >50 ms. Loading is reported separately. Gate on sustained host tick health too; smooth client rendering cannot hide a server falling behind.

Target game working set ≤4 GB and VRAM ≤6 GB for the slice. No sustained per-tick managed allocation in facility loops after warmup; record allocations elsewhere and GC pauses rather than claiming globally zero allocation. A 30-minute run should plateau, with ≤5% post-warmup memory growth pending investigation of caches. Cap pooled effects, event logs, pending joins and navigation jobs.

## Network envelope and arithmetic

Starting **gameplay** target: ≤80 kB/s average host→each client, ≤15 kB/s each client→host; aggregate host send ≤240 kB/s for three clients before voice. Example: 80 active transforms × 32 encoded bytes × 20 Hz = 51,200 B/s to one client before packet overhead, reliable changes and retransmission. This illustrates why interest management, quantization and sleeping updates matter; 32 bytes is a design hypothesis to measure, not a FishNet packet size claim.

Allow short collapse bursts up to 200 kB/s per client for ≤2 seconds, rate-limit baselines separately, and prevent reliable queues growing without bound. Aim for a compressed initial world baseline ≤1 MB; verify an actual target connection can join within 10 seconds after assets are loaded. Never send a giant unbounded RPC. Fragment/chunk within the chosen transport's documented limits and measure wire bytes, not just payload counters.

Reserve a provisional 8 kB/s per active talker→listener voice route, then replace with measurements of the chosen codec. In host-forwarded four-person voice with everyone talking, host outbound can contain nine such streams: about 72 kB/s plus overhead. With gameplay, target roughly ≤350 kB/s steady host egress (~2.8 Mb/s), excluding baseline bursts. Relay routing may change accounting; capture both directions and distinguish billed service traffic from host traffic. This is not a promise of audio quality or home-network suitability.

## Overload policy

First reduce cosmetic particles, shadowed lights, ragdoll detail and far-view refresh. Then batch dirty state, lower distant noncritical snapshot frequency and coalesce nav updates. Keep damage, collision, critical controls and mission transitions authoritative. Never discard a leak, remove a barricade or stop an offscreen fire to recover fps. Use content caps if critical work cannot fit.

Network overload: prioritize player input, durable transitions and nearby interactions; throttle cosmetic and distant updates; bound voice buffers and join traffic. If snapshots fall behind, resync rather than replaying seconds of stale movement. Reject new costly spawns with a valid gameplay outcome instead of allowing unbounded queues.

## Measurement protocol

Capture standalone Development builds for markers, then corroborate representative results in a release/IL2CPP build. Exclude warmup/shader compilation explicitly; also test first-run shader/loading experience separately. Repeat normal and worst-case workloads at 1/2/3/4 players, and report p50/p95/p99, maxima, queue age, correction counts, packet loss, wire traffic and memory. Maintain an identical seed/input script for comparisons. No benchmark has run in this review.
