# Containment-Shift

Working title: **Containment Shift** — a planned 1–4 player industrial disaster co-op game in which the facility itself is a systemic threat.

## Architecture review

Review date: October 8, 2026. Start with [Architecture Decision](docs/architecture/ARCHITECTURE_DECISION.md) and [First Vertical Slice](docs/architecture/FIRST_VERTICAL_SLICE.md).

The provisional direction is Unity 6.3 LTS, URP, host-authoritative multiplayer, FishNet subject to a physics/networking validation gate, graph-based facility simulation and bounded hybrid destruction.

| Document | Purpose |
|---|---|
| [ARCHITECTURE_DECISION.md](docs/architecture/ARCHITECTURE_DECISION.md) | Engine decision and architectural boundaries |
| [FACILITY_SIMULATION.md](docs/architecture/FACILITY_SIMULATION.md) | Facility graphs, hazards, difficulty, saves and resets |
| [FIRST_VERTICAL_SLICE.md](docs/architecture/FIRST_VERTICAL_SLICE.md) | First playable scope and go/no-go gates |
| [INITIAL_STACK.md](docs/architecture/INITIAL_STACK.md) | Bootstrap stack and implementation handoff |
| [NETWORKING_ARCHITECTURE.md](docs/architecture/NETWORKING_ARCHITECTURE.md) | Networking comparison, authority, replication and Steam |
| [PERFORMANCE_BUDGETS.md](docs/architecture/PERFORMANCE_BUDGETS.md) | Initial performance targets and measurement protocol |
| [PHYSICS_AND_DESTRUCTION.md](docs/architecture/PHYSICS_AND_DESTRUCTION.md) | Interaction ownership and hybrid destruction |
| [PROCEDURAL_GENERATION.md](docs/architecture/PROCEDURAL_GENERATION.md) | Infrastructure generation and changing navigation |
| [TECHNICAL_RISKS.md](docs/architecture/TECHNICAL_RISKS.md) | Risk register and honest test evidence requirements |

## Implementation status

**PLANNED — NOT TESTED.** This repository currently contains architecture documentation, not a playable game. No Unity compilation, gameplay tests, multiplayer sessions or performance benchmarks have been executed for this project. Documentation packaging checks do not establish gameplay feasibility.

Implementation should follow the vertical-slice gates before expanding content. Record actual build and multi-instance test evidence; never count placeholder classes as completed features.
