# Containment Shift — architecture decision

Review date: 2026-10-08. Status: PLANNED architecture; implementation and runtime validation NOT TESTED.

## Decision

Proceed with **Unity 6.3 LTS, URP, C#, host-authoritative co-op, FishNet provisionally, and a pure-C# facility simulation**. Approve only the risk-proving vertical slice. Do not approve full production until its gates pass. This is a feasible direction for a bounded indie game; the entire long-term feature list is not an achievable first release specification.

The product promise should be interacting facility systems and readable cascading failures. Destruction is an input to those systems, not an obligation to fracture every surface. Keep a convincing industrial shell, authored breakable sections, and systemic consequences even where geometry cannot be destroyed.

## Unity versus Unreal for this project

| Criterion | Unity | Unreal | Judgment |
|---|---|---|---|
| Small-team, AI-assisted implementation | C# domain code, unit-testable libraries, text-serialized assets | C++ plus Blueprint/editor asset workflows | Unity fits the intended implementation workflow; AI still needs actual Editor/build access |
| Physics/destruction tooling | Requires a deliberately scoped fracture/state pipeline | Chaos provides integrated destruction tooling [3] | Unreal wins authoring convenience, not automatic multiplayer correctness |
| Networked physics | Several competing packages; must select and prove one | Integrated replication, predictive interpolation and resimulation options [4] | Unreal deserves consideration, but neither engine removes collision/latency testing |
| Visual direction | URP can serve bounded, atmospheric industrial scenes | Strong high-fidelity environment tooling | The proposed art direction does not require an engine switch |
| Source review | C# and YAML are reviewable; meshes/textures remain binary | C++ reviewable; many authored assets require editor review | Unity advantage is practical, not universal |
| Facility simulation | Custom graph/data core required | Custom graph/data core required | No decisive engine advantage |
| Commercial economics | Eligibility-based seats; Runtime Fee cancelled [5] | Standard game royalties generally 5% above $1M lifetime gross product revenue, with exclusions/programs [6] | Budget against actual terms before release; no assumed free lifetime services |

Choose Unreal instead only if a small comparative prototype demonstrates a decisive advantage for the **required** destruction/physics workload, or the team gains substantial Unreal experience. Do not switch on cinematic demos alone. Do not spend weeks implementing both engines now.

## Version policy

Unity's current official support page identifies **6.3 LTS** as the latest LTS, supported through December 2027. It also recommends supported Update releases for new projects; those are production releases, not inherently unstable. This review deliberately favors LTS to reduce dependency churn for a small team [1].

**6000.3.25f1**, released September 24, 2026, is a verified stable patch candidate [2], not a claim that no newer patch exists. Review its known issues and confirm the newest appropriate 6000.3 patch in Hub at bootstrap. Record the exact accepted editor in ProjectVersion.txt. No package compatibility is proven by this document. Schedule an LTS/support review well before December 2027 rather than freezing an unsupported engine indefinitely.

## Boundaries that prevent expensive rewrites

1. One server-owned world for offline solo and multiplayer. Solo boots the same authority locally without Steam or an Internet requirement.
2. Facility state is independent of scenes, rendering and networking SDK types. Commands in; state changes and typed events out.
3. Stable entity/content IDs, schema versions and topology revisions exist from the first slice. Never serialize Unity instance IDs as identity.
4. Physics produces authoritative observations; it is not deterministic lockstep. Seeds reproduce generation, not every collision.
5. Only the server commits damage, repairs, inventory, death, objectives, severity and progression. Cosmetic prediction cannot trigger any of these.
6. Difficulty profiles vary active dependencies and assistance within the same system schemas. Gore and camera comfort are local presentation options. Rule-changing horror settings are negotiated lobby settings.
7. Post-death control changes the player's embodiment and capability set; it does not create a second networking architecture.
8. Data-driven construction is finite: typed sockets, component tags, enumerated behavior modifiers, explicit compatibility and bounded effect budgets. No arbitrary runtime code or LLM devices.

## Project/module shape

Dependency direction: Presentation and Networking adapters → Application commands/snapshots → Domain. Unity physics and platform services implement narrow Application ports. Domain does not import UnityEngine or FishNet. Keep separate assemblies for Domain, Application, UnityRuntime, Networking.FishNet, Platform.Steam, Presentation and Tests. Do not create a framework for swapping every engine feature.

ScriptableObjects author immutable definitions; bake them to validated runtime records. MonoBehaviours bind views, colliders and input to stable IDs. Scene loading is orchestration, not the source of simulation truth. Central bootstrap owns a run-scoped world and tears it down cleanly.

## Commercial foundations

- Start Windows x64; Steam distribution later in the slice. Steam Deck/Linux and optional third person remain PLANNED, not promised support.
- Input actions from day one; rebindable controls, hold/toggle options, controller-focusable menus, scalable subtitles, redundant icon/text alarm cues. Test controller completion before calling it supported.
- Localize using message keys and arguments. Company announcements select authored lines from events with cooldown/priority rules; urgent information must remain understandable and subtitled. Original writing and licensed voice recordings only.
- Low-gore substitutes preserve hitboxes, collision and gameplay readability. Camera bob, shake, flashes, motion blur and ragdoll camera movement must be separately adjustable. Reduced horror presentation cannot change shared AI state secretly.
- Track creator, source, acquisition date, license, receipt, allowed redistribution and AI involvement for each asset/dependency. Keep restricted source assets out of public repositories. Review current Steam content-survey requirements before submission [7].
- Local structured diagnostics by default, bounded retention, explicit user action for upload. No voice recording, chat collection or persistent identity in routine logs. No runtime LLMs, embedded service secrets or unnecessary analytics SDKs.

## Evidence and scope

GitHub authentication and repository listing succeeded. At the initial review, no game repository was accessible. On the user's follow-up on 2026-10-08, whkoerner/Containment-Shift became accessible and contained only its initial README. This architecture package is being added under docs/architecture. No game code, prefab, Unity project, build or multiplayer session was created or executed. All performance figures elsewhere are proposed acceptance budgets.

Read next: FIRST_VERTICAL_SLICE.md, NETWORKING_ARCHITECTURE.md, then the system documents. INITIAL_STACK.md gives the bootstrap list; TECHNICAL_RISKS.md gives stop conditions.

## Sources checked 2026-10-08

[1] https://unity.com/releases/unity-6/support

[2] https://unity.com/releases/editor/whats-new/6000.3.25f1

[3] https://dev.epicgames.com/documentation/unreal-engine/chaos-destruction-in-unreal-engine

[4] https://dev.epicgames.com/documentation/en-us/unreal-engine/networked-physics-overview

[5] https://unity.com/products/pricing-updates

[6] https://www.unrealengine.com/license

[7] https://partner.steamgames.com/doc/gettingstarted/contentsurvey — release checklist reference; exact survey interpretation deferred to submission.
