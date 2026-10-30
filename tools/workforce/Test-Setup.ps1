$ErrorActionPreference = 'Stop'
$Project = Join-Path ([IO.Path]::GetTempPath()) ('CS-Setup-Test-' + [guid]::NewGuid().ToString('N'))
$script:GitExe = (Get-Command git -ErrorAction Stop).Source
$parseErrors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile(
    (Join-Path $PSScriptRoot 'Install.ps1'), [ref]$null, [ref]$parseErrors)
if ($parseErrors) { throw ($parseErrors | Out-String) }
$definition = $ast.Find({ param($node)
    $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Git'
}, $true)
if (-not $definition) { throw 'Installer Git wrapper was not found.' }
# Load only the trusted wrapper function, never the installer body or installs.
Invoke-Expression $definition.Extent.Text
$finder = $ast.Find({ param($node)
    $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Find-Program'
}, $true)
if (-not $finder) { throw 'Installer program finder was not found.' }
Invoke-Expression $finder.Extent.Text
# Reproduce the actual failure: Git the helper exists before looking for Git the application.
$detected = Find-Program 'git' @()
if (-not $detected -or $detected -ne $script:GitExe) { throw 'The Git helper hid git.exe during dependency detection.' }
& $detected --version
if ($LASTEXITCODE -ne 0) { throw 'Detected Git is not executable.' }
Write-Host 'PASS: installed Git is detected even while a Git helper function exists.'
New-Item -ItemType Directory -Path $Project | Out-Null
try {
    Git @('init', '--quiet')
    Git @('config', 'user.name', 'Containment Shift Setup Fixture')
    $value = (& $script:GitExe -C $Project config user.name | Out-String).Trim()
    if ($value -ne 'Containment Shift Setup Fixture') { throw 'Installer lost Git arguments or quoting.' }
    Write-Host 'PASS: installer forwards every Git argument, including values containing spaces.'
} finally {
    Remove-Item -LiteralPath $Project -Recurse -Force
}

# WinGet responses are simulated; this test must not install/upgrade runner packages.
$installer = $ast.Find({ param($node)
    $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Install-Missing'
}, $true)
if (-not $installer) { throw 'Installer dependency install helper was not found.' }
Invoke-Expression $installer.Extent.Text
$stub = Join-Path ([IO.Path]::GetTempPath()) ('CS-WinGet-Stub-' + [guid]::NewGuid().ToString('N') + '.cmd')
Set-Content -LiteralPath $stub -Value "@echo off`r`nexit /b %CS_WORKFORCE_WINGET_CODE%" -Encoding ASCII
$script:CSFixtureWingetStub = $stub
function Get-Command {
    param([string]$Name, [string]$CommandType)
    if ($Name -ne 'winget') { throw 'Unexpected lookup in WinGet fixture.' }
    return [pscustomobject]@{Source=$script:CSFixtureWingetStub}
}
$pathBefore = $env:PATH
try {
    foreach ($code in @(0, -1978335189, -1978335135, -1978334963)) {
        $env:CS_WORKFORCE_WINGET_CODE = [string]$code
        Install-Missing 'Git.Git'
    }
    $env:CS_WORKFORCE_WINGET_CODE = '42'
    $blocked = $false
    try { Install-Missing 'Git.Git' }
    catch { if ($_.Exception.Message -notlike '*0x0000002A*') { throw }; $blocked = $true }
    if (-not $blocked) { throw 'A real WinGet error was incorrectly ignored.' }
    Write-Host 'PASS: simulated existing/current packages continue to detection; real install errors still stop setup.'
} finally {
    Remove-Item -LiteralPath $stub -Force
    Remove-Item Function:\Get-Command
    Remove-Item Env:\CS_WORKFORCE_WINGET_CODE
    $env:PATH = $pathBefore
    # The fixture deliberately invokes a failing native command and verifies its
    # exception. Do not let a CI shell mistake that expected last HRESULT for a test failure.
    $global:LASTEXITCODE = 0
}
