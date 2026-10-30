# Third-party notices / integration register

This file is a gate and a record. Listing a candidate does **not** mean its
code or assets have been imported.

| Source | License verified from repository | Imported? | Integration status |
|---|---|---|---|
| https://github.com/Showerss/unity-first-person-controller | MIT, copyright Phillip Banky (2026) | No | Movement reference candidate; do not import until current input/spawn failure diagnosed. |
| https://github.com/nicholas-maltbie/OpenKCC | MIT, copyright Nicholas Maltbie (2023) | No | Alternate architecture reference; old package dependencies require compatibility review. |
| https://github.com/Unity-Technologies/U6-First-Person-Multiplayer | Unity Companion License (2026) | No | Reference only; dependent assets and Unity-only scope require review. |
| https://github.com/CoplayDev/unity-mcp | MIT, copyright CoplayDev (2025) | No | Possible editor automation, not installed. |
| https://github.com/Inspiaaa/UnityHFSM | MIT (2020) | No | Future enemy FSM candidate. |

When any code/assets are actually integrated, add exact pinned revision,
package/dependency versions, files, copyright notices, attribution and the
license text as required by the license. Confirm commercial use and independent
asset licensing before shipping or redistributing. Unity Asset Store and
proprietary game content are not automatically open-source or redistributable.

The Windows Unity import does **not** audit licensing comprehensively. Do not
publish unlicensed third-party content in this public repository.

## Local workforce dependencies and reviewed alternatives — October 30, 2026

| Source | Exact inspected revision | License and decision |
|---|---|---|
| https://github.com/giampaolo/psutil | `714a292bd14cf0c28b9454d34f5afc26dbb9b0dc` (`release-7.2.2`) | BSD-3-Clause; runtime dependency pinned to PyPI `psutil==7.2.2`; provides process identity, descendant enumeration, CPU/RAM/disk information. No package source vendored. License included at `tools/workforce/licenses/psutil.txt`. |
| https://github.com/ollama/ollama | `f9323416f0c3f84d82f6c4a7bde75b717448bd44` | MIT; existing local service used via documented HTTP API. API documentation inspected, no server code vendored or forcibly upgraded. Model licenses remain independent and must be checked for the installed model. |
| https://github.com/Aider-AI/aider | `5dc9490bb35f9729ef2c95d00a19ccd30c26339c` | Apache-2.0 verified from LICENSE.txt. Existing editing architecture inspected first. Not installed: this initial controller needs exact file restrictions and a small dependency footprint; bounded JSON edits avoid giving a worker shell/runtime access. No Aider code copied. |
| https://github.com/CoplayDev/unity-mcp | `81542a7e86292b5c4c21b1782c5af23b567f45ce` | MIT license verified. Deferred: requires interactive Editor/server setup; batch entry points suffice for the initial scene checks. No MCP package imported. |
| https://github.com/Unity-Technologies/InputSystem | `54b1581acb600c1f00998505af19a644795ef9b8` | Official installation documentation consulted for backend/define behavior. No sample code or assets copied. Existing installed package stays `1.20.1`. |

The workforce adds original glue for scheduling, checkpoints, atomic patches,
feedback, desktop controls and batch verification. It builds on Git, Python,
psutil, the installed Ollama service and the existing Unity prototype. The
research register records compatibility gaps instead of claiming metadata proves
Unity compatibility. No third-party controllers, destruction, voice or AI
frameworks have been added. The game itself has not been relicensed by this work.
