Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-TargetInstallFromSource {
  param(
    [string]$Target,
    [string]$CommandsRoot,
    [string]$InstallDir,
    [string]$ManifestPath,
    [string]$ResolvedVersion,
    [string]$SourceDir,
    [string]$NormalizedScope,
    [string]$ResolvedOs
  )

  switch ($Target) {
    "opencode" {
      Install-OpencodeTargetFromSource -CommandsRoot $CommandsRoot -InstallDir $InstallDir -ManifestPath $ManifestPath -ResolvedVersion $ResolvedVersion -SourceDir $SourceDir -NormalizedScope $NormalizedScope -ResolvedTarget $Target -ResolvedOs $ResolvedOs
    }
    "vscode" {
      Install-VscodeTargetFromSource -CommandsRoot $CommandsRoot -ManifestPath $ManifestPath -ResolvedVersion $ResolvedVersion -SourceDir $SourceDir -NormalizedScope $NormalizedScope -ResolvedTarget $Target -ResolvedOs $ResolvedOs
    }
    default {
      Stop-WithError "Target não suportado para instalação: $Target"
    }
  }
}

function Invoke-TargetUninstall {
  param(
    [string]$Target,
    [string]$CommandsRoot,
    [string]$InstallDir,
    [string]$ManifestPath
  )

  switch ($Target) {
    "opencode" {
      Uninstall-OpencodeTargetInstallation -InstallDir $InstallDir -ManifestPath $ManifestPath
    }
    "vscode" {
      Uninstall-VscodeTargetInstallation -CommandsRoot $CommandsRoot -ManifestPath $ManifestPath
    }
    default {
      Stop-WithError "Target não suportado para remoção: $Target"
    }
  }
}

function Invoke-Install {
  param(
    [string]$ResolvedScope,
    [string]$ResolvedTarget,
    [string]$ResolvedOs,
    [string]$ResolvedVersion
  )

  $normalizedScope = Normalize-ScopeForTarget -RequestedScope $ResolvedScope -ResolvedTarget $ResolvedTarget
  $commandsRoot = Resolve-CommandsRoot -ResolvedScope $normalizedScope -ResolvedTarget $ResolvedTarget -ResolvedOs $ResolvedOs -ResolvedProjectDir $ProjectDir
  $installDir = Resolve-InstallDir -CommandsRoot $commandsRoot -ResolvedTarget $ResolvedTarget
  $manifestPath = Join-Path $commandsRoot ".memflow-install.json"
  $sourceDir = Resolve-SourceDir -RepoName $Repo -RequestedVersion $ResolvedVersion -InstallerScriptDir $ScriptDir

  Invoke-TargetInstallFromSource -Target $ResolvedTarget -CommandsRoot $commandsRoot -InstallDir $installDir -ManifestPath $manifestPath -ResolvedVersion $ResolvedVersion -SourceDir $sourceDir -NormalizedScope $normalizedScope -ResolvedOs $ResolvedOs
}

function Invoke-Update {
  param(
    [string]$ResolvedScope,
    [string]$ResolvedTarget,
    [string]$ResolvedOs
  )

  $nextVersion = if ($Version) { $Version } else { Get-LatestReleaseTag -RepoName $Repo }
  $manifestPath = $null
  $manifestPaths = @()
  $targetFilter = if ($script:MemflowTargetProvided) { $ResolvedTarget } else { $null }
  if ([string]::IsNullOrEmpty($ResolvedScope)) {
    $manifestPaths = @(Find-ExistingManifests -ResolvedOs $ResolvedOs -ResolvedProjectDir $ProjectDir -TargetFilter $targetFilter)
    if ($manifestPaths.Count -eq 0) {
      if (-not $NonInteractive) {
        $missingMessage = Get-MissingInstallationMessage -ActionName "update" -ResolvedScope $ResolvedScope -HasExplicitScope $false
        Write-WarnLog $missingMessage
        $confirmInstall = Read-Host "Deseja iniciar uma nova instalação agora? [y/N]"
        if ($confirmInstall.ToLower() -eq "y" -or $confirmInstall.ToLower() -eq "yes") {
          $bootstrapScope = if ($ResolvedTarget -eq "vscode") { "local" } else { "global" }
          Write-Info "Iniciando nova instalação no escopo $bootstrapScope."
          Invoke-Install -ResolvedScope $bootstrapScope -ResolvedTarget $ResolvedTarget -ResolvedOs $ResolvedOs -ResolvedVersion $nextVersion
          return
        }
      }
      Stop-NotFound (Get-MissingInstallationMessage -ActionName "update" -ResolvedScope $ResolvedScope -HasExplicitScope $false)
    }

    $updatedCount = 0
    foreach ($currentManifestPath in $manifestPaths) {
      $manifest = $null
      $installedVersion = $null
      try {
        $manifest = Get-Content $currentManifestPath -Raw | ConvertFrom-Json
        $installedVersion = $manifest.version
      } catch {
        # Se o manifest estiver corrompido/inválido, segue o update normalmente.
      }

      $effectiveScope = if ($manifest -and $manifest.scope) { [string]$manifest.scope } else { "global" }
      $effectiveOs = if ($manifest -and $manifest.os) { [string]$manifest.os } else { $ResolvedOs }
      $effectiveTarget = if ($manifest -and $manifest.target) { [string]$manifest.target } else { $ResolvedTarget }
      if ([string]::IsNullOrEmpty($effectiveTarget)) {
        $effectiveTarget = "opencode"
      }

      if ($installedVersion -and ($installedVersion -eq $nextVersion)) {
        Write-Info "[$effectiveScope] MEMFLOW já está atualizado ($installedVersion)"
        continue
      }

      if ($installedVersion) {
        Write-Info "[$effectiveScope] Nova versão do MEMFLOW encontrada. Atual: $installedVersion | Disponível: $nextVersion"
      } else {
        Write-Info "[$effectiveScope] Atualização do MEMFLOW iniciada para versão $nextVersion"
      }

      Invoke-Install -ResolvedScope $effectiveScope -ResolvedTarget $effectiveTarget -ResolvedOs $effectiveOs -ResolvedVersion $nextVersion
      $updatedCount += 1
    }

    if ($updatedCount -gt 0) {
      Write-Info "Atualização concluída em $updatedCount escopo(s)."
    }
    return
  }

  $commandsRoot = Resolve-CommandsRoot -ResolvedScope $ResolvedScope -ResolvedTarget $ResolvedTarget -ResolvedOs $ResolvedOs -ResolvedProjectDir $ProjectDir
  $manifestPath = Join-Path $commandsRoot ".memflow-install.json"

  if (-not $manifestPath -or -not (Test-Path $manifestPath)) {
    if ($ResolvedScope -eq "local" -and -not $script:ProjectDirProvided) {
      Stop-WithError "Para atualizar instalação local fora do projeto atual, informe -ProjectDir <dir>."
    }
    $missingMessage = Get-MissingInstallationMessage -ActionName "update" -ResolvedScope $ResolvedScope -HasExplicitScope $true
    if (-not $NonInteractive) {
      Write-WarnLog $missingMessage
      $confirmInstall = Read-Host "Deseja iniciar uma nova instalação agora? [y/N]"
      if ($confirmInstall.ToLower() -eq "y" -or $confirmInstall.ToLower() -eq "yes") {
        Write-Info "Iniciando nova instalação no escopo $ResolvedScope."
        Invoke-Install -ResolvedScope $ResolvedScope -ResolvedTarget $ResolvedTarget -ResolvedOs $ResolvedOs -ResolvedVersion $nextVersion
        return
      }
    }
    Stop-NotFound $missingMessage
  }

  $manifest = $null
  $installedVersion = $null
  try {
    $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
    $installedVersion = $manifest.version
  } catch {
    # Se o manifest estiver corrompido/inválido, segue o update normalmente.
  }

  $effectiveScope = $ResolvedScope
  if ([string]::IsNullOrEmpty($effectiveScope) -and $manifest -and $manifest.scope) {
    $effectiveScope = [string]$manifest.scope
  }
  if ([string]::IsNullOrEmpty($effectiveScope)) {
    $effectiveScope = "global"
  }

  $effectiveOs = $ResolvedOs
  if ($manifest -and $manifest.os) {
    $effectiveOs = [string]$manifest.os
  }

  if ($installedVersion -and ($installedVersion -eq $nextVersion)) {
    Write-Info "MEMFLOW já está atualizado ($installedVersion)"
    return
  }

  if ($installedVersion) {
    Write-Info "Nova versão do MEMFLOW encontrada. Atual: $installedVersion | Disponível: $nextVersion"
  } else {
    Write-Info "Atualização do MEMFLOW iniciada para versão $nextVersion"
  }
  $effectiveTarget = $ResolvedTarget
  if ($manifest -and $manifest.target) {
    $effectiveTarget = [string]$manifest.target
  }
  if ([string]::IsNullOrEmpty($effectiveTarget)) {
    $effectiveTarget = "opencode"
  }
  Invoke-Install -ResolvedScope $effectiveScope -ResolvedTarget $effectiveTarget -ResolvedOs $effectiveOs -ResolvedVersion $nextVersion
}

function Invoke-Uninstall {
  param(
    [string]$ResolvedScope,
    [string]$ResolvedTarget,
    [string]$ResolvedOs
  )

  $manifestPaths = @()
  $targetFilter = if ($script:MemflowTargetProvided) { $ResolvedTarget } else { $null }
  if ([string]::IsNullOrEmpty($ResolvedScope)) {
    $manifestPaths = @(Find-ExistingManifests -ResolvedOs $ResolvedOs -ResolvedProjectDir $ProjectDir -TargetFilter $targetFilter)
  } else {
    $commandsRoot = Resolve-CommandsRoot -ResolvedScope $ResolvedScope -ResolvedTarget $ResolvedTarget -ResolvedOs $ResolvedOs -ResolvedProjectDir $ProjectDir
    $manifestPaths = @((Join-Path $commandsRoot ".memflow-install.json"))
  }

  if ($manifestPaths.Count -eq 0) {
    if ($ResolvedScope -eq "local" -and -not $script:ProjectDirProvided) {
      Stop-WithError "Para remover instalação local fora do projeto atual, informe -ProjectDir <dir>."
    }
    Stop-NotFound (Get-MissingInstallationMessage -ActionName "uninstall" -ResolvedScope $ResolvedScope -HasExplicitScope $false)
  }

  $targetsToRemove = @()
  foreach ($currentManifestPath in $manifestPaths) {
    $currentCommandsRoot = Split-Path -Parent $currentManifestPath
    $manifestTarget = $null
    try {
      $manifestContent = Get-Content $currentManifestPath -Raw | ConvertFrom-Json
      if ($manifestContent -and $manifestContent.target) {
        $manifestTarget = [string]$manifestContent.target
      }
    } catch {}
    if (-not $manifestTarget) {
      $manifestTarget = $ResolvedTarget
    }
    if (-not $manifestTarget) {
      $manifestTarget = "opencode"
    }
    $currentInstallDir = Resolve-InstallDir -CommandsRoot $currentCommandsRoot -ResolvedTarget $manifestTarget
    if ((Test-Path $currentInstallDir) -or (Test-Path $currentManifestPath)) {
      $targetsToRemove += @{
        ManifestPath = $currentManifestPath
        InstallDir = $currentInstallDir
        Target = $manifestTarget
      }
    }
  }

  if ($targetsToRemove.Count -eq 0) {
    if ($ResolvedScope -eq "local" -and -not $script:ProjectDirProvided) {
      Stop-WithError "Para remover instalação local fora do projeto atual, informe -ProjectDir <dir>."
    }
    $hasExplicitScope = -not [string]::IsNullOrEmpty($ResolvedScope)
    Stop-NotFound (Get-MissingInstallationMessage -ActionName "uninstall" -ResolvedScope $ResolvedScope -HasExplicitScope $hasExplicitScope)
  }

  if ($targetsToRemove.Count -gt 1) {
    Write-Info "Removendo $($targetsToRemove.Count) instalações (global/local)."
  }
  foreach ($target in $targetsToRemove) {
    Write-Host "Destino de remoção: $($target.InstallDir)"
  }

  if (-not $NonInteractive) {
    $confirm = Read-Host "Confirmar remoção completa do MEMFLOW? [y/N]"
    if ($confirm.ToLower() -ne "y" -and $confirm.ToLower() -ne "yes") {
      Write-WarnLog "Remoção cancelada."
      return
    }
  }

  foreach ($target in $targetsToRemove) {
    $currentCommandsRoot = Split-Path -Parent $target.ManifestPath
    Invoke-TargetUninstall -Target $target.Target -CommandsRoot $currentCommandsRoot -InstallDir $target.InstallDir -ManifestPath $target.ManifestPath
  }

  if ($targetsToRemove.Count -gt 1) {
    Write-Info "MEMFLOW removido com sucesso em $($targetsToRemove.Count) escopo(s)."
  } else {
    Write-Info "MEMFLOW removido com sucesso."
  }
}

function Invoke-Check {
  param(
    [string]$ResolvedScope,
    [string]$ResolvedTarget,
    [string]$ResolvedOs
  )
  $manifestPaths = @()
  $targetFilter = if ($script:MemflowTargetProvided) { $ResolvedTarget } else { $null }
  if ($ResolvedScope) {
    $commandsRoot = Resolve-CommandsRoot -ResolvedScope $ResolvedScope -ResolvedTarget $ResolvedTarget -ResolvedOs $ResolvedOs -ResolvedProjectDir $ProjectDir
    $candidateManifestPath = Join-Path $commandsRoot ".memflow-install.json"
    if (Test-Path $candidateManifestPath) {
      $manifestPaths += $candidateManifestPath
    }
  } else {
    $manifestPaths = @(Find-ExistingManifests -ResolvedOs $ResolvedOs -ResolvedProjectDir $ProjectDir -TargetFilter $targetFilter)
  }

  if ($manifestPaths.Count -eq 0) {
    return
  }

  foreach ($manifestPath in $manifestPaths) {
    $manifest = $null
    try {
      $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
    } catch {
      continue
    }
    if (-not $manifest -or -not $manifest.version) {
      continue
    }

    $effectiveScope = if ($manifest.scope) { [string]$manifest.scope } elseif ($ResolvedScope) { $ResolvedScope } else { "global" }
    $effectiveOs = if ($manifest.os) { [string]$manifest.os } else { $ResolvedOs }
    $effectiveTarget = if ($manifest.target) { [string]$manifest.target } elseif ($ResolvedTarget) { $ResolvedTarget } else { "opencode" }
    $effectiveScope = Normalize-ScopeForTarget -RequestedScope $effectiveScope -ResolvedTarget $effectiveTarget
    $repoName = if ($manifest.repo) { [string]$manifest.repo } else { $Repo }

    $latestVersion = Get-LatestVersionWithCache -RepoName $repoName -ResolvedOs $effectiveOs
    if (-not $latestVersion) {
      continue
    }
    if (Test-IsVersionNewer -LatestVersion $latestVersion -InstalledVersion ([string]$manifest.version)) {
      Show-VersionUpdateNotice -InstalledVersion ([string]$manifest.version) -LatestVersion $latestVersion -ResolvedScope $effectiveScope -ResolvedOs $effectiveOs -ResolvedTarget $effectiveTarget
    }
  }
}
