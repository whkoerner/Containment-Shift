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
