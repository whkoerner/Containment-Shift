$ErrorActionPreference = 'Stop'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('CS-Overseer-Update-' + [guid]::NewGuid().ToString('N'))
$project = Join-Path $fixture 'Project With Spaces'
$runtime = Join-Path $project 'tools\workforce'
$state = Join-Path $project '.workforce'
$python = (Get-Command python -CommandType Application -All | Where-Object { $_.Source -notmatch 'WindowsApps' } | Select-Object -First 1).Source
$git = (Get-Command git -CommandType Application -All | Select-Object -First 1).Source
function FixtureGit([string[]]$Arguments) {
    $ErrorActionPreference = 'Continue'
    $out = @(& $git -C $project @Arguments 2>&1)
    $code = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    if ($code -ne 0) { throw ($out -join "`n") }
    return ($out -join "`n").Trim()
}
try {
    New-Item -ItemType Directory -Force -Path $runtime,$state | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'agent.py') -Destination $runtime
    # Extract the actual pre-overseer launcher, avoiding PowerShell text re-encoding.
    $extract = Join-Path $fixture 'extract.py'
    @'
from pathlib import Path
import subprocess,sys
Path(sys.argv[1]).write_bytes(subprocess.check_output(['git','show','d898a7041f28b3a80c811e791b4fc845b5ae384e:tools/workforce/Launch.ps1']))
'@ | Set-Content -LiteralPath $extract -Encoding UTF8
    & $python $extract (Join-Path $runtime 'Launch.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'Failed old launcher extraction.' }
    & $python -m venv --without-pip (Join-Path $state 'venv')
    if ($LASTEXITCODE -ne 0) { throw 'Failed fixture venv.' }
    @{project=$project;profile='Balanced';model='fixture';custom='keep'} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $state 'config.json') -Encoding UTF8
    '.workforce/' | Set-Content -LiteralPath (Join-Path $project '.gitignore')
    'original' | Set-Content -LiteralPath (Join-Path $project 'human.txt')
    $null=FixtureGit -Arguments @('init','--quiet')
    $null=FixtureGit -Arguments @('config','user.name','Fixture')
    $null=FixtureGit -Arguments @('config','user.email','fixture@example.invalid')
    $null=FixtureGit -Arguments @('add','.')
    $null=FixtureGit -Arguments @('commit','-m','baseline')
    $null=FixtureGit -Arguments @('switch','-c','agent/update-fixture')
    'staged human work' | Set-Content -LiteralPath (Join-Path $project 'human.txt')
    $null=FixtureGit -Arguments @('add','human.txt')
    $index=FixtureGit -Arguments @('diff','--cached')
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Install-Overseer.ps1') -Project $project
    if ($LASTEXITCODE -ne 0) { throw 'Overseer updater failed.' }
    if ((FixtureGit -Arguments @('diff','--cached')) -ne $index) { throw 'Human staged work changed.' }
    foreach ($file in @('Launch.ps1','overseer.py','Run-OpenCode.ps1')) {
        if ((Get-FileHash (Join-Path $runtime $file)).Hash -ne (Get-FileHash (Join-Path $PSScriptRoot $file)).Hash) { throw "Wrong installed $file" }
    }
    $head=FixtureGit -Arguments @('rev-parse','HEAD')
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Install-Overseer.ps1') -Project $project
    if ($LASTEXITCODE -ne 0 -or (FixtureGit -Arguments @('rev-parse','HEAD')) -ne $head) { throw 'Repeat update was not idempotent.' }
    Add-Content -LiteralPath (Join-Path $runtime 'overseer.py') -Value '# custom edit'
    $hash=(Get-FileHash (Join-Path $runtime 'overseer.py')).Hash
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Install-Overseer.ps1') -Project $project
    if ($LASTEXITCODE -eq 0 -or (Get-FileHash (Join-Path $runtime 'overseer.py')).Hash -ne $hash) { throw 'Custom overseer was overwritten.' }
    Write-Host 'PASS: old launcher migrated, payload installed, staged human work preserved, repeat idempotent, custom worker protected.'
} finally {
    Remove-Item -LiteralPath $fixture -Recurse -Force
    $global:LASTEXITCODE=0
}
