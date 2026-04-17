Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Stop-NotFound {
  param([string]$Message)
  Write-ErrorLog $Message
  exit $script:NotFoundExitCode
}


function Get-MissingInstallationMessage {
  param(
    [string]$ActionName,
    [string]$ResolvedScope,
    [bool]$HasExplicitScope
  )
  if ($HasExplicitScope) {
    return "Não é possível executar $ActionName`: nenhuma instalação MEMFLOW encontrada no escopo $ResolvedScope."
  }
  return "Não é possível executar $ActionName`: nenhuma instalação MEMFLOW encontrada."
}


function Get-SupportedTargets {
  return $script:SupportedTargets
}


function Normalize-ScopeForTarget {
  param(
    [string]$RequestedScope,
    [string]$ResolvedTarget
  )
  if ($ResolvedTarget -eq "vscode") {
    # VS Code usa instalação única por projeto.
    return "local"
  }
  return $RequestedScope
}


function Resolve-InstallDir {
  param(
    [string]$CommandsRoot,
    [string]$ResolvedTarget
  )
  if ($ResolvedTarget -eq "vscode") {
    return (Join-Path $CommandsRoot "prompts")
  }
  return (Join-Path $CommandsRoot "memflow")
}


function Resolve-CommandsRoot {
  param(
    [string]$ResolvedScope,
    [string]$ResolvedTarget,
    [string]$ResolvedOs,
    [string]$ResolvedProjectDir
  )

  if ($ResolvedTarget -eq "vscode") {
    return (Join-Path $ResolvedProjectDir ".github")
  }

  if ($ResolvedScope -eq "global") {
    if ($ResolvedOs -eq "windows") {
      return (Join-Path $env:USERPROFILE ".config\$ResolvedTarget\commands")
    }
    return (Join-Path $HOME ".config/$ResolvedTarget/commands")
  }
  return (Join-Path $ResolvedProjectDir ".$ResolvedTarget\commands")
}


function Get-LatestReleaseTag {
  param([string]$RepoName)
  $apiUrl = "https://api.github.com/repos/$RepoName/releases/latest"
  $response = Invoke-RestMethod -Uri $apiUrl -Method Get
  if (-not $response.tag_name) {
    Stop-WithError "Não foi possível descobrir a release mais recente."
  }
  return [string]$response.tag_name
}


function Try-GetLatestReleaseTag {
  param([string]$RepoName)
  try {
    $apiUrl = "https://api.github.com/repos/$RepoName/releases/latest"
    $response = Invoke-RestMethod -Uri $apiUrl -Method Get
    if (-not $response.tag_name) {
      return $null
    }
    return [string]$response.tag_name
  } catch {
    return $null
  }
}


function Get-VersionCachePath {
  param([string]$ResolvedOs)
  if ($ResolvedOs -eq "windows") {
    $base = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { Join-Path $HOME "AppData\Local" }
    return (Join-Path $base "memflow\version-check.json")
  }
  return (Join-Path $HOME ".cache/memflow/version-check.json")
}


function Get-VersionCacheData {
  param([string]$CachePath)
  if (-not (Test-Path $CachePath)) {
    return $null
  }
  try {
    return (Get-Content $CachePath -Raw | ConvertFrom-Json)
  } catch {
    return $null
  }
}


function Save-VersionCacheData {
  param(
    [string]$CachePath,
    [string]$RepoName,
    [string]$LatestVersion,
    [long]$NowEpoch
  )
  $cacheDir = Split-Path -Parent $CachePath
  New-Item -Path $cacheDir -ItemType Directory -Force | Out-Null
  $payload = [ordered]@{
    repo = $RepoName
    latestVersion = $LatestVersion
    lastCheckedEpoch = "$NowEpoch"
  }
  $payload | ConvertTo-Json | Set-Content -Path $CachePath -Encoding UTF8
}


function Get-LatestVersionWithCache {
  param(
    [string]$RepoName,
    [string]$ResolvedOs
  )
  $cachePath = Get-VersionCachePath -ResolvedOs $ResolvedOs
  $cache = Get-VersionCacheData -CachePath $cachePath
  $nowEpoch = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
  if ($cache -and $cache.repo -eq $RepoName -and $cache.lastCheckedEpoch -and $cache.latestVersion) {
    $lastChecked = 0L
    if ([long]::TryParse([string]$cache.lastCheckedEpoch, [ref]$lastChecked)) {
      $delta = $nowEpoch - $lastChecked
      if ($delta -ge 0 -and $delta -le $script:VersionCheckTtlSeconds) {
        return [string]$cache.latestVersion
      }
    }
  }

  $latest = Try-GetLatestReleaseTag -RepoName $RepoName
  if (-not $latest) {
    return $null
  }
  Save-VersionCacheData -CachePath $cachePath -RepoName $RepoName -LatestVersion $latest -NowEpoch $nowEpoch
  return $latest
}


function Normalize-VersionTag {
  param([string]$Value)
  if (-not $Value) { return "" }
  return ($Value -replace '^[vV]', '')
}


function Test-IsVersionNewer {
  param(
    [string]$LatestVersion,
    [string]$InstalledVersion
  )
  $latest = Normalize-VersionTag -Value $LatestVersion
  $installed = Normalize-VersionTag -Value $InstalledVersion
  if (-not $latest -or -not $installed -or $latest -eq $installed) {
    return $false
  }
  try {
    $latestBase = $latest.Split('-')[0]
    $installedBase = $installed.Split('-')[0]
    return ([version]$latestBase -gt [version]$installedBase)
  } catch {
    return $latest -ne $installed
  }
}


function Find-ExistingManifest {
  param(
    [string]$ResolvedOs,
    [string]$ResolvedProjectDir,
    [string]$TargetFilter
  )
  foreach ($candidateTarget in (Get-SupportedTargets)) {
    if ($TargetFilter -and $candidateTarget -ne $TargetFilter) {
      continue
    }
    if ($candidateTarget -eq "vscode") {
      $singleRoot = Resolve-CommandsRoot -ResolvedScope "local" -ResolvedTarget $candidateTarget -ResolvedOs $ResolvedOs -ResolvedProjectDir $ResolvedProjectDir
      $singleManifest = Join-Path $singleRoot ".memflow-install.json"
      if (Test-Path $singleManifest) { return $singleManifest }
      continue
    }
    $globalRoot = Resolve-CommandsRoot -ResolvedScope "global" -ResolvedTarget $candidateTarget -ResolvedOs $ResolvedOs -ResolvedProjectDir $ResolvedProjectDir
    $localRoot = Resolve-CommandsRoot -ResolvedScope "local" -ResolvedTarget $candidateTarget -ResolvedOs $ResolvedOs -ResolvedProjectDir $ResolvedProjectDir
    $globalManifest = Join-Path $globalRoot ".memflow-install.json"
    $localManifest = Join-Path $localRoot ".memflow-install.json"
    if (Test-Path $globalManifest) { return $globalManifest }
    if (Test-Path $localManifest) { return $localManifest }
  }
  return $null
}


function Find-ExistingManifests {
  param(
    [string]$ResolvedOs,
    [string]$ResolvedProjectDir,
    [string]$TargetFilter
  )
  $manifests = @()
  foreach ($candidateTarget in (Get-SupportedTargets)) {
    if ($TargetFilter -and $candidateTarget -ne $TargetFilter) {
      continue
    }
    if ($candidateTarget -eq "vscode") {
      $singleRoot = Resolve-CommandsRoot -ResolvedScope "local" -ResolvedTarget $candidateTarget -ResolvedOs $ResolvedOs -ResolvedProjectDir $ResolvedProjectDir
      $singleManifest = Join-Path $singleRoot ".memflow-install.json"
      if (Test-Path $singleManifest) { $manifests += $singleManifest }
      continue
    }
    $globalRoot = Resolve-CommandsRoot -ResolvedScope "global" -ResolvedTarget $candidateTarget -ResolvedOs $ResolvedOs -ResolvedProjectDir $ResolvedProjectDir
    $localRoot = Resolve-CommandsRoot -ResolvedScope "local" -ResolvedTarget $candidateTarget -ResolvedOs $ResolvedOs -ResolvedProjectDir $ResolvedProjectDir
    $globalManifest = Join-Path $globalRoot ".memflow-install.json"
    $localManifest = Join-Path $localRoot ".memflow-install.json"
    if (Test-Path $globalManifest) { $manifests += $globalManifest }
    if (Test-Path $localManifest) { $manifests += $localManifest }
  }
  return $manifests
}


function Show-VersionUpdateNotice {
  param(
    [string]$InstalledVersion,
    [string]$LatestVersion,
    [string]$ResolvedScope,
    [string]$ResolvedOs,
    [string]$ResolvedTarget
  )
  $updateCommand = "memflowctl update --scope $ResolvedScope --non-interactive"
  if ($ResolvedTarget -eq "vscode") {
    $updateCommand = "memflowctl update --target vscode --project-dir . --non-interactive"
  } elseif ($ResolvedOs -eq "windows") {
    $updateCommand = "memflowctl.ps1 update -Scope $ResolvedScope -NonInteractive"
  }
  Write-Info "Nova versão do MEMFLOW encontrada. Atual: $InstalledVersion | Disponível: $LatestVersion"
  Write-Host "  Próximo passo: $updateCommand"
}


function Resolve-SourceDir {
  param(
    [string]$RepoName,
    [string]$RequestedVersion,
    [string]$InstallerScriptDir
  )

  if ($RequestedVersion -eq "local") {
    $repoRoot = Split-Path -Parent $InstallerScriptDir
    $srcPath = Join-Path $repoRoot "src"
    if (-not (Test-Path $srcPath)) {
      Stop-WithError "Diretório src não encontrado para instalação local."
    }
    return $srcPath
  }

  $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("memflow-" + [Guid]::NewGuid().ToString("N"))
  New-Item -Path $tempRoot -ItemType Directory | Out-Null
  $archivePath = Join-Path $tempRoot "release.zip"
  $zipUrl = "https://github.com/$RepoName/archive/refs/tags/$RequestedVersion.zip"

  Invoke-WebRequest -Uri $zipUrl -OutFile $archivePath
  Expand-Archive -Path $archivePath -DestinationPath $tempRoot -Force

  $folder = Get-ChildItem -Path $tempRoot -Directory | Where-Object { $_.Name -notlike "*.zip" } | Select-Object -First 1
  if (-not $folder) {
    Stop-WithError "Falha ao extrair a release."
  }

  $src = Join-Path $folder.FullName "src"
  if (-not (Test-Path $src)) {
    Stop-WithError "Release inválida: diretório src não encontrado."
  }
  return $src
}


function Write-Manifest {
  param(
    [string]$ManifestPath,
    [string]$ResolvedVersion,
    [string]$ResolvedScope,
    [string]$ResolvedTarget,
    [string]$ResolvedOs,
    [string]$InstallDir,
    [string]$CommandsRoot,
    [string]$RepoName
  )

  $manifest = [ordered]@{
    schemaVersion = $script:MemflowSchemaVersion
    project       = "memflow-command-system"
    version       = $ResolvedVersion
    scope         = $ResolvedScope
    target        = $ResolvedTarget
    channel       = "release"
    repo          = $RepoName
    os            = $ResolvedOs
    installDir    = $InstallDir
    commandsRoot  = $CommandsRoot
    installedAt   = (Get-IsoTimestamp)
  }

  $manifest | ConvertTo-Json | Set-Content -Path $ManifestPath -Encoding UTF8
}


function Resolve-WizardValues {
  $resolvedOs = $Os
  $resolvedScope = $Scope
  $resolvedTarget = $Target

  if ($Action -eq "check") {
    if (-not $resolvedOs) { $resolvedOs = if ($IsWindows) { "windows" } elseif ($IsMacOS) { "macos" } else { "linux" } }
    if (-not $script:MemflowScopeProvided) {
      $resolvedScope = $null
    } elseif (-not $resolvedScope) {
      $resolvedScope = "global"
    }
    if (-not $resolvedTarget) { $resolvedTarget = "opencode" }
  } elseif (-not $NonInteractive) {
    Show-MemflowBanner
    Write-Host ""
    Write-Host "MEMFLOW - sistema open source de engenharia com IA para SDLC (Software Development Life Cycle) completo e automação de comandos em múltiplas plataformas."
    Write-Host "Um conjunto de ferramentas de código aberto para focar em cenários de produto e resultados previsíveis, em vez de desenvolver cada parte do zero com base em intuição."
    Write-Host ""

    if (-not $resolvedOs) {
      $resolvedOs = Select-Option -Prompt "1 - Escolha seu sistema operacional" -Options @("windows", "linux", "macos")
    }
    if (-not $resolvedTarget) {
      $resolvedTarget = Select-Option -Prompt "2 - Selecione o local de instalação" -Options (Get-SupportedTargets)
    } else {
      Write-Host "2 - Selecione o local de instalação"
      Write-Host "  > $resolvedTarget"
    }
    if (-not $resolvedScope) {
      if ($resolvedTarget -eq "vscode") {
        $resolvedScope = "local"
        Write-Host "3 - Escopo"
        Write-Host "  > local (único para vscode)"
      } else {
        $resolvedScope = Select-Option -Prompt "3 - Essa instalação vai ser local ou global?" -Options @("local", "global")
      }
    }
  } else {
    if (-not $resolvedOs) { $resolvedOs = "windows" }
    if (-not $resolvedScope) {
      if (($Action -eq "update" -or $Action -eq "uninstall") -and -not $script:MemflowScopeProvided) {
        $resolvedScope = $null
      } else {
        $resolvedScope = "global"
      }
    }
    if (-not $resolvedTarget) { $resolvedTarget = "opencode" }
  }

  $resolvedScope = Normalize-ScopeForTarget -RequestedScope $resolvedScope -ResolvedTarget $resolvedTarget

  return @{
    Os = $resolvedOs
    Scope = $resolvedScope
    Target = $resolvedTarget
  }
}
