Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Render-CommandWithSharedInjection {
  param(
    [string]$SourceFile,
    [string]$DestinationFile,
    [string]$SourceDir,
    [string]$TargetAdapterRelativePath,
    [string]$TargetAdapterInjectedTitle
  )

  $sharedDir = Join-Path $SourceDir "_shared"
  $sharedOutput = Join-Path $sharedDir "base-output.md"
  $sharedPreconditions = Join-Path $sharedDir "base-preconditions.md"
  $sharedDegraded = Join-Path $sharedDir "base-degraded-mode.md"
  $sharedTargetAdapter = Join-Path $sharedDir $TargetAdapterRelativePath
  $modelPolicyFile = Join-Path $SourceDir "model-policy.md"

  foreach ($required in @($sharedOutput, $sharedPreconditions, $sharedDegraded, $sharedTargetAdapter)) {
    if (-not (Test-Path $required)) {
      Stop-WithError "Arquivo compartilhado não encontrado: $required"
    }
  }
  if (-not (Test-Path $modelPolicyFile)) {
    Stop-WithError "Arquivo não encontrado: $modelPolicyFile"
  }

  $sharedOutputLines = Get-Content -Path $sharedOutput
  $sharedPreconditionsLines = Get-Content -Path $sharedPreconditions
  $sharedDegradedLines = Get-Content -Path $sharedDegraded
  $sharedTargetAdapterLines = Get-Content -Path $sharedTargetAdapter
  $modelPolicyLines = Get-Content -Path $modelPolicyFile
  $result = New-Object System.Collections.Generic.List[string]

  foreach ($line in (Get-Content -Path $SourceFile)) {
    if ($line -match "^\s*-\s+`?_shared/base-output\.md`?\s*$") {
      $result.Add("### Conteúdo injetado: _shared/base-output.md")
      foreach ($sharedLine in $sharedOutputLines) { $result.Add($sharedLine) }
      continue
    }
    if ($line -match "^\s*-\s+`?_shared/base-preconditions\.md`?\s*$") {
      $result.Add("### Conteúdo injetado: _shared/base-preconditions.md")
      foreach ($sharedLine in $sharedPreconditionsLines) { $result.Add($sharedLine) }
      continue
    }
    if ($line -match "^\s*-\s+`?_shared/base-degraded-mode\.md`?\s*$") {
      $result.Add("### Conteúdo injetado: _shared/base-degraded-mode.md")
      foreach ($sharedLine in $sharedDegradedLines) { $result.Add($sharedLine) }
      continue
    }
    if ($line -match "^\s*-\s+`?_shared/target-adapter\.md`?\s*$") {
      $result.Add($TargetAdapterInjectedTitle)
      foreach ($sharedLine in $sharedTargetAdapterLines) { $result.Add($sharedLine) }
      continue
    }
    if ($line -match "^\s*-\s+`?model-policy\.md`?\s*$") {
      $result.Add("### Conteúdo injetado: model-policy.md")
      foreach ($sharedLine in $modelPolicyLines) { $result.Add($sharedLine) }
      continue
    }
    $result.Add($line)
  }

  Set-Content -Path $DestinationFile -Value $result -Encoding UTF8
}
