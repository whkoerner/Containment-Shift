param(
    [string]$Project = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'ContainmentShift-Unity')
)
$ErrorActionPreference = 'Stop'
try {
    . (Join-Path $PSScriptRoot 'Create-Shortcuts.ps1')
    $result = New-WorkforceShortcuts -Project $Project -OpenControls
    Write-Host 'Verified all six controls on your Desktop and in the folder just opened.' -ForegroundColor Green
    Write-Host ('Desktop: ' + $result.DesktopDirectory)
    Write-Host ('Controls: ' + $result.ControlsDirectory)
    Write-Host 'Double-click VIEW AGENT STATUS in that folder to view progress.'
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
