Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Render-OpencodeCommandWithShared {
  param(
    [string]$SourceFile,
    [string]$DestinationFile,
    [string]$SourceDir
  )

  $sharedDir = Join-Path $SourceDir "_shared"
  $sharedOutput = Join-Path $sharedDir "base-output.md"
  $sharedPreconditions = Join-Path $sharedDir "base-preconditions.md"
  $sharedDegraded = Join-Path $sharedDir "base-degraded-mode.md"
  $sharedTargetAdapter = Join-Path $sharedDir "target-adapter.md"
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
      $result.Add("### Conteúdo injetado: _shared/target-adapter.md")
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

function Install-OpencodeTargetFromSource {
  param(
    [string]$CommandsRoot,
    [string]$InstallDir,
    [string]$ManifestPath,
    [string]$ResolvedVersion,
    [string]$SourceDir,
    [string]$NormalizedScope,
    [string]$ResolvedTarget,
    [string]$ResolvedOs
  )

  New-Item -Path $CommandsRoot -ItemType Directory -Force | Out-Null

  if (Test-Path $InstallDir) {
    if (-not $NonInteractive) {
      $backup = Read-Host "Instalação existente detectada. Criar backup? [Y/n]"
      if ([string]::IsNullOrWhiteSpace($backup) -or $backup.ToLower() -eq "y" -or $backup.ToLower() -eq "yes") {
        $backupDir = "$InstallDir.bak.$(Get-Date -Format yyyyMMddHHmmss)"
        Copy-Item -Path $InstallDir -Destination $backupDir -Recurse
        Write-Info "Backup criado: $backupDir"
      }
    }
    Remove-Item -Path $InstallDir -Recurse -Force
  }

  New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null
  $sourceFiles = @(Get-ChildItem -Path $SourceDir -File -Filter "*.md")
  if ($sourceFiles.Count -eq 0) {
    Stop-WithError "Nenhum comando encontrado em $SourceDir para instalação OpenCode."
  }
  $generatedCount = 0
  foreach ($srcFile in $sourceFiles) {
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($srcFile.Name)
    if ($stem -eq "model-policy") {
      continue
    }
    $destFile = Join-Path $InstallDir ($stem + ".md")
    Render-OpencodeCommandWithShared -SourceFile $srcFile.FullName -DestinationFile $destFile -SourceDir $SourceDir
    $generatedCount++
  }
  if ($generatedCount -eq 0) {
    Stop-WithError "Nenhum comando encontrado em $SourceDir para instalação OpenCode."
  }

  Write-Manifest -ManifestPath $ManifestPath -ResolvedVersion $ResolvedVersion -ResolvedScope $NormalizedScope -ResolvedTarget $ResolvedTarget -ResolvedOs $ResolvedOs -InstallDir $InstallDir -CommandsRoot $CommandsRoot -RepoName $Repo

  Write-Info "Instalação concluída com sucesso."
  Write-Info "Destino: $InstallDir"
}

function Uninstall-OpencodeTargetInstallation {
  param(
    [string]$InstallDir,
    [string]$ManifestPath
  )

  if (Test-Path $InstallDir) {
    Remove-Item -Path $InstallDir -Recurse -Force
  }
  if (Test-Path $ManifestPath) {
    Remove-Item -Path $ManifestPath -Force
  }
}
