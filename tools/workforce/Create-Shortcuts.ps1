function New-WorkforceShortcuts {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Project,
        [string]$DesktopDirectory = [Environment]::GetFolderPath([Environment+SpecialFolder]::DesktopDirectory),
        [switch]$OpenControls
    )
    $ErrorActionPreference = 'Stop'
    $Project = [IO.Path]::GetFullPath($Project)
    $required = @('tools\workforce\Launch.ps1', 'tools\workforce\agent.py',
                  '.workforce\config.json', '.workforce\venv\Scripts\python.exe')
    $missing = @($required | Where-Object { -not (Test-Path -LiteralPath (Join-Path $Project $_) -PathType Leaf) })
    if ($missing.Count -gt 0) {
        throw ("Setup is incomplete at: $Project`nMissing: " + ($missing -join ', ') +
               "`nExtract the setup ZIP and run SETUP.cmd. If setup stops, copy its error message.")
    }
    if ([string]::IsNullOrWhiteSpace($DesktopDirectory)) {
        throw 'Windows did not return a physical Desktop folder. No desktop shortcuts were created.'
    }
    $desktop = [IO.Path]::GetFullPath($DesktopDirectory)
    if (-not (Test-Path -LiteralPath $desktop -PathType Container)) {
        throw "Windows Desktop folder does not exist: $desktop"
    }
    $controls = Join-Path $Project '.workforce\controls'
    New-Item -ItemType Directory -Force -Path $controls | Out-Null
    $shell = New-Object -ComObject WScript.Shell
    $target = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { throw "Windows PowerShell is missing: $target" }
    $launcher = Join-Path $Project 'tools\workforce\Launch.ps1'
    $actions = [ordered]@{
        'START CONTAINMENT SHIFT AGENT'='start'; 'STOP AND SAVE AGENT'='stop';
        'EMERGENCY STOP AGENT'='emergency'; 'PLAY CONTAINMENT SHIFT'='play';
        'SUBMIT PLAYTEST FEEDBACK'='feedback'; 'VIEW AGENT STATUS'='status'
    }
    $created = @()
    foreach ($entry in $actions.GetEnumerator()) {
        $arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $launcher +
                     '" -Action ' + $entry.Value + ' -Project "' + $Project + '"'
        foreach ($directory in @($desktop, $controls)) {
            $path = Join-Path $directory ($entry.Key + '.lnk')
            $link = $shell.CreateShortcut($path)
            $link.TargetPath = $target
            $link.Arguments = $arguments
            $link.WorkingDirectory = $Project
            $link.Description = 'Containment Shift local Ollama workforce'
            $link.Save()
            $saved = $shell.CreateShortcut($path)
            if (-not (Test-Path -LiteralPath $path -PathType Leaf) -or
                $saved.TargetPath -ne $target -or $saved.Arguments -ne $arguments -or
                $saved.WorkingDirectory -ne $Project) {
                throw "Shortcut verification failed: $path"
            }
            $created += $path
        }
    }
    $result = [pscustomobject]@{
        DesktopDirectory = $desktop
        ControlsDirectory = $controls
        DesktopShortcutCount = $actions.Count
        Shortcuts = $created
        VerifiedAtUtc = [DateTime]::UtcNow.ToString('o')
    }
    $result | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $Project '.workforce\shortcuts.json') -Encoding UTF8
    if ($OpenControls) { Start-Process explorer.exe -ArgumentList ('"' + $controls + '"') | Out-Null }
    return $result
}
