$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
. (Join-Path $PSScriptRoot 'Set-Context.ps1')
$payload = Join-Path $PSScriptRoot 'agent.py'
$realPython = (Get-Command python -CommandType Application -All | Where-Object { $_.Source -notmatch 'WindowsApps' } | Select-Object -First 1).Source
$git = (Get-Command git -CommandType Application -All | Select-Object -First 1).Source
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('CS-Context-Test-' + [guid]::NewGuid().ToString('N'))
$project = Join-Path $fixture 'Agent Project With Spaces'
$runtime = Join-Path $project 'tools\workforce\agent.py'
$config = Join-Path $project '.workforce\config.json'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $runtime), (Split-Path -Parent $config) | Out-Null
function Invoke-ContextFixtureGit {
    param([string[]]$Arguments)
    $ErrorActionPreference = 'Continue'
    $output = @(& $git -C $project @Arguments 2>&1)
    $code = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    if ($code -ne 0) { throw ($output -join "`n") }
    return ($output -join "`n").Trim()
}
try {
    # Extract exact UTF-8 bytes of the reviewed previous controller from Git history.
    $extract = Join-Path $fixture 'extract.py'
    @'
import subprocess, sys
from pathlib import Path
Path(sys.argv[1]).write_bytes(subprocess.check_output(["git", "show", "2bcf9ff10687e61eac7c65d97adf15e3feda19c1:tools/workforce/agent.py"]))
'@ | Set-Content -LiteralPath $extract -Encoding UTF8
    & $realPython $extract $runtime
    if ($LASTEXITCODE -ne 0) { throw 'Could not extract the previous controller fixture.' }
    $oldHash = (Get-FileHash -LiteralPath $runtime).Hash
    & $realPython -m venv --without-pip (Join-Path $project '.workforce\venv')
    if ($LASTEXITCODE -ne 0) { throw 'Fixture venv creation failed.' }
    @{project=$project; model='fixture-model'; profile='Balanced'; inference_timeout=300; custom='preserve me'; num_ctx=8192} |
        ConvertTo-Json | Set-Content -LiteralPath $config -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $project '.gitignore') -Value '.workforce/'
    Set-Content -LiteralPath (Join-Path $project 'human.txt') -Value 'original'
    $null = Invoke-ContextFixtureGit -Arguments @('init', '--quiet')
    $null = Invoke-ContextFixtureGit -Arguments @('config', 'user.name', 'Context Fixture')
    $null = Invoke-ContextFixtureGit -Arguments @('config', 'user.email', 'fixture@example.invalid')
    $null = Invoke-ContextFixtureGit -Arguments @('add', '.gitignore', 'human.txt', 'tools/workforce/agent.py')
    $null = Invoke-ContextFixtureGit -Arguments @('commit', '-m', 'fixture baseline')
    $null = Invoke-ContextFixtureGit -Arguments @('switch', '-c', 'agent/context-fixture')
    Set-Content -LiteralPath (Join-Path $project 'human.txt') -Value 'staged human work'
    $null = Invoke-ContextFixtureGit -Arguments @('add', 'human.txt')
    Set-Content -LiteralPath (Join-Path $project 'untracked.txt') -Value 'private work'
    $staged = Invoke-ContextFixtureGit -Arguments @('diff', '--cached')
    $result = Set-WorkforceContext -Project $project -RuntimeFile $payload
    $settings = Get-Content -LiteralPath $config -Raw | ConvertFrom-Json
    if ($settings.num_ctx -ne 32768 -or $settings.inference_timeout -ne 900 -or $settings.custom -ne 'preserve me') { throw 'Context update lost settings or failed to enable 32K.' }
    if ((Get-FileHash -LiteralPath $runtime).Hash -ne (Get-FileHash -LiteralPath $payload).Hash) { throw 'Reviewed controller was not installed.' }
    if ($staged -ne (Invoke-ContextFixtureGit -Arguments @('diff', '--cached'))) { throw 'Unrelated staged work changed.' }
    if (-not (Test-Path -LiteralPath (Join-Path $project 'untracked.txt'))) { throw 'Untracked work was removed.' }
    $files = Invoke-ContextFixtureGit -Arguments @('show', '--pretty=format:', '--name-only', 'HEAD')
    if ($files -ne 'tools/workforce/agent.py') { throw 'Update commit included unrelated files.' }
    if ((Get-FileHash -LiteralPath (Join-Path $project '.workforce\context-update\agent.previous.py')).Hash -ne $oldHash) { throw 'Previous controller backup did not preserve exact bytes.' }
    $revision = $result.Commit
    $again = Set-WorkforceContext -Project $project -RuntimeFile $payload
    if ($again.Commit -ne $revision) { throw 'Repeat context update created an unnecessary commit.' }
    Add-Content -LiteralPath $runtime -Value '# local controller modification'
    $editedHash = (Get-FileHash -LiteralPath $runtime).Hash
    $blocked = $false
    try { $null = Set-WorkforceContext -Project $project -RuntimeFile $payload }
    catch { if ($_.Exception.Message -notlike '*other changes*') { throw }; $blocked = $true }
    if (-not $blocked -or (Get-FileHash -LiteralPath $runtime).Hash -ne $editedHash) { throw 'Custom runtime edits were overwritten.' }
    Copy-Item -LiteralPath $payload -Destination $runtime -Force
    $hold = Join-Path $fixture 'hold.py'
    $ready = Join-Path $fixture 'ready.txt'
    $lockFile = Join-Path $project '.workforce\instance.lock'
    @'
import msvcrt, sys, time
from pathlib import Path
with open(sys.argv[1], "r+b") as lock:
    msvcrt.locking(lock.fileno(), msvcrt.LK_NBLCK, 1)
    Path(sys.argv[2]).write_text("ready")
    time.sleep(60)
'@ | Set-Content -LiteralPath $hold -Encoding UTF8
    $holder = Start-Process -FilePath $realPython -ArgumentList @(('"' + $hold + '"'), ('"' + $lockFile + '"'), ('"' + $ready + '"')) -PassThru
    try {
        $deadline = [DateTime]::UtcNow.AddSeconds(10)
        while (-not (Test-Path -LiteralPath $ready) -and [DateTime]::UtcNow -lt $deadline) { Start-Sleep -Milliseconds 100 }
        if (-not (Test-Path -LiteralPath $ready)) { throw 'Fixture did not acquire the real Windows byte-range lock.' }
        $before = (Get-FileHash -LiteralPath $config).Hash
        $blocked = $false
        try { $null = Set-WorkforceContext -Project $project -RuntimeFile $payload }
        catch { if ($_.Exception.Message -notlike '*still owns the project*') { throw }; $blocked = $true }
        if (-not $blocked -or (Get-FileHash -LiteralPath $config).Hash -ne $before) { throw 'Update ignored an active agent lock.' }
    } finally {
        if (-not $holder.HasExited) { $holder.Kill(); $holder.WaitForExit() }
        $holder.Dispose()
    }
    Write-Host 'PASS: previous runtime upgraded, only reviewed code committed, settings/human edits preserved, repeat update idempotent, custom code protected, and active Python/Windows lock respected.'
} finally {
    Remove-Item -LiteralPath $fixture -Recurse -Force
    $global:LASTEXITCODE = 0
}
