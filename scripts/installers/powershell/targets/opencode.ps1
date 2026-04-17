Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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
  Copy-Item -Path (Join-Path $SourceDir "*") -Destination $InstallDir -Recurse -Force

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
