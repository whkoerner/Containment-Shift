$ErrorActionPreference = 'Stop'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('CS-OpenCode-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $fixture | Out-Null
$oldPath = $env:PATH
$python = (Get-Command python -CommandType Application -All | Where-Object { $_.Source -notmatch 'WindowsApps' } | Select-Object -First 1).Source
try {
    $fake = Join-Path $fixture 'fake.py'
    @'
import json, os, sys
from pathlib import Path
a=sys.argv[1:]
assert a[0]=='run' and '--auto' in a and '--format' in a
assert a[a.index('--model')+1]=='ollama/fixture:latest'
prompt=Path(a[a.index('--file')+1]).read_text(encoding='utf-8')
assert prompt=='Literal $value; "quoted" & text\nSecond line'
c=json.loads(os.environ['OPENCODE_CONFIG_CONTENT'])
assert c['model']=='ollama/fixture:latest'
print(json.dumps({'type':'text','part':{'text':'Fixture worker invoked'}}))
'@ | Set-Content -LiteralPath $fake -Encoding UTF8
    ('@echo off' + "`r`n" + '"' + $python + '" "' + $fake + '" %*' + "`r`n" + 'exit /b %ERRORLEVEL%') |
        Set-Content -LiteralPath (Join-Path $fixture 'opencode.cmd') -Encoding ASCII
    $env:PATH = "$fixture;$oldPath"
    $request = Join-Path $fixture 'request.json'
    @{model='ollama/fixture:latest';config=@{model='ollama/fixture:latest'};prompt=('Literal $value; "quoted" & text' + "`nSecond line")} |
        ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $request -Encoding UTF8
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Run-OpenCode.ps1') -RequestFile $request
    if ($LASTEXITCODE -ne 0) { throw 'OpenCode .cmd fixture failed; arguments/config/prompt were not preserved.' }
    Write-Host 'PASS: real PowerShell 5.1 -> npm-style .cmd -> Python fixture; local model, JSON config, prompt quotes/newlines preserved.'
} finally {
    $env:PATH = $oldPath
    Remove-Item -LiteralPath $fixture -Recurse -Force
}
