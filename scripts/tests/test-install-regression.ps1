Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallScript = Join-Path $ScriptDir "..\install.ps1"
$PowerShellHost = if (Get-Command pwsh -ErrorAction SilentlyContinue) { "pwsh" } else { "powershell" }

$PassCount = 0
$FailCount = 0

function Invoke-ExpectExit {
  param(
    [string]$TestName,
    [int]$ExpectedExit,
    [string[]]$CommandArgs
  )

  $pwshArgs = @("-ExecutionPolicy", "Bypass", "-File", $InstallScript) + $CommandArgs
  & $PowerShellHost @pwshArgs *> $null
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
  & $PowerShellHost @pwshArgs *> $null
  $ok = (-not $LASTEXITCODE -or $LASTEXITCODE -eq 0)

  if ($ok) {
    Write-Host "[PASS] $TestName"
    $script:PassCount += 1
  } else {
    Write-Host "[FAIL] $TestName (comando deveria passar)"
    & $PowerShellHost @pwshArgs
    $script:FailCount += 1
  }
}

$TmpRoot = Join-Path $ScriptDir (".tmp-install-regression-ps-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $TmpRoot | Out-Null
try {
  $HomeRoot = Join-Path $TmpRoot "home"
  $ProjectLocal = Join-Path $TmpRoot "project-local"
  $ProjectVscode = Join-Path $TmpRoot "project-vscode"
  $ProjectClaude = Join-Path $TmpRoot "project-claude"
  New-Item -ItemType Directory -Path $HomeRoot, $ProjectLocal, $ProjectVscode, $ProjectClaude -Force | Out-Null

  $env:HOME = $HomeRoot
  $env:USERPROFILE = $HomeRoot

  Invoke-ExpectExit "update local sem instalação deve falhar com código 2" 2 @("update", "-Scope", "local", "-ProjectDir", $ProjectLocal, "-NonInteractive", "-Version", "local")

  Invoke-ExpectExit "update global sem instalação deve falhar com código 2" 2 @("update", "-Scope", "global", "-NonInteractive", "-Version", "local")

  Invoke-ExpectSuccess "install local inicial deve funcionar" @("install", "-Scope", "local", "-ProjectDir", $ProjectLocal, "-NonInteractive", "-Version", "local")

  Invoke-ExpectExit "update cursor sem instalação deve falhar com código 2" 2 @("update", "-Target", "cursor", "-ProjectDir", $ProjectLocal, "-NonInteractive", "-Version", "local")

  Invoke-ExpectExit "uninstall cursor sem instalação deve falhar com código 2" 2 @("uninstall", "-Target", "cursor", "-ProjectDir", $ProjectLocal, "-NonInteractive")

  Invoke-ExpectSuccess "install cursor inicial deve funcionar" @("install", "-Target", "cursor", "-ProjectDir", $ProjectLocal, "-NonInteractive", "-Version", "local")

  $cursorInstallDir = Join-Path $ProjectLocal ".cursor\commands\memflow"
  if (Test-Path $cursorInstallDir) {
    Write-Host "[PASS] install cursor cria comandos em .cursor\commands\memflow"
    $PassCount += 1
  } else {
    Write-Host "[FAIL] install cursor não criou comandos em .cursor\commands\memflow"
    $FailCount += 1
  }

  $cursorWorkflowFile = Join-Path $cursorInstallDir "workflow.md"
  $cursorWorkflow = if (Test-Path $cursorWorkflowFile) { Get-Content -Raw -Path $cursorWorkflowFile } else { "" }
  if (($cursorWorkflow -like "*injetado: _shared/target-adapter.cursor.md*") -and ($cursorWorkflow -like "*injetado: _shared/base-subagents.md*")) {
    Write-Host "[PASS] install cursor injeta adaptador do Cursor e base-subagents"
    $PassCount += 1
  } else {
    Write-Host "[FAIL] install cursor não injeta adaptador do Cursor ou base-subagents"
    $FailCount += 1
  }

  if (Test-Path (Join-Path $cursorInstallDir "retro.md")) {
    Write-Host "[PASS] install cursor instala o comando retro"
    $PassCount += 1
  } else {
    Write-Host "[FAIL] install cursor não instalou o comando retro"
    $FailCount += 1
  }

  Invoke-ExpectSuccess "update cursor com instalação existente deve funcionar" @("update", "-Target", "cursor", "-ProjectDir", $ProjectLocal, "-NonInteractive", "-Version", "local")

  Invoke-ExpectSuccess "check cursor com instalação existente deve funcionar" @("check", "-Target", "cursor", "-ProjectDir", $ProjectLocal, "-NonInteractive")

  Invoke-ExpectSuccess "uninstall cursor remove instalação existente" @("uninstall", "-Target", "cursor", "-ProjectDir", $ProjectLocal, "-NonInteractive")

  if (-not (Test-Path $cursorInstallDir)) {
    Write-Host "[PASS] uninstall cursor remove instalação local"
    $PassCount += 1
  } else {
    Write-Host "[FAIL] uninstall cursor manteve instalação local"
    $FailCount += 1
  }

  $cursorGlobalDir = Join-Path $HomeRoot ".config\cursor\commands\memflow"
  if (-not (Test-Path $cursorGlobalDir)) {
    Write-Host "[PASS] cursor não usa instalação global"
    $PassCount += 1
  } else {
    Write-Host "[FAIL] cursor criou instalação global indevida"
    $FailCount += 1
  }

  Invoke-ExpectSuccess "install vscode deve gerar prompts" @("install", "-Target", "vscode", "-ProjectDir", $ProjectVscode, "-NonInteractive", "-Version", "local")

  $promptFiles = @(Get-ChildItem -Path (Join-Path $ProjectVscode ".github\prompts") -Filter "memflow.*.prompt.md" -ErrorAction SilentlyContinue)
  if ($promptFiles.Count -gt 0) {
    Write-Host "[PASS] install vscode cria prompts"
    $PassCount += 1
  } else {
    Write-Host "[FAIL] install vscode não criou prompts"
    $FailCount += 1
  }

  $vscodeWorkflowFile = Join-Path $ProjectVscode ".github\prompts\memflow.workflow.prompt.md"
  $vscodeWorkflow = if (Test-Path $vscodeWorkflowFile) { Get-Content -Raw -Path $vscodeWorkflowFile } else { "" }
  if (($vscodeWorkflow -like "*injetado: _shared/target-adapter.vscode.md*") -and ($vscodeWorkflow -like "*injetado: model-policy.md*")) {
    Write-Host "[PASS] install vscode injeta adaptador do VSCode e model-policy"
    $PassCount += 1
  } else {
    Write-Host "[FAIL] install vscode não injeta adaptador do VSCode ou model-policy"
    $FailCount += 1
  }

  Invoke-ExpectSuccess "uninstall vscode deve remover prompts" @("uninstall", "-Target", "vscode", "-ProjectDir", $ProjectVscode, "-NonInteractive")

  Invoke-ExpectExit "update claude sem instalação deve falhar com código 2" 2 @("update", "-Target", "claude", "-ProjectDir", $ProjectClaude, "-NonInteractive", "-Version", "local")

  Invoke-ExpectExit "uninstall claude sem instalação deve falhar com código 2" 2 @("uninstall", "-Target", "claude", "-ProjectDir", $ProjectClaude, "-NonInteractive")

  Invoke-ExpectSuccess "install claude inicial deve funcionar" @("install", "-Target", "claude", "-ProjectDir", $ProjectClaude, "-NonInteractive", "-Version", "local")

  $claudeInstallDir = Join-Path $ProjectClaude ".claude\commands\memflow"
  if (Test-Path $claudeInstallDir) {
    Write-Host "[PASS] install claude cria comandos em .claude\commands\memflow"
    $PassCount += 1
  } else {
    Write-Host "[FAIL] install claude não criou comandos em .claude\commands\memflow"
    $FailCount += 1
  }

  $claudeContextFile = Join-Path $claudeInstallDir "context.md"
  $claudeContext = if (Test-Path $claudeContextFile) { Get-Content -Raw -Path $claudeContextFile } else { "" }
  if ($claudeContext -like "*injetado: _shared/base-domain-model.md*") {
    Write-Host "[PASS] install claude injeta base-domain-model em context.md"
    $PassCount += 1
  } else {
    Write-Host "[FAIL] install claude não injeta base-domain-model em context.md"
    $FailCount += 1
  }

  if (($claudeContext -like "*injetado: model-policy.md*") -and ($claudeContext -like "*injetado: _shared/target-adapter.claude.md*") -and ($claudeContext -notlike "*injetado: _shared/target-adapter.md*")) {
    Write-Host "[PASS] install claude injeta model-policy e adaptador próprio do Claude"
    $PassCount += 1
  } else {
    Write-Host "[FAIL] install claude não injeta model-policy ou adaptador próprio do Claude"
    $FailCount += 1
  }

  $leftoverRefs = @(Select-String -Path (Join-Path $claudeInstallDir "*.md") -Pattern '^\s*-\s+`?(_shared/[A-Za-z0-9._-]+|model-policy)\.md`?\s*$')
  if ($leftoverRefs.Count -eq 0) {
    Write-Host "[PASS] install claude não deixa referências normativas sem injeção"
    $PassCount += 1
  } else {
    Write-Host "[FAIL] install claude deixou $($leftoverRefs.Count) referência(s) normativa(s) sem injeção"
    $FailCount += 1
  }

  Invoke-ExpectSuccess "update claude com instalação existente deve funcionar" @("update", "-Target", "claude", "-ProjectDir", $ProjectClaude, "-NonInteractive", "-Version", "local")

  Invoke-ExpectSuccess "check claude com instalação existente deve funcionar" @("check", "-Target", "claude", "-ProjectDir", $ProjectClaude, "-NonInteractive")

  Invoke-ExpectSuccess "uninstall claude remove instalação existente" @("uninstall", "-Target", "claude", "-ProjectDir", $ProjectClaude, "-NonInteractive")

  if (-not (Test-Path $claudeInstallDir)) {
    Write-Host "[PASS] uninstall claude remove instalação local"
    $PassCount += 1
  } else {
    Write-Host "[FAIL] uninstall claude manteve instalação local"
    $FailCount += 1
  }

  $claudeGlobalDir = Join-Path $HomeRoot ".config\claude\commands\memflow"
  if (-not (Test-Path $claudeGlobalDir)) {
    Write-Host "[PASS] claude não usa instalação global"
    $PassCount += 1
  } else {
    Write-Host "[FAIL] claude criou instalação global indevida"
    $FailCount += 1
  }
} finally {
  Remove-Item -Recurse -Force $TmpRoot -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host ("Resultado: {0} passou, {1} falhou" -f $PassCount, $FailCount)
if ($FailCount -gt 0) {
  exit 1
}
