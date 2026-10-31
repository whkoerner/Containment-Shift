param([Parameter(Mandatory=$true)][string]$RequestFile)
$ErrorActionPreference = 'Stop'
try {
    $request = Get-Content -LiteralPath $RequestFile -Raw | ConvertFrom-Json
    $command = Get-Command opencode -CommandType Application -All -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $command) { throw 'OpenCode is missing from PATH. Open the same environment used by your working OpenCode shortcut.' }
    $env:OPENCODE_CONFIG_CONTENT = $request.config | ConvertTo-Json -Depth 50 -Compress
    $env:OPENCODE_DISABLE_AUTOUPDATE = 'true'
    $promptFile = Join-Path (Split-Path -Parent $RequestFile) 'opencode-prompt.txt'
    [IO.File]::WriteAllText($promptFile, [string]$request.prompt, (New-Object Text.UTF8Encoding($false)))
    $arguments = @('run', 'Execute the attached task instructions now using your actual tools.', '--format', 'json', '--model', [string]$request.model, '--agent', 'build', '--auto', '--file', $promptFile)
    & $command.Source @arguments
    exit $LASTEXITCODE
} catch { Write-Error $_; exit 1 }
