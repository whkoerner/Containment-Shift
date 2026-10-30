param(
    [string]$Project = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'ContainmentShift-Unity'),
    [string]$Branch = 'feat/local-workforce-20261030'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$Remote = 'https://github.com/whkoerner/Containment-Shift.git'
$logDirectory = Join-Path $env:LOCALAPPDATA 'ContainmentShiftWorkforce'
New-Item -ItemType Directory -Force -Path $logDirectory | Out-Null
$setupLog = Join-Path $logDirectory 'setup.log'
Start-Transcript -Path $setupLog -Append -Force | Out-Null
try {

function Find-Program([string]$Name, [string[]]$Candidates) {
    $found = Get-Command $Name -ErrorAction SilentlyContinue
    if ($found -and $found.Source -notmatch 'WindowsApps') { return $found.Source }
    foreach ($candidate in $Candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    }
    return $null
}
function Install-Missing([string]$Id) {
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $winget) { throw 'Open Microsoft Store, install App Installer, then run setup again.' }
    & $winget.Source install --id $Id --exact --source winget --accept-source-agreements --accept-package-agreements --silent
    if ($LASTEXITCODE -ne 0) { throw "Install failed for $Id. Install it normally and run setup again." }
}
function Git {
    param([Parameter(ValueFromRemainingArguments=$true)][string[]]$GitArgs)
    & $script:GitExe -C $Project @GitArgs
    if ($LASTEXITCODE -ne 0) { throw ('Git failed: ' + ($GitArgs -join ' ')) }
}

Write-Host 'Containment Shift workforce setup. Your old AI workspace will remain read-only.'
$GitExe = Find-Program 'git' @("$env:ProgramFiles\Git\cmd\git.exe", "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe")
if (-not $GitExe) {
    Install-Missing 'Git.Git'
    $GitExe = Find-Program 'git' @("$env:ProgramFiles\Git\cmd\git.exe", "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe")
}
if (-not $GitExe) { throw 'Git was installed. Close this window and run setup again to refresh Windows paths.' }
$gitDirectory = Split-Path -Parent $GitExe
$env:PATH = "$gitDirectory;$env:PATH"

$Python = Find-Program 'python' @("$env:LOCALAPPDATA\Programs\Python\Python312\python.exe", "$env:ProgramFiles\Python312\python.exe")
if ($Python) {
    & $Python -c 'import sys; assert (3,10) <= sys.version_info < (3,14)'
    if ($LASTEXITCODE -ne 0) { $Python = $null }
}
if (-not $Python) {
    Install-Missing 'Python.Python.3.12'
    $Python = Find-Program 'python' @("$env:LOCALAPPDATA\Programs\Python\Python312\python.exe", "$env:ProgramFiles\Python312\python.exe")
}
if (-not $Python) { throw 'Python was installed. Close this window and run setup again.' }

$Project = [IO.Path]::GetFullPath($Project)
$protected = [IO.Path]::GetFullPath((Join-Path $env:LOCALAPPDATA 'ContainmentShiftAgent'))
if ($Project.Equals($protected, [StringComparison]::OrdinalIgnoreCase) -or
    $Project.StartsWith($protected + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Choose a checkout outside the old AI workspace.' }
$unityProcess = Get-CimInstance Win32_Process -Filter "Name = 'Unity.exe'" | Where-Object {
    $_.CommandLine -and $_.CommandLine.IndexOf($Project, [StringComparison]::OrdinalIgnoreCase) -ge 0
}
if ($unityProcess -or (Test-Path -LiteralPath (Join-Path $Project 'Temp\UnityLockfile'))) {
    throw 'Close this Unity project, then run setup again. No processes were killed or locks deleted.'
}
if (-not (Test-Path -LiteralPath $Project)) {
    $parent = Split-Path -Parent $Project
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    & $GitExe clone --branch $Branch --single-branch $Remote $Project
    if ($LASTEXITCODE -ne 0) { throw 'Git clone failed. Check your internet connection.' }
} else {
    if (-not (Test-Path -LiteralPath (Join-Path $Project '.git'))) { throw "The folder already exists without Git. Preserved everything: $Project. Choose a separate checkout with -Project." }
    $origin = (& $GitExe -C $Project remote get-url origin | Out-String).Trim()
    if ($origin -notin @($Remote, $Remote.Replace('.git', ''), 'git@github.com:whkoerner/Containment-Shift.git')) { throw "Wrong origin: $origin" }
    $dirty = (& $GitExe -C $Project status --porcelain | Out-String).Trim()
    if ($dirty) { throw "Your checkout has uncommitted changes. Everything is preserved. Commit your changes in GitHub Desktop, then run setup again. Folder: $Project" }
    Git @('fetch', 'origin', ($Branch + ':refs/remotes/origin/' + $Branch))
    $setupBranch = 'agent/setup-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + ([guid]::NewGuid().ToString('N').Substring(0,6))
    Git @('switch', '-c', $setupBranch)
    & $GitExe -C $Project merge --no-edit ('origin/' + $Branch)
    if ($LASTEXITCODE -ne 0) {
        & $GitExe -C $Project merge --abort
        throw 'Your branch differs from this setup. The merge was aborted and your existing files were preserved. Share this message for a targeted update.'
    }
}

$stateDirectory = Join-Path $Project '.workforce'
New-Item -ItemType Directory -Force -Path $stateDirectory | Out-Null
$Runtime = Join-Path $Project 'tools\workforce'
$venv = Join-Path $stateDirectory 'venv'
if (-not (Test-Path -LiteralPath (Join-Path $venv 'Scripts\python.exe'))) {
    & $Python -m venv $venv
    if ($LASTEXITCODE -ne 0) { throw 'Python virtual environment creation failed.' }
}
$Python = Join-Path $venv 'Scripts\python.exe'
& $Python -m pip install --disable-pip-version-check -r (Join-Path $Runtime 'requirements.txt')
if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed.' }
Write-Host 'Testing recovery, stop controls, feedback and Git protection on this Windows computer...'
& $Python -m unittest discover -s $Runtime -p test_agent.py -v
if ($LASTEXITCODE -ne 0) { throw 'Local runtime tests failed. Setup stopped before creating shortcuts. Share the errors above.' }

$configPath = Join-Path $stateDirectory 'config.json'
if (-not (Test-Path -LiteralPath $configPath)) {
    @{project=$Project; remote=$Remote; model=''; ollama='http://127.0.0.1:11434'; profile='Balanced';
      unity=''; scene='Assets/ContainmentShift/Scenes/Annex_Greybox.unity'; push=$true;
      max_hours=8; max_attempts=3; feedback_folders=@()} | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 -LiteralPath $configPath
}
$identity = (& $GitExe -C $Project config user.email | Out-String).Trim()
if (-not $identity) {
    # Use the repository owner's public GitHub noreply identity only for this checkout.
    Git @('config', 'user.name', 'Wyatt Koerner')
    Git @('config', 'user.email', '267839055+whkoerner@users.noreply.github.com')
}

. (Join-Path $Runtime 'Create-Shortcuts.ps1')
$shortcuts = New-WorkforceShortcuts -Project $Project -OpenControls
Write-Host 'Verified all six desktop shortcuts. The controls folder is now open.' -ForegroundColor Green
Write-Host ('Desktop: ' + $shortcuts.DesktopDirectory)
Write-Host ('Controls folder: ' + $shortcuts.ControlsDirectory)

$ollamaExe = Find-Program 'ollama' @("$env:LOCALAPPDATA\Programs\Ollama\ollama.exe")
if (-not $ollamaExe) {
    try { Install-Missing 'Ollama.Ollama' }
    catch { Write-Host ('Your shortcuts are ready; Ollama still needs installation: ' + $_.Exception.Message) -ForegroundColor Yellow }
    $ollamaExe = Find-Program 'ollama' @("$env:LOCALAPPDATA\Programs\Ollama\ollama.exe")
}
try { $null = Invoke-RestMethod 'http://127.0.0.1:11434/api/tags' -TimeoutSec 5 }
catch { Write-Host 'Open Ollama from your Start menu before clicking Start. Setup will still create your controls.' }

Write-Host ''
Write-Host 'Setup finished. Six desktop shortcuts are ready.' -ForegroundColor Green
Write-Host 'Click START CONTAINMENT SHIFT AGENT. The dashboard will report any missing Unity Editor or local coding model.'
Write-Host "Project: $Project"
Write-Host "Settings: $configPath"
& $Python (Join-Path $Runtime 'agent.py') doctor --config $configPath
if ($LASTEXITCODE -ne 0) { Write-Host 'The diagnostic above names the remaining local setup step. The agent has not claimed gameplay is verified.' }
} catch {
    Write-Host ('Setup stopped: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host ("Setup log: $setupLog")
    Write-Host 'If shortcuts are absent, setup did not finish. Copy the error above so it can be repaired.'
    exit 1
} finally {
    Stop-Transcript | Out-Null
}
