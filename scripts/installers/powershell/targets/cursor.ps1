Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Remove-CursorFrontmatter {
  param(
    [string]$TargetFile
  )

  $lines = @(Get-Content -Path $TargetFile -Encoding UTF8)
  if ($lines.Count -eq 0 -or $lines[0] -ne "---") {
    return
  }

  $endIdx = -1
  for ($i = 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -eq "---") {
      $endIdx = $i
      break
    }
  }

  if ($endIdx -lt 0) {
    return
  }

  $description = $null
  for ($i = 1; $i -lt $endIdx; $i++) {
    if ($lines[$i] -match '^\s*description:\s*(.+?)\s*$') {
      $description = $Matches[1].Trim()
      if (($description.StartsWith('"') -and $description.EndsWith('"')) -or ($description.StartsWith("'") -and $description.EndsWith("'"))) {
        $description = $description.Substring(1, $description.Length - 2)
      }
      break
    }
  }

  $newLines = @()
  if ($description) {
    $newLines += "> $description"
    $newLines += ""
  }

  if ($endIdx + 1 -lt $lines.Count) {
    $newLines += $lines[($endIdx + 1)..($lines.Count - 1)]
  }

  Set-Content -Path $TargetFile -Value $newLines -Encoding UTF8
}

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

  Remove-CursorFrontmatter -TargetFile $DestinationFile
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
