# AI developer handoff — Containment Shift

1. Read README.md and docs/architecture/FIRST_VERTICAL_SLICE.md, then DECISIONS.md, NOT_RUN.md and TEST_RESULTS.md before edits.
2. Repository is solely whkoerner/Containment-Shift. Do not touch Rocky/Chordic repositories.
3. Keep main stable; use focused branches + PRs; do not merge without a verified Unity import/build or explicit owner approval.
4. Do not confuse source presence with compiled/playable behavior. Every PR must state IMPLEMENTED — UNVERIFIED, TESTED, PARTIAL, BLOCKED, etc., and include actual test evidence.
5. Engine project lives in UnityProject/. Commit Assets/.meta, Packages/, ProjectSettings/; ignore Unity caches. Keep precise editor/package pin evidence.
6. World gameplay state authority belongs to server. The local Phase 1A/1B scripts are disposable/adaptable presentation prototypes ONLY; no networked/world-damage code should depend directly on their toggle state.
7. Facility Domain must remain pure C# and independent of UnityEngine/FishNet; real networking awaits Gate A SDK spike and multi-process proof.
8. Maintain stable IDs, revisions and typed commands in authoritative systems; no client-only damage, repair, rewards or prop authority. Never introduce a second networking SDK in the production project.
9. Begin by running the Unity generator menu; inspect generated scene in the Editor, then save and commit scene plus .meta in a separate PR after validation.
10. Never invent measurements or green test results. Record precise editor versions, console logs and peers in docs/TEST_RESULTS.md and docs/NOT_RUN.md. No cloud secrets in repo.

