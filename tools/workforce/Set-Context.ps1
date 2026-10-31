param(
    [string]$Project = '',
    [string]$RuntimeFile = (Join-Path $PSScriptRoot 'agent.py')
)

function Set-WorkforceContext {
    [CmdletBinding()]
    param([string]$Project = '', [Parameter(Mandatory=$true)][string]$RuntimeFile)
    $ErrorActionPreference = 'Stop'
    $PSNativeCommandUseErrorActionPreference = $false
    if (-not $Project) {
        $installation = Join-Path $env:LOCALAPPDATA 'ContainmentShiftWorkforce\installation.json'
        if (-not (Test-Path -LiteralPath $installation -PathType Leaf)) { throw 'Complete workforce setup first; installation record is missing.' }
        $Project = (Get-Content -LiteralPath $installation -Raw | ConvertFrom-Json).project
    }
    $Project = [IO.Path]::GetFullPath($Project)
    $runtime = Join-Path $Project 'tools\workforce\agent.py'
    $configPath = Join-Path $Project '.workforce\config.json'
    $python = Join-Path $Project '.workforce\venv\Scripts\python.exe'
    foreach ($file in @($runtime, $configPath, $python, $RuntimeFile)) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Required file is missing: $file" }
    }
    function Get-ContextRuntimeHash {
        param([string]$Path)
        $text = [IO.File]::ReadAllText($Path).Replace("`r`n", "`n")
        $sha = [Security.Cryptography.SHA256]::Create()
        try { return ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($text)))).Replace('-', '').ToLowerInvariant() }
        finally { $sha.Dispose() }
    }
    $previousHash = 'b3bda7525e0a82803cac562b4162f75abbf782ab63da3c7f0fa5e0529038eeab'
    $payloadHash = '1bfc01039cc8c3390ef048383b91d39b57f54b803a8f2765719b19a977639462'
    if ((Get-ContextRuntimeHash -Path $RuntimeFile) -ne $payloadHash) { throw 'The bundled controller does not match this reviewed update. Download the complete update ZIP again.' }
    $currentHash = Get-ContextRuntimeHash -Path $runtime
    if ($currentHash -notin @($previousHash, $payloadHash)) { throw 'Your controller has other changes. Preserved it; use a targeted update rather than overwriting it.' }
    if (Test-Path -LiteralPath (Join-Path $Project '.workforce\owner.json')) {
        throw 'Click Stop and Save, wait for Supervisor alive: False, and close the old status window before applying this update.'
    }
    $git = Get-Command git -CommandType Application -All -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $git) { throw 'Git is not available in this window. Run setup to repair its executable path.' }
    $GitExe = $git.Source
    function Invoke-ContextGit {
        param([string[]]$Arguments)
        $ErrorActionPreference = 'Continue'
        $output = @(& $GitExe -C $Project @Arguments 2>&1)
        $code = $LASTEXITCODE
        $ErrorActionPreference = 'Stop'
        if ($code -ne 0) { throw ('Git update failed: ' + ($Arguments -join ' ') + "`n" + ($output -join "`n")) }
        return ($output -join "`n").Trim()
    }
    $root = Invoke-ContextGit -Arguments @('rev-parse', '--show-toplevel')
    if ([IO.Path]::GetFullPath($root) -ne $Project) { throw 'The selected project is not the expected Git root.' }
    $branch = Invoke-ContextGit -Arguments @('branch', '--show-current')
    if ($branch -notlike 'agent/*') { throw 'The updater requires the dedicated agent branch. It will not alter a shared/stable branch.' }
    $null = Invoke-ContextGit -Arguments @('ls-files', '--error-unmatch', '--', 'tools/workforce/agent.py')
    if (Invoke-ContextGit -Arguments @('diff', '--cached', '--name-only', '--', 'tools/workforce/agent.py')) {
        throw 'The controller has staged changes. Preserved them; review that file before updating.'
    }

    $lock = [IO.File]::Open((Join-Path $Project '.workforce\instance.lock'), [IO.FileMode]::OpenOrCreate,
                          [IO.FileAccess]::ReadWrite, [IO.FileShare]::ReadWrite)
    $locked = $false
    $mutated = $false
    $committed = $false
    $beforeRuntime = [IO.File]::ReadAllBytes($runtime)
    $beforeConfig = [IO.File]::ReadAllBytes($configPath)
    try {
        try { $lock.Lock(0, 1); $locked = $true }
        catch { throw 'The agent still owns the project. Use Stop and Save, wait for it to exit, then retry.' }
        if (Test-Path -LiteralPath (Join-Path $Project '.workforce\owner.json')) { throw 'The agent is starting or stopping. Wait for it to exit before updating.' }
        $config = [IO.File]::ReadAllText($configPath) | ConvertFrom-Json
        $config | Add-Member -NotePropertyName num_ctx -NotePropertyValue 32768 -Force
        $timeout = 900
        if ($config.PSObject.Properties.Name -contains 'inference_timeout') { $timeout = [Math]::Max(900, [int]$config.inference_timeout) }
        $config | Add-Member -NotePropertyName inference_timeout -NotePropertyValue $timeout -Force
        $staging = Join-Path $Project '.workforce\context-update'
        New-Item -ItemType Directory -Force -Path $staging | Out-Null
        $nextRuntime = Join-Path $staging 'agent.next.py'
        $nextConfig = Join-Path $staging 'config.next.json'
        Copy-Item -LiteralPath $RuntimeFile -Destination $nextRuntime -Force
        $utf8 = New-Object Text.UTF8Encoding($false)
        [IO.File]::WriteAllText($nextConfig, ($config | ConvertTo-Json -Depth 50), $utf8)
        & $python -m py_compile $nextRuntime
        if ($LASTEXITCODE -ne 0) { throw 'Updated controller failed Python compilation; the installed runtime was preserved.' }
        foreach ($entry in @(@{Path=(Join-Path $staging 'agent.previous.py'); Bytes=$beforeRuntime},
                              @{Path=(Join-Path $staging 'config.previous.json'); Bytes=$beforeConfig})) {
            if (-not (Test-Path -LiteralPath $entry.Path)) { [IO.File]::WriteAllBytes($entry.Path, $entry.Bytes) }
        }
        $mutated = $true
        [IO.File]::Copy($nextRuntime, $runtime, $true)
        [IO.File]::Copy($nextConfig, $configPath, $true)
        $changed = Invoke-ContextGit -Arguments @('diff', '--name-only', 'HEAD', '--', 'tools/workforce/agent.py')
        if ($changed) {
            # Commit only this reviewed controller. Preserve all other staged and untracked work.
            $null = Invoke-ContextGit -Arguments @('commit', '--only', '-m', 'feat: support configurable 32K agent context', '--', 'tools/workforce/agent.py')
            $committed = $true
        }
        $revision = Invoke-ContextGit -Arguments @('rev-parse', 'HEAD')
        @{num_ctx=32768; branch=$branch; commit=$revision; runtime_hash=$payloadHash; time_utc=[DateTime]::UtcNow.ToString('o')} |
            ConvertTo-Json | Set-Content -LiteralPath (Join-Path $staging 'result.json') -Encoding UTF8
        return [pscustomobject]@{Project=$Project; RequestedContext=32768; InferenceTimeout=$timeout; Commit=$revision}
    } catch {
        if ($mutated -and -not $committed) {
            [IO.File]::WriteAllBytes($runtime, $beforeRuntime)
            [IO.File]::WriteAllBytes($configPath, $beforeConfig)
        }
        throw
    } finally {
        if ($locked) { $lock.Unlock(0, 1) }
        $lock.Dispose()
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    try {
        $result = Set-WorkforceContext -Project $Project -RuntimeFile $RuntimeFile
        Write-Host 'Agent context configured: 32768 tokens (32K).' -ForegroundColor Green
        Write-Host ('Project: ' + $result.Project)
        Write-Host 'Use your normal START CONTAINMENT SHIFT AGENT shortcut next.'
        Write-Host 'During local inference, run ollama ps: check CONTEXT=32768 and PROCESSOR for GPU placement.'
        Write-Host '32K needs more memory; full GPU placement still requires verification on your laptop.'
    } catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}
