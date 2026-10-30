$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Create-Shortcuts.ps1')
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('CS-Shortcut-Test-' + [guid]::NewGuid().ToString('N'))
$project = Join-Path $fixture 'Project With Spaces'
$desktop = Join-Path $fixture 'Redirected Desktop'
New-Item -ItemType Directory -Force -Path $project, $desktop | Out-Null
try {
    # An incomplete install must fail before creating misleading launch controls.
    $blocked = $false
    try { $null = New-WorkforceShortcuts -Project $project -DesktopDirectory $desktop }
    catch { if ($_.Exception.Message -notlike '*Setup is incomplete*') { throw }; $blocked = $true }
    if (-not $blocked) { throw 'An incomplete install was reported as ready.' }
    if (@(Get-ChildItem -LiteralPath $desktop).Count -ne 0) { throw 'Incomplete install created shortcuts.' }
    foreach ($path in @('tools\workforce\Launch.ps1', 'tools\workforce\agent.py',
                        '.workforce\config.json', '.workforce\venv\Scripts\python.exe')) {
        $file = Join-Path $project $path
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $file) | Out-Null
        Set-Content -LiteralPath $file -Value 'Shortcut fixture only; never execute.'
    }
    Set-Content -LiteralPath (Join-Path $desktop 'Keep My File.txt') -Value 'untouched'
    $result = New-WorkforceShortcuts -Project $project -DesktopDirectory $desktop
    if ($result.DesktopDirectory -ne $desktop -or $result.Shortcuts.Count -ne 12) { throw 'Unexpected shortcut output.' }
    if (@(Get-ChildItem -LiteralPath $desktop -Filter '*.lnk').Count -ne 6) { throw 'Desktop shortcuts missing.' }
    if (@(Get-ChildItem -LiteralPath $result.ControlsDirectory -Filter '*.lnk').Count -ne 6) { throw 'Fallback controls missing.' }
    $shell = New-Object -ComObject WScript.Shell
    $link = $shell.CreateShortcut((Join-Path $desktop 'VIEW AGENT STATUS.lnk'))
    if ($link.Arguments -notlike '*-Action status*' -or $link.Arguments -notlike ('*-Project "' + $project + '"')) {
        throw 'Status shortcut lost action or quoted project path.'
    }
    $null = New-WorkforceShortcuts -Project $project -DesktopDirectory $desktop
    if (@(Get-ChildItem -LiteralPath $desktop -Filter '*.lnk').Count -ne 6) { throw 'Repair made duplicate shortcuts.' }
    if ((Get-Content -LiteralPath (Join-Path $desktop 'Keep My File.txt') -Raw).Trim() -ne 'untouched') { throw 'Repair altered an unrelated file.' }
    $manifest = Get-Content -LiteralPath (Join-Path $project '.workforce\shortcuts.json') -Raw | ConvertFrom-Json
    if ($manifest.DesktopShortcutCount -ne 6) { throw 'Shortcut verification report missing.' }
    Write-Host 'PASS: six real Windows shortcuts, redirected Desktop, quoted paths, fallback controls, repeat repair and incomplete-install protection.'
} finally {
    Remove-Item -LiteralPath $fixture -Recurse -Force
}
