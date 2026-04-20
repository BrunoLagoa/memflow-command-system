Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallScript = Join-Path $ScriptDir "..\install.ps1"

$PassCount = 0
$FailCount = 0

function Invoke-ExpectExit {
  param(
    [string]$TestName,
    [int]$ExpectedExit,
    [string[]]$CommandArgs
  )

  $pwshArgs = @("-ExecutionPolicy", "Bypass", "-File", $InstallScript) + $CommandArgs
  & powershell @pwshArgs *> $null
  $exitCode = if ($LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }

  if ($exitCode -eq $ExpectedExit) {
    Write-Host "[PASS] $TestName"
    $script:PassCount += 1
  } else {
    Write-Host "[FAIL] $TestName (esperado exit=$ExpectedExit, recebido=$exitCode)"
    $script:FailCount += 1
  }
}

function Invoke-ExpectSuccess {
  param(
    [string]$TestName,
    [string[]]$CommandArgs
  )

  $pwshArgs = @("-ExecutionPolicy", "Bypass", "-File", $InstallScript) + $CommandArgs
  & powershell @pwshArgs *> $null
  $ok = (-not $LASTEXITCODE -or $LASTEXITCODE -eq 0)

  if ($ok) {
    Write-Host "[PASS] $TestName"
    $script:PassCount += 1
  } else {
    Write-Host "[FAIL] $TestName (comando deveria passar)"
    $script:FailCount += 1
  }
}

$TmpRoot = Join-Path $ScriptDir (".tmp-install-regression-ps-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $TmpRoot | Out-Null
try {
  $HomeRoot = Join-Path $TmpRoot "home"
  $ProjectLocal = Join-Path $TmpRoot "project-local"
  $ProjectVscode = Join-Path $TmpRoot "project-vscode"
  New-Item -ItemType Directory -Path $HomeRoot, $ProjectLocal, $ProjectVscode -Force | Out-Null

  $env:HOME = $HomeRoot
  $env:USERPROFILE = $HomeRoot

  Invoke-ExpectExit "update local sem instalação deve falhar com código 2" 2 @("update", "-Scope", "local", "-ProjectDir", $ProjectLocal, "-NonInteractive", "-Version", "local")

  Invoke-ExpectExit "update global sem instalação deve falhar com código 2" 2 @("update", "-Scope", "global", "-NonInteractive", "-Version", "local")

  Invoke-ExpectSuccess "install local inicial deve funcionar" @("install", "-Scope", "local", "-ProjectDir", $ProjectLocal, "-NonInteractive", "-Version", "local")

  Invoke-ExpectSuccess "install vscode deve gerar prompts" @("install", "-Target", "vscode", "-ProjectDir", $ProjectVscode, "-NonInteractive", "-Version", "local")

  $promptFiles = @(Get-ChildItem -Path (Join-Path $ProjectVscode ".github\prompts") -Filter "memflow.*.prompt.md" -ErrorAction SilentlyContinue)
  if ($promptFiles.Count -gt 0) {
    Write-Host "[PASS] install vscode cria prompts"
    $PassCount += 1
  } else {
    Write-Host "[FAIL] install vscode não criou prompts"
    $FailCount += 1
  }

  Invoke-ExpectSuccess "uninstall vscode deve remover prompts" @("uninstall", "-Target", "vscode", "-ProjectDir", $ProjectVscode, "-NonInteractive")
} finally {
  Remove-Item -Recurse -Force $TmpRoot -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host ("Resultado: {0} passou, {1} falhou" -f $PassCount, $FailCount)
if ($FailCount -gt 0) {
  exit 1
}
