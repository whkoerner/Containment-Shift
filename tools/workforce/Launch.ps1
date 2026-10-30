param(
    [ValidateSet('start','stop','emergency','play','feedback','status','doctor','cleanup')]
    [string]$Action='status',
    [string]$Project=(Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'ContainmentShift-Unity')
)
$ErrorActionPreference = 'Stop'
try {
    $installation = Join-Path $env:LOCALAPPDATA 'ContainmentShiftWorkforce\installation.json'
    if (-not $PSBoundParameters.ContainsKey('Project') -and (Test-Path -LiteralPath $installation -PathType Leaf)) {
        $Project = (Get-Content -LiteralPath $installation -Raw | ConvertFrom-Json).project
    }
    $python = Join-Path $Project '.workforce\venv\Scripts\python.exe'
    $entry = Join-Path $Project 'tools\workforce\agent.py'
    $config = Join-Path $Project '.workforce\config.json'
    if (-not (Test-Path -LiteralPath $python)) { throw 'Run Install.ps1 first.' }
    & $python $entry $Action --config $config
    if ($LASTEXITCODE -ne 0) { throw 'The action needs attention. Read the message above.' }
    if ($Action -in @('stop','emergency','play','doctor','cleanup')) { Read-Host 'Press Enter to close' | Out-Null }
} catch {
    Write-Host $_ -ForegroundColor Red
    Read-Host 'Press Enter to close' | Out-Null
    exit 1
}
