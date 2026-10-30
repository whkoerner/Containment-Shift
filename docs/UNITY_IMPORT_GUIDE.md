# Unity source import (guarded)

GitHub `main` was documentation-only at the time this procedure was created.
The code, input assets and gameplay scenes currently live on the user's Windows PC.
Use the deployment helper on the `integration/unity-import-20261030` branch to copy the
existing Unity project's `Assets`, `Packages`, and `ProjectSettings` to GitHub.

## Run from Windows PowerShell

With Git for Windows installed, download `tools/Import-ContainmentShiftToGitHub.ps1`
from this branch and run (with the file saved to Downloads):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\Downloads\Import-ContainmentShiftToGitHub.ps1"
```

The helper searches the intended Documents checkout, the earlier Downloads game
folder, and the latest agent workspace **read-only**; if none are valid, specify
`-SourceProject 'C:\path\to\Game'`. It refuses to overwrite a live Unity
project, requires confirmation before publishing into this PUBLIC GitHub repo,
blocks obvious restricted binary/third-party files, copies all `.meta` files,
commits and pushes only after staging, verifies remote HEAD, and deletes only
its old generated read-only audit helper after success. Unknown assets and source
rights still require human review before publishing.

It may create a sibling folder named `ContainmentShift-Unity-GitHub` if the
intended checkout already contains a Unity project. This avoids overwriting
working files; do not delete the original unless the new project has been
verified in Unity and backed up appropriately.

## Reopen in Unity

Unity Hub > Add project from disk > select the printed GITHUB CHECKOUT path.
Install/use exactly the editor version printed from `ProjectVersion.txt`.
If the Editor reports missing packages, review `Packages/manifest.json` and
`Packages/packages-lock.json`; do not blindly upgrade major dependencies.
Check scripts and console before testing movement. Build success alone is not
proof that player spawning/input/NGO ownership works.

## Storage policy

Do not download the repository as repeated ZIP copies. Use `git pull --ff-only`
for subsequent updates. Clean generated Unity caches only when Unity is closed
and only as an intentional repair. The helper removes only a superseded audit
script after a verified remote push. It does not delete the original Unity
project, snapshots or assets. Old source versions live in Git history rather
than duplicate filenames.