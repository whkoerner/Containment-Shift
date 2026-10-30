# Containment-Shift

Working title: **Containment Shift** — a planned 1–4 player industrial disaster co-op game in which the facility itself is a systemic threat.

## Local development workforce

[Install and use the Ollama workforce](docs/WORKFORCE_SETUP.md) · [REAL-TIME TESTS](docs/REAL_TIME_TESTS.md) · [Test evidence](TEST_RESULTS.md)

On this branch, double-click **INSTALL_WORKFORCE.cmd** on Windows. Setup preserves
the old AI workspace, runs the runtime regression suite locally, and creates
Start, Stop and Save, Emergency Stop, Play, Feedback, and Status shortcuts.

This branch includes the imported Unity `6000.6.7f1`/NGO prototype and an input
backend repair. Windows execution, Unity compilation and gameplay from this
branch remain unverified until the local checks and human playtest run.

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

**IMPORTED PROTOTYPE — CURRENT BRANCH GAMEPLAY NOT VERIFIED.** The earlier
documents-only state is preserved in Git history. This branch includes imported
Unity source and workforce code; existing historical reports of controls working
do not establish gameplay from this checkout. Cloud runtime checks do not
establish Unity compilation, multiplayer correctness, or gameplay feasibility.

Implementation should follow the vertical-slice gates before expanding content. Record actual build and multi-instance test evidence; never count placeholder classes as completed features.
