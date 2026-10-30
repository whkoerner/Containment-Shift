$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
. (Join-Path $PSScriptRoot 'Setup-Checkout.ps1')
$GitExe = (Get-Command git -CommandType Application -All -ErrorAction Stop | Select-Object -First 1).Source
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('CS-Checkout-Test-' + [guid]::NewGuid().ToString('N'))
$source = Join-Path $fixture 'Original Project'
$remote = Join-Path $fixture 'remote.git'
$branch = 'fixture-workforce'
New-Item -ItemType Directory -Force -Path $fixture | Out-Null
function Invoke-FixtureGit {
    param([string]$Location, [string[]]$Arguments)
    $ErrorActionPreference = 'Continue'
    $output = @(& $GitExe -C $Location @Arguments 2>&1)
    $code = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    if ($code -ne 0) { throw ('Fixture Git failed: ' + ($Arguments -join ' ') + "`n" + ($output -join "`n")) }
    return ($output -join "`n").Trim()
}
try {
    $null = Invoke-FixtureGit -Location $fixture -Arguments @('init', '--bare', $remote)
    $null = Invoke-FixtureGit -Location $fixture -Arguments @('clone', $remote, $source)
    $null = Invoke-FixtureGit -Location $source -Arguments @('config', 'user.name', 'Setup Fixture')
    $null = Invoke-FixtureGit -Location $source -Arguments @('config', 'user.email', 'fixture@example.invalid')
    [IO.File]::WriteAllText((Join-Path $source '.gitignore'), ".workforce/`nTemp/`n")
    [IO.File]::WriteAllText((Join-Path $source 'game.txt'), 'baseline')
    $null = Invoke-FixtureGit -Location $source -Arguments @('add', '.gitignore', 'game.txt')
    $null = Invoke-FixtureGit -Location $source -Arguments @('commit', '-m', 'baseline')
    $originalBranch = Invoke-FixtureGit -Location $source -Arguments @('branch', '--show-current')
    $null = Invoke-FixtureGit -Location $source -Arguments @('switch', '-c', $branch)
    [IO.File]::WriteAllText((Join-Path $source 'agent.txt'), 'agent integration fixture')
    $null = Invoke-FixtureGit -Location $source -Arguments @('add', 'agent.txt')
    $null = Invoke-FixtureGit -Location $source -Arguments @('commit', '-m', 'agent integration')
    $null = Invoke-FixtureGit -Location $source -Arguments @('push', 'origin', $branch)
    $null = Invoke-FixtureGit -Location $source -Arguments @('switch', $originalBranch)
    [IO.File]::WriteAllText((Join-Path $source 'committed.txt'), 'existing committed game work')
    $null = Invoke-FixtureGit -Location $source -Arguments @('add', 'committed.txt')
    $null = Invoke-FixtureGit -Location $source -Arguments @('commit', '-m', 'local committed work')
    [IO.File]::WriteAllText((Join-Path $source 'game.txt'), 'human uncommitted changes')
    [IO.File]::WriteAllText((Join-Path $source 'private-untracked.txt'), 'must never be copied or published')
    [IO.File]::WriteAllText((Join-Path $source 'staged.txt'), 'human staged changes')
    $null = Invoke-FixtureGit -Location $source -Arguments @('add', 'staged.txt')
    $beforeHead = Invoke-FixtureGit -Location $source -Arguments @('rev-parse', 'HEAD')
    $beforeStatus = Invoke-FixtureGit -Location $source -Arguments @('status', '--porcelain')
    $beforeIndex = Invoke-FixtureGit -Location $source -Arguments @('diff', '--cached')
    $hashes = @{}
    foreach ($name in @('game.txt', 'private-untracked.txt', 'staged.txt')) {
        $hashes[$name] = (Get-FileHash -LiteralPath (Join-Path $source $name)).Hash
    }
    $result = Initialize-WorkforceCheckout -GitExe $GitExe -Project $source -Remote $remote -Branch $branch
    if (-not $result.Isolated -or $result.Project -ne (Join-Path $fixture 'ContainmentShift-Workforce')) { throw 'Dirty checkout did not use the dedicated worktree.' }
    if ($beforeHead -ne (Invoke-FixtureGit -Location $source -Arguments @('rev-parse', 'HEAD'))) { throw 'Original HEAD changed.' }
    if ($originalBranch -ne (Invoke-FixtureGit -Location $source -Arguments @('branch', '--show-current'))) { throw 'Original branch changed.' }
    if ($beforeStatus -ne (Invoke-FixtureGit -Location $source -Arguments @('status', '--porcelain'))) { throw 'Original status changed.' }
    if ($beforeIndex -ne (Invoke-FixtureGit -Location $source -Arguments @('diff', '--cached'))) { throw 'Original staged changes changed.' }
    foreach ($name in $hashes.Keys) {
        if ($hashes[$name] -ne (Get-FileHash -LiteralPath (Join-Path $source $name)).Hash) { throw "Original file changed: $name" }
    }
    foreach ($name in @('agent.txt', 'committed.txt')) {
        if (-not (Test-Path -LiteralPath (Join-Path $result.Project $name))) { throw "Committed source/integration missing: $name" }
    }
    if (Test-Path -LiteralPath (Join-Path $result.Project 'private-untracked.txt')) { throw 'Private untracked file was copied.' }
    if (Invoke-FixtureGit -Location $result.Project -Arguments @('status', '--porcelain')) { throw 'Agent worktree is not clean.' }
    $again = Initialize-WorkforceCheckout -GitExe $GitExe -Project $source -Remote $remote -Branch $branch
    if ($again.Project -ne $result.Project) { throw 'Repeat setup made another checkout.' }
    $listing = Invoke-FixtureGit -Location $source -Arguments @('worktree', 'list', '--porcelain')
    if (@($listing -split "`n" | Where-Object { $_ -like 'worktree *' }).Count -ne 2) { throw 'Repeat setup accumulated extra worktrees.' }
    [IO.File]::WriteAllText((Join-Path $result.Project 'agent.txt'), 'agent worktree unsaved edits')
    $blocked = $false
    try { $null = Initialize-WorkforceCheckout -GitExe $GitExe -Project $source -Remote $remote -Branch $branch }
    catch { if ($_.Exception.Message -notlike '*workforce checkout itself has unsaved edits*') { throw }; $blocked = $true }
    if (-not $blocked) { throw 'Setup overwrote a dirty agent worktree.' }
    $fresh = Join-Path $fixture 'Fresh Project'
    $new = Initialize-WorkforceCheckout -GitExe $GitExe -Project $fresh -Remote $remote -Branch $branch
    if ($new.Isolated -or -not (Test-Path -LiteralPath (Join-Path $fresh 'agent.txt'))) { throw 'Fresh clone setup failed.' }
    Write-Host 'PASS: original staged/unstaged/untracked bytes and branch preserved; committed work integrated; one reusable worktree; dirty agent worktree protected; fresh clone supported.'
} finally {
    Remove-Item -LiteralPath $fixture -Recurse -Force
    $global:LASTEXITCODE = 0
}
