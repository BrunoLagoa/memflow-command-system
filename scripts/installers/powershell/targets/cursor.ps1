Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Render-CursorCommandWithShared {
  param(
    [string]$SourceFile,
    [string]$DestinationFile,
    [string]$SourceDir
  )
  Render-CommandWithSharedInjection `
    -SourceFile $SourceFile `
    -DestinationFile $DestinationFile `
    -SourceDir $SourceDir `
    -TargetAdapterRelativePath "target-adapter.md" `
    -TargetAdapterInjectedTitle "### Conteúdo injetado: _shared/target-adapter.md"
}

function Install-CursorTargetFromSource {
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
    Stop-WithError "Nenhum comando encontrado em $SourceDir para instalação Cursor."
  }
  $generatedCount = 0
  foreach ($srcFile in $sourceFiles) {
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($srcFile.Name)
    if ($stem -eq "model-policy") {
      continue
    }
    $destFile = Join-Path $InstallDir ($stem + ".md")
    Render-CursorCommandWithShared -SourceFile $srcFile.FullName -DestinationFile $destFile -SourceDir $SourceDir
    $generatedCount++
  }
  if ($generatedCount -eq 0) {
    Stop-WithError "Nenhum comando encontrado em $SourceDir para instalação Cursor."
  }

  Write-Manifest -ManifestPath $ManifestPath -ResolvedVersion $ResolvedVersion -ResolvedScope $NormalizedScope -ResolvedTarget $ResolvedTarget -ResolvedOs $ResolvedOs -InstallDir $InstallDir -CommandsRoot $CommandsRoot -RepoName $Repo

  Write-Info "Instalação concluída com sucesso."
  Write-Info "Destino: $InstallDir"
}

function Uninstall-CursorTargetInstallation {
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
