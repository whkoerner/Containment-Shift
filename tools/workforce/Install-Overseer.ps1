param([string]$Project = '')
$ErrorActionPreference = 'Stop'
try {
    if (-not $Project) {
        $record = Join-Path $env:LOCALAPPDATA 'ContainmentShiftWorkforce\installation.json'
        $Project = (Get-Content -LiteralPath $record -Raw | ConvertFrom-Json).project
    }
    $Project = [IO.Path]::GetFullPath($Project)
    # First apply the existing tested 32K controller update, preserving unrelated work.
    . (Join-Path $PSScriptRoot 'Set-Context.ps1') -Project $Project -RuntimeFile (Join-Path $PSScriptRoot 'agent.py')
    $null = Set-WorkforceContext -Project $Project -RuntimeFile (Join-Path $PSScriptRoot 'agent.py')
    $files = @('Launch.ps1', 'overseer.py', 'Run-OpenCode.ps1')
    $manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'payload-map.json') -Raw | ConvertFrom-Json
    function Hash-OverseerFile([string]$Path) {
        $sha = [Security.Cryptography.SHA256]::Create()
        try { return ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes([IO.File]::ReadAllText($Path).Replace("`r`n", "`n"))))).Replace('-', '').ToLowerInvariant() }
        finally { $sha.Dispose() }
    }
    $git = (Get-Command git -CommandType Application -All | Select-Object -First 1).Source
    function Invoke-OverseerGit([string[]]$Arguments) {
        $ErrorActionPreference = 'Continue'
        $out = @(& $git -C $Project @Arguments 2>&1)
        $code = $LASTEXITCODE
        $ErrorActionPreference = 'Stop'
        if ($code -ne 0) { throw ($out -join "`n") }
        return ($out -join "`n").Trim()
    }
    if ((Invoke-OverseerGit -Arguments @('branch','--show-current')) -notlike 'agent/*') { throw 'Use the dedicated agent branch.' }
    $paths = @($files | ForEach-Object { 'tools/workforce/' + $_ })
    if (Invoke-OverseerGit -Arguments (@('diff','--cached','--name-only','--') + $paths)) { throw 'Update files have staged changes; preserved for your review.' }
    foreach ($file in $files) {
        $payload = Join-Path $PSScriptRoot $file
        $expected = $manifest.PSObject.Properties[$file].Value
        if ((Hash-OverseerFile $payload) -ne $expected) { throw "Incomplete update payload: $file" }
        $installed = Join-Path $Project ('tools\workforce\' + $file)
        if (Test-Path -LiteralPath $installed) {
            $hash = Hash-OverseerFile $installed
            $allowed = @($expected)
            if ($file -eq 'Launch.ps1') { $allowed += '88c3729cee0b2b6920ebb4293d50a78a1fa52ee0b1e4ed8313fb5d3a93aa55f9' }
            if ($hash -notin $allowed) { throw "Custom $file preserved. A targeted update is required." }
        }
    }
    $lock = [IO.File]::Open((Join-Path $Project '.workforce\instance.lock'), 'OpenOrCreate', 'ReadWrite', 'ReadWrite')
    $locked = $false; $committed = $false; $before = @{}
    try {
        try { $lock.Lock(0,1); $locked=$true } catch { throw 'Agent is still running. Stop and Save before updating.' }
        if (Test-Path -LiteralPath (Join-Path $Project '.workforce\owner.json')) { throw 'Agent is starting/stopping. Wait for it to finish.' }
        $backup = Join-Path $Project '.workforce\overseer-update'
        New-Item -ItemType Directory -Force -Path $backup | Out-Null
        $python = Join-Path $Project '.workforce\venv\Scripts\python.exe'
        & $python -m py_compile (Join-Path $PSScriptRoot 'overseer.py')
        if ($LASTEXITCODE -ne 0) { throw 'Overseer failed Python compilation.' }
        foreach ($file in $files) {
            $destination = Join-Path $Project ('tools\workforce\' + $file)
            if (Test-Path -LiteralPath $destination) {
                $before[$file] = [IO.File]::ReadAllBytes($destination)
                $saved = Join-Path $backup ($file + '.previous')
                if (-not (Test-Path -LiteralPath $saved)) { [IO.File]::WriteAllBytes($saved, $before[$file]) }
            } else { $before[$file] = $null }
            Copy-Item -LiteralPath (Join-Path $PSScriptRoot $file) -Destination $destination -Force
        }
        $dirty = Invoke-OverseerGit -Arguments (@('status','--porcelain','--') + $paths)
        if ($dirty) {
            # Stage ONLY the reviewed launcher/worker files; commit --only preserves other index entries.
            $null = Invoke-OverseerGit -Arguments (@('add','--') + $paths)
            $null = Invoke-OverseerGit -Arguments (@('commit','--only','-m','feat: Ollama-first OpenCode overseer','--') + $paths)
        }
        $committed = $true
    } catch {
        if (-not $committed) {
            foreach ($file in $before.Keys) {
                $destination = Join-Path $Project ('tools\workforce\' + $file)
                if ($null -eq $before[$file]) { Remove-Item -LiteralPath $destination -ErrorAction SilentlyContinue }
                else { [IO.File]::WriteAllBytes($destination, $before[$file]) }
            }
            # Clear only this updater's temporary staging; pre-existing staged paths were rejected above.
            $null = Invoke-OverseerGit -Arguments (@('reset','--') + $paths)
        }
        throw
    } finally { if ($locked) { $lock.Unlock(0,1) }; $lock.Dispose() }
    Write-Host 'OpenCode overseer installed. Use START CONTAINMENT SHIFT AGENT.' -ForegroundColor Green
    Write-Host 'Stop your separate Containment Shift AI OpenCode session first. It belongs to another project and is not controlled by this launcher.'
    Write-Host ('Active project: ' + $Project)
    Write-Host 'Startup: Ollama server -> real READY response at 32K -> overseer queue -> OpenCode attempts -> outcomes report.'
} catch { Write-Host $_.Exception.Message -ForegroundColor Red; exit 1 }
