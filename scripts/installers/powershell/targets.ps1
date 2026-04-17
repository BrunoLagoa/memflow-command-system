Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Render-VscodePromptWithShared {
  param(
    [string]$SourceFile,
    [string]$DestinationFile,
    [string]$SourceDir
  )

  $sharedDir = Join-Path $SourceDir "_shared"
  $sharedOutput = Join-Path $sharedDir "base-output.md"
  $sharedPreconditions = Join-Path $sharedDir "base-preconditions.md"
  $sharedDegraded = Join-Path $sharedDir "base-degraded-mode.md"

  foreach ($required in @($sharedOutput, $sharedPreconditions, $sharedDegraded)) {
    if (-not (Test-Path $required)) {
      Stop-WithError "Arquivo compartilhado não encontrado: $required"
    }
  }

  $sharedOutputLines = Get-Content -Path $sharedOutput
  $sharedPreconditionsLines = Get-Content -Path $sharedPreconditions
  $sharedDegradedLines = Get-Content -Path $sharedDegraded
  $result = New-Object System.Collections.Generic.List[string]

  foreach ($line in (Get-Content -Path $SourceFile)) {
    if ($line -match "_shared/base-output\.md") {
      $result.Add("### Conteúdo injetado: _shared/base-output.md")
      foreach ($sharedLine in $sharedOutputLines) { $result.Add($sharedLine) }
      continue
    }
    if ($line -match "_shared/base-preconditions\.md") {
      $result.Add("### Conteúdo injetado: _shared/base-preconditions.md")
      foreach ($sharedLine in $sharedPreconditionsLines) { $result.Add($sharedLine) }
      continue
    }
    if ($line -match "_shared/base-degraded-mode\.md") {
      $result.Add("### Conteúdo injetado: _shared/base-degraded-mode.md")
      foreach ($sharedLine in $sharedDegradedLines) { $result.Add($sharedLine) }
      continue
    }
    $result.Add($line)
  }

  Set-Content -Path $DestinationFile -Value $result -Encoding UTF8
}
