# CURRENT TASKS — 2026-10-08

Canonical definitions and criteria: [PROJECT_EXECUTION_PLAN.md](PROJECT_EXECUTION_PLAN.md). This is a queue, not a competing roadmap. **Source-only work does not earn a TESTED gameplay status.**

## CURRENT
- **P01-M01-T01 (BLOCKED, Critical)** — clean Unity 6000.3.25f1 import + zero compiler errors, package lock evidence. Code fixes may proceed without Editor; actual acceptance needs Unity. Expected player-visible result: an Editor project opens ready for graybox generation. After compile, proceed to P01-M01-T02.

## NEXT
- **P01-M01-T02 (IMPLEMENTED — UNVERIFIED)** — generate and commit the two-room scene from the actual Editor. Verify 12 props, interactive door/switch and build inclusion; generator never overwrites.
- **P01-M02-T03 (BLOCKED)** — run four real InteractionRules EditMode tests; capture passing/failing results.
- **P01-M01-T04 / P01-M02-T04 (BLOCKED)** — Windows build and fresh-checkout playable interaction smoke test.
- **P01-M03-T01 (PLANNED)** — only after local gate: pin and import FishNet; test real host and remote client.

## BLOCKED
- Unity Editor and Windows build runner are absent in the available execution environment; package resolution, scene serialization, actual compilation, physics and PlayMode cannot be certified here.
- No Unity-authored .unity scene or packages-lock.json has been generated yet; do not hand-write either.
- GitHub connector allows edits and PR commentary but does not expose an Issues creation action; track task IDs here rather than manufacturing issue URLs.

## COMPLETED (with narrow evidence)
- **P00-M01-T01:** repository access, main/PR #1 readback and nine architecture docs inspected. Main `86a0ab473422531a5e2be815390c41fb9999fe51`, draft PR #1 originally `48cb648205f5230038ffda75a98e702abbd60867`. GitHub audit only; not Unity validation.
- Initial Phase 1A/1B **source authored** in PR #1, status IMPLEMENTED — UNVERIFIED. **Not** a completed playable milestone.

## DEFERRED
- Facility cascades P01-M04+, procedural generation P05, Steam and content expansion until local/remote proof; see task dependencies.
