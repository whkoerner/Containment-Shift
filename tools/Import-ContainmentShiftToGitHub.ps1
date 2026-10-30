#requires -Version 5.1
<#
Containment Shift: guarded, one-way Unity project import into GitHub.
Runs on the user's Windows PC, not inside ChatGPT.
Never writes to the ContainmentShiftAgent workspace or its source Unity project.
Only deletes a known, obsolete audit helper after a verified successful push.
#>
[CmdletBinding()]
param(
    [string] $SourceProject = '',
    [string] $Checkout = (Join-Path $env:USERPROFILE 'Documents\ContainmentShift-Unity')
)
$ErrorActionPreference = 'Stop'
$Repo = 'https://github.com/whkoerner/Containment-Shift.git'
$Branch = 'integration/unity-import-20261030'
$Stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'

function Assert-UnityProject([string]$Path) {
    return ((Test-Path -LiteralPath (Join-Path $Path 'Assets') -PathType Container) -and
            (Test-Path -LiteralPath (Join-Path $Path 'Packages\manifest.json') -PathType Leaf) -and
            (Test-Path -LiteralPath (Join-Path $Path 'ProjectSettings\ProjectVersion.txt') -PathType Leaf))
}
function Run-Git([string[]]$Arguments) {
    & git @Arguments
    if ($LASTEXITCODE -ne 0) { throw "git failed (exit $LASTEXITCODE): git $($Arguments -join ' ')" }
}
function Full-Path([string]$Path) { return [IO.Path]::GetFullPath($Path).TrimEnd('\') }

Write-Host 'Containment Shift - guarded project deployment' -ForegroundColor Cyan
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git for Windows is required. Install Git, then run this script again.' }

# Discovery is read-only. Explicit source takes precedence, otherwise prefer the intended checkout.
$Candidates = New-Object 'System.Collections.Generic.List[string]'
if ($SourceProject) { $Candidates.Add($SourceProject) }
else {
    $Candidates.Add($Checkout)
    $Candidates.Add((Join-Path $env:USERPROFILE 'Downloads\ContainmentShift_AI_NightKit\ContainmentShift_AI_NightKit\Game'))
    $AgentRoot = Join-Path $env:LOCALAPPDATA 'ContainmentShiftAgent'
    if (Test-Path -LiteralPath $AgentRoot) {
        Get-ChildItem -LiteralPath $AgentRoot -Directory -Filter 'Work-*' -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            ForEach-Object { $Candidates.Add((Join-Path $_.FullName 'Project')) }
    }
}
$Source = $Candidates | Where-Object { Assert-UnityProject $_ } | Select-Object -First 1
if (-not $Source) { throw "No valid Unity project found. Run again with -SourceProject 'C:\path\to\your\Game' (must contain Assets, Packages/manifest.json, ProjectSettings/ProjectVersion.txt)." }
$Source = Full-Path $Source
Write-Host "SOURCE (never modified): $Source"
Write-Host ('Unity editor pin: ' + ((Get-Content -LiteralPath (Join-Path $Source 'ProjectSettings\ProjectVersion.txt') -TotalCount 1) -join ''))

# Never replace the live Unity project or a non-Git directory with the Git clone.
$Target = Full-Path $Checkout
if (Assert-UnityProject $Target) { $Target = "$Target-GitHub" }
if ((Test-Path -LiteralPath $Target) -and -not (Test-Path -LiteralPath (Join-Path $Target '.git'))) {
    $Target = "$Target-GitHub"
}
if ((Test-Path -LiteralPath $Target) -and -not (Test-Path -LiteralPath (Join-Path $Target '.git'))) {
    throw "Safe checkout destination already exists and is not a Git repo: $Target. Do not delete it; choose a different -Checkout location."
}
Write-Host "GITHUB CHECKOUT: $Target"

# Safety gate: this GitHub repository is PUBLIC. No unreviewed third-party asset folders.
$Suspicious = @(Get-ChildItem -LiteralPath (Join-Path $Source 'Assets') -Directory -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^(AssetStore|ThirdParty|Third.Party|External|Downloaded|Purchased|Marketplace|StoreAssets)$' } |
    Select-Object -ExpandProperty FullName)
$UnsafeFiles = @(Get-ChildItem -LiteralPath (Join-Path $Source 'Assets') -File -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Extension -in @('.unitypackage', '.dll', '.exe', '.pfx', '.pem', '.key') -or $_.Name -match '(?i)(secret|credentials|\.env$)' } |
    Select-Object -ExpandProperty FullName)
if ($Suspicious.Count -gt 0 -or $UnsafeFiles.Count -gt 0) {
    Write-Warning 'Potentially restricted or sensitive files detected. Import was stopped BEFORE copying or pushing.'
    $Suspicious + $UnsafeFiles | ForEach-Object { Write-Host "  $_" }
    throw 'Review licensing and confidential material, move excluded files out of the publishable source copy, then rerun. Original source was not changed.'
}
$LargeFiles = @(Get-ChildItem -LiteralPath (Join-Path $Source 'Assets') -File -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -ge 90MB } | Select-Object -ExpandProperty FullName)
if ($LargeFiles.Count -gt 0) { $LargeFiles | ForEach-Object { Write-Warning "Large file: $_" }; throw 'Resolve files >=90 MB (for example, with Git LFS) before importing.' }

Write-Warning 'The target GitHub repository is PUBLIC. Upload only your own assets, or assets with redistribution permission. Paid Asset Store content and proprietary game code must NOT be redistributed.'
$Confirmation = Read-Host 'Type PUBLISH to confirm that ALL selected Assets, Packages, and ProjectSettings files are permitted to be published'
if ($Confirmation -cne 'PUBLISH') { throw 'Cancelled safely; no files copied or pushed.' }

if (-not (Test-Path -LiteralPath $Target)) {
    $Parent = Split-Path -Parent $Target
    if (-not (Test-Path -LiteralPath $Parent)) { New-Item -ItemType Directory -Path $Parent -Force | Out-Null }
    Run-Git @('clone', '--branch', $Branch, '--single-branch', $Repo, $Target)
} else {
    $ActualRemote = ((& git -C $Target remote get-url origin) | Select-Object -First 1)
    if ($LASTEXITCODE -ne 0 -or ($ActualRemote -notmatch '(?i)(github\.com[:/])whkoerner/Containment-Shift(\.git)?$')) {
        throw "Not the approved GitHub repo: $Target ($ActualRemote)"
    }
    $Dirty = @(& git -C $Target status --porcelain)
    if ($LASTEXITCODE -ne 0 -or $Dirty.Count -gt 0) { throw "Checkout has uncommitted changes; preserved untouched: $Target" }
    Run-Git @('-C', $Target, 'fetch', 'origin', $Branch)
    $LocalBranch = @(& git -C $Target branch --list $Branch)
    if ($LocalBranch.Count -gt 0) { Run-Git @('-C', $Target, 'switch', $Branch) }
    else { Run-Git @('-C', $Target, 'switch', '-c', $Branch, '--track', "origin/$Branch") }
    Run-Git @('-C', $Target, 'pull', '--ff-only', 'origin', $Branch)
}

# Import entire Unity source directories with every .meta, but never Library, Temp,
# Logs, Obj, Builds, UserSettings, .vs, or any local Agent workspace content.
foreach ($Folder in @('Assets', 'Packages', 'ProjectSettings')) {
    $Destination = Join-Path $Target $Folder
    if (Test-Path -LiteralPath $Destination) {
        throw "Destination '$Destination' already exists. No overwrite was attempted. Use a new clean checkout for another import."
    }
    Copy-Item -LiteralPath (Join-Path $Source $Folder) -Destination $Destination -Recurse
}

# Detect source manifests that rely on absolute/local packages.
try {
    $Manifest = Get-Content -LiteralPath (Join-Path $Source 'Packages\manifest.json') -Raw | ConvertFrom-Json
    $LocalDependencies = @($Manifest.dependencies.PSObject.Properties | Where-Object { "$($_.Value)" -match '^(file:|[A-Za-z]:\\)' })
    if ($LocalDependencies.Count -gt 0) {
        $LocalDependencies | ForEach-Object { Write-Warning "Local dependency requires manual follow-up: $($_.Name) = $($_.Value)" }
    }
} catch { Write-Warning "Package manifest warning: $($_.Exception.Message)" }

$ProgressPath = Join-Path $Target 'DEVELOPMENT_PROGRESS.md'
if (-not (Test-Path -LiteralPath $ProgressPath)) { Set-Content -LiteralPath $ProgressPath -Value '# Containment Shift development progress' -Encoding UTF8 }
Add-Content -LiteralPath $ProgressPath -Value @"

## GitHub Unity import - $Stamp
- Source: Local Unity project (read-only; private path deliberately omitted).
- Local Git checkout: See deployment terminal output (private path not committed).
- Commit: see Git history for this import.
- Imported: Assets/, Packages/, ProjectSettings/ (including .meta files).
- Excluded: Library/, Temp/, Obj/, Logs/, UserSettings/, local AI workspace metadata.
- Compilation: NOT RUN. Unity Play Mode: NOT RUN. Networking: NOT RUN.
- Next: open this checkout through Unity Hub, compile and test movement.
"@

Run-Git @('-C', $Target, 'add', '--', 'Assets', 'Packages', 'ProjectSettings', 'DEVELOPMENT_PROGRESS.md')
$Staged = @(& git -C $Target diff --cached --name-only)
if ($LASTEXITCODE -ne 0 -or $Staged.Count -eq 0) { throw 'No project changes were staged; nothing was pushed.' }
Write-Host ('Staged ' + $Staged.Count + ' paths.')
Run-Git @('-C', $Target, 'commit', '-m', 'Import existing Unity game project with metadata (runtime unverified)')
Run-Git @('-C', $Target, 'push', '--set-upstream', 'origin', $Branch)
$LocalSHA = ((& git -C $Target rev-parse HEAD) | Select-Object -First 1).Trim()
$RemoteSHA = ((& git -C $Target ls-remote origin "refs/heads/$Branch") | Select-Object -First 1) -split '\s+'
if ($LASTEXITCODE -ne 0 -or $RemoteSHA[0] -ne $LocalSHA) { throw 'Push returned but the remote commit could not be verified. No cleanup performed.' }
Write-Host "REMOTE VERIFIED: $LocalSHA" -ForegroundColor Green
Write-Host "Open Unity Hub -> Add project from disk -> $Target" -ForegroundColor Green
Write-Host "GitHub: https://github.com/whkoerner/Containment-Shift/tree/$Branch" -ForegroundColor Green

# Storage cleanup: remove only the previous generated audit helper, after verified push.
# Do not delete game sources, checkout, source assets, backups, or unknown downloads.
$Obsolete = Join-Path $env:USERPROFILE 'Downloads\ContainmentShift_ReadOnly_Audit.ps1'
if (Test-Path -LiteralPath $Obsolete -PathType Leaf) {
    try { Remove-Item -LiteralPath $Obsolete -Force; Write-Host "Removed superseded helper: $Obsolete" }
    catch { Write-Warning "Could not remove old helper: $($_.Exception.Message)" }
}
# This helper is disposable; try to remove the downloaded copy after successful deployment.
if ($PSCommandPath -and ((Full-Path $PSCommandPath) -eq (Full-Path (Join-Path $env:USERPROFILE 'Downloads\Import-ContainmentShiftToGitHub.ps1')))) {
    try { Remove-Item -LiteralPath $PSCommandPath -Force; Write-Host 'Removed the completed import helper from Downloads.' }
    catch { Write-Warning 'Import succeeded; delete the helper from Downloads whenever convenient.' }
}
Write-Host 'Cleanup complete. Original Unity game and AI workspace remain untouched.' 