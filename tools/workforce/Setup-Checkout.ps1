function Initialize-WorkforceCheckout {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$GitExe,
        [Parameter(Mandatory=$true)][string]$Project,
        [Parameter(Mandatory=$true)][string]$Remote,
        [Parameter(Mandatory=$true)][string]$Branch
    )
    $ErrorActionPreference = 'Stop'
    $PSNativeCommandUseErrorActionPreference = $false
    function Invoke-SetupGit {
        param([string]$Location, [string[]]$Arguments)
        # Windows PowerShell can turn native stderr progress into ErrorRecords.
        # Capture it with Continue and decide success from the native exit code.
        $ErrorActionPreference = 'Continue'
        $output = @(& $GitExe -C $Location @Arguments 2>&1)
        $code = $LASTEXITCODE
        $ErrorActionPreference = 'Stop'
        if ($code -ne 0) { throw ('Git failed: ' + ($Arguments -join ' ') + "`n" + ($output -join "`n")) }
        return ($output -join "`n").Trim()
    }
    function Assert-SetupRepository {
        param([string]$Location)
        if (-not (Test-Path -LiteralPath (Join-Path $Location '.git'))) { throw "Existing folder is not a Git checkout; preserved: $Location" }
        $actualRoot = Invoke-SetupGit -Location $Location -Arguments @('rev-parse', '--show-toplevel')
        if ([IO.Path]::GetFullPath($actualRoot) -ne [IO.Path]::GetFullPath($Location)) { throw "Not an independent checkout root: $Location" }
        $origin = Invoke-SetupGit -Location $Location -Arguments @('remote', 'get-url', 'origin')
        $normalOrigin = ($origin -replace '^git@github.com:', 'https://github.com/') -replace '\.git$', ''
        $normalRemote = ($Remote -replace '^git@github.com:', 'https://github.com/') -replace '\.git$', ''
        if ($normalOrigin -ne $normalRemote) { throw "Wrong repository at $Location; existing files preserved." }
    }
    function Get-SetupCommonDirectory {
        param([string]$Location)
        $common = Invoke-SetupGit -Location $Location -Arguments @('rev-parse', '--git-common-dir')
        if (-not [IO.Path]::IsPathRooted($common)) { $common = Join-Path $Location $common }
        return [IO.Path]::GetFullPath($common)
    }
    $source = [IO.Path]::GetFullPath($Project)
    $active = $source
    $isolated = $false
    $sourceHead = ''
    $sourceStatus = ''
    $setupBranch = 'agent/setup-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + ([guid]::NewGuid().ToString('N').Substring(0,6))
    if (-not (Test-Path -LiteralPath $source)) {
        $parent = Split-Path -Parent $source
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
        $null = Invoke-SetupGit -Location $parent -Arguments @('clone', '--branch', $Branch, '--single-branch', $Remote, $source)
        $null = Invoke-SetupGit -Location $source -Arguments @('switch', '-c', $setupBranch)
    } else {
        Assert-SetupRepository -Location $source
        if (Test-Path -LiteralPath (Join-Path $source 'Temp\UnityLockfile')) { throw 'Close Unity before running setup.' }
        if (Test-Path -LiteralPath (Join-Path $source '.workforce\owner.json')) { throw 'Stop the existing workforce before running setup.' }
        $sourceHead = Invoke-SetupGit -Location $source -Arguments @('rev-parse', 'HEAD')
        $sourceStatus = Invoke-SetupGit -Location $source -Arguments @('status', '--porcelain')
        # Fetch only changes Git refs/objects; it does not stash, stage or alter source files.
        $null = Invoke-SetupGit -Location $source -Arguments @('fetch', 'origin', ($Branch + ':refs/remotes/origin/' + $Branch))
        if ($sourceStatus) {
            $active = Join-Path (Split-Path -Parent $source) 'ContainmentShift-Workforce'
            if ($active -eq $source) { throw 'The existing workforce checkout has unsaved changes; preserved for review.' }
            $isolated = $true
            if (Test-Path -LiteralPath $active) {
                Assert-SetupRepository -Location $active
                if ((Get-SetupCommonDirectory -Location $active) -ne (Get-SetupCommonDirectory -Location $source)) {
                    throw "The reserved workforce folder belongs to another checkout; preserved: $active"
                }
                if (Test-Path -LiteralPath (Join-Path $active 'Temp\UnityLockfile')) { throw "Close the workforce project in Unity: $active" }
                if (Test-Path -LiteralPath (Join-Path $active '.workforce\owner.json')) { throw 'Stop the existing workforce before updating its checkout.' }
                if (Invoke-SetupGit -Location $active -Arguments @('status', '--porcelain')) {
                    throw "The workforce checkout itself has unsaved edits. They are preserved: $active"
                }
            } else {
                $null = Invoke-SetupGit -Location $source -Arguments @('worktree', 'add', '-b', $setupBranch, $active, $sourceHead)
            }
            Write-Host "Preserved your uncommitted files in: $source"
            Write-Host "Agent development checkout: $active"
            Write-Host 'Uncommitted source edits are not imported or published automatically.'
        } else {
            $null = Invoke-SetupGit -Location $active -Arguments @('switch', '-c', $setupBranch)
        }
        $mergeArgs = @('-c', 'user.name=Wyatt Koerner', '-c', 'user.email=267839055+whkoerner@users.noreply.github.com',
                       'merge', '--no-edit', ('origin/' + $Branch))
        try { $null = Invoke-SetupGit -Location $active -Arguments $mergeArgs }
        catch {
            $ErrorActionPreference = 'Continue'
            $null = & $GitExe -C $active merge --abort 2>&1
            $ErrorActionPreference = 'Stop'
            throw "Setup integration conflicted in $active. The merge was aborted; original files remain preserved."
        }
        if ($isolated) {
            $afterHead = Invoke-SetupGit -Location $source -Arguments @('rev-parse', 'HEAD')
            $afterStatus = Invoke-SetupGit -Location $source -Arguments @('status', '--porcelain')
            if ($afterHead -ne $sourceHead -or $afterStatus -ne $sourceStatus) {
                throw 'The original checkout changed concurrently. Setup stopped; inspect its current edits.'
            }
            $state = Join-Path $active '.workforce'
            New-Item -ItemType Directory -Force -Path $state | Out-Null
            @{source_project=$source; source_commit=$sourceHead; source_status=$sourceStatus; uncommitted_edits_imported=$false} |
                ConvertTo-Json | Set-Content -LiteralPath (Join-Path $state 'setup-source.json') -Encoding UTF8
        }
    }
    return [pscustomobject]@{Project=$active; SourceProject=$source; Isolated=$isolated; UncommittedEditsImported=$false}
}
