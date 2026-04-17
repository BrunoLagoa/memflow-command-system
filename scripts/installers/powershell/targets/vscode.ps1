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
  $sharedTargetAdapterVscode = Join-Path $sharedDir "target-adapter.vscode.md"

  foreach ($required in @($sharedOutput, $sharedPreconditions, $sharedDegraded, $sharedTargetAdapterVscode)) {
    if (-not (Test-Path $required)) {
      Stop-WithError "Arquivo compartilhado não encontrado: $required"
    }
  }

  $sharedOutputLines = Get-Content -Path $sharedOutput
  $sharedPreconditionsLines = Get-Content -Path $sharedPreconditions
  $sharedDegradedLines = Get-Content -Path $sharedDegraded
  $sharedTargetAdapterVscodeLines = Get-Content -Path $sharedTargetAdapterVscode
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
      $result.Add("### Conteúdo injetado: _shared/target-adapter.vscode.md")
      foreach ($sharedLine in $sharedTargetAdapterVscodeLines) { $result.Add($sharedLine) }
      continue
    }
    $result.Add($line)
  }

  Set-Content -Path $DestinationFile -Value $result -Encoding UTF8
}

function Install-VscodeTargetFromSource {
  param(
    [string]$CommandsRoot,
    [string]$ManifestPath,
    [string]$ResolvedVersion,
    [string]$SourceDir,
    [string]$NormalizedScope,
    [string]$ResolvedTarget,
    [string]$ResolvedOs
  )

  $promptsDir = Join-Path $CommandsRoot "prompts"
  $legacyAgentsDir = Join-Path $CommandsRoot "agents"
  New-Item -Path $promptsDir -ItemType Directory -Force | Out-Null

  if (-not $NonInteractive) {
    $existingPrompts = @(Get-ChildItem -Path $promptsDir -Filter "memflow.*.prompt.md" -ErrorAction SilentlyContinue)
    $existingLegacyAgents = @(Get-ChildItem -Path $legacyAgentsDir -Filter "memflow.*.agent.md" -ErrorAction SilentlyContinue)
    if ($existingPrompts.Count -gt 0 -or $existingLegacyAgents.Count -gt 0) {
      $backup = Read-Host "Comandos MEMFLOW existentes detectados para VSCode. Criar backup? [Y/n]"
      if ([string]::IsNullOrWhiteSpace($backup) -or $backup.ToLower() -eq "y" -or $backup.ToLower() -eq "yes") {
        $backupDir = Join-Path $CommandsRoot ("memflow-vscode-backup." + (Get-Date -Format yyyyMMddHHmmss))
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
        Copy-Item -Path $promptsDir -Destination (Join-Path $backupDir "prompts") -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item -Path $legacyAgentsDir -Destination (Join-Path $backupDir "agents") -Recurse -Force -ErrorAction SilentlyContinue
        Write-Info "Backup criado: $backupDir"
      }
    }
  }

  Get-ChildItem -Path $promptsDir -Filter "memflow.*.prompt.md" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
  Get-ChildItem -Path $legacyAgentsDir -Filter "memflow.*.agent.md" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

  $sourceFiles = @(Get-ChildItem -Path $SourceDir -File -Filter "*.md")
  if ($sourceFiles.Count -eq 0) {
    Stop-WithError "Nenhum comando encontrado em $SourceDir para instalação VSCode."
  }
  foreach ($srcFile in $sourceFiles) {
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($srcFile.Name)
    $promptFile = Join-Path $promptsDir ("memflow.$stem.prompt.md")
    Render-VscodePromptWithShared -SourceFile $srcFile.FullName -DestinationFile $promptFile -SourceDir $SourceDir
  }

  Write-Manifest -ManifestPath $ManifestPath -ResolvedVersion $ResolvedVersion -ResolvedScope $NormalizedScope -ResolvedTarget $ResolvedTarget -ResolvedOs $ResolvedOs -InstallDir $promptsDir -CommandsRoot $CommandsRoot -RepoName $Repo
  Write-Info "Instalação concluída com sucesso."
  Write-Info "Destino prompts: $promptsDir"
}

function Uninstall-VscodeTargetInstallation {
  param(
    [string]$CommandsRoot,
    [string]$ManifestPath
  )

  $agentsDir = Join-Path $CommandsRoot "agents"
  $promptsDir = Join-Path $CommandsRoot "prompts"
  Get-ChildItem -Path $agentsDir -Filter "memflow.*.agent.md" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
  Get-ChildItem -Path $promptsDir -Filter "memflow.*.prompt.md" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
  if (Test-Path $ManifestPath) {
    Remove-Item -Path $ManifestPath -Force
  }
}
