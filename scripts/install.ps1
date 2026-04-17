param(
  [Parameter(Position = 0)]
  [ValidateSet("install", "update", "uninstall", "check")]
  [string]$Action = "install",
  [ValidateSet("global", "local")]
  [string]$Scope,
  [ValidateSet("opencode", "vscode")]
  [string]$Target,
  [ValidateSet("linux", "macos", "windows")]
  [string]$Os,
  [string]$Version,
  [string]$ProjectDir = (Get-Location).Path,
  [string]$Repo = "BrunoLagoa/memflow-command-system",
  [switch]$NonInteractive
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$script:VersionCheckTtlSeconds = 86400
$script:ProjectDirProvided = $PSBoundParameters.ContainsKey("ProjectDir")
$script:MemflowScopeProvided = $PSBoundParameters.ContainsKey("Scope")
$script:MemflowTargetProvided = $PSBoundParameters.ContainsKey("Target")
$script:NotFoundExitCode = 2
$script:SupportedTargets = @("opencode", "vscode")

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommonScript = Join-Path $ScriptDir "lib/common.ps1"
if (Test-Path $CommonScript) {
  . $CommonScript
} else {
  function Write-Info { param([string]$Message) Write-Host "[INFO] $Message" -ForegroundColor Cyan }
  function Write-WarnLog { param([string]$Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
  function Write-ErrorLog { param([string]$Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }
  function Stop-WithError { param([string]$Message) Write-ErrorLog $Message; exit 1 }
  function Show-MemflowBanner {
@"
 __  __ _____ __  __ _____ _     _____        __
|  \/  | ____|  \/  |  ___| |   / _ \ \      / /
| |\/| |  _| | |\/| | |_  | |  | | | \ \ /\ / /
| |  | | |___| |  | |  _| | |__| |_| |\ V  V /
|_|  |_|_____|_|  |_|_|   |_____\___/  \_/\_/
"@
  }
  function Get-IsoTimestamp { return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ") }
  function Select-Option {
    param([string]$Prompt, [string[]]$Options)
    Write-Host $Prompt
    for ($i = 0; $i -lt $Options.Count; $i++) {
      Write-Host ("  {0}) {1}" -f ($i + 1), $Options[$i])
    }
    while ($true) {
      $answer = Read-Host ("Selecione uma opção [1-{0}]" -f $Options.Count)
      $number = 0
      if ([int]::TryParse($answer, [ref]$number) -and $number -ge 1 -and $number -le $Options.Count) {
        return $Options[$number - 1]
      }
      Write-WarnLog "Opção inválida. Tente novamente."
    }
  }
  $script:MemflowRepoDefault = "BrunoLagoa/memflow-command-system"
  $script:MemflowSchemaVersion = "1"
}

if (-not (Get-Variable -Name MemflowSchemaVersion -Scope Script -ErrorAction SilentlyContinue)) {
  $script:MemflowSchemaVersion = "1"
}

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

  New-Item -Path $commandsRoot -ItemType Directory -Force | Out-Null

  $sourceDir = Resolve-SourceDir -RepoName $Repo -RequestedVersion $ResolvedVersion -InstallerScriptDir $ScriptDir
  if ($ResolvedTarget -eq "vscode") {
    $promptsDir = Join-Path $commandsRoot "prompts"
    $legacyAgentsDir = Join-Path $commandsRoot "agents"
    New-Item -Path $promptsDir -ItemType Directory -Force | Out-Null

    if (-not $NonInteractive) {
      $existingPrompts = @(Get-ChildItem -Path $promptsDir -Filter "memflow.*.prompt.md" -ErrorAction SilentlyContinue)
      $existingLegacyAgents = @(Get-ChildItem -Path $legacyAgentsDir -Filter "memflow.*.agent.md" -ErrorAction SilentlyContinue)
      if ($existingPrompts.Count -gt 0 -or $existingLegacyAgents.Count -gt 0) {
        $backup = Read-Host "Comandos MEMFLOW existentes detectados para VSCode. Criar backup? [Y/n]"
        if ([string]::IsNullOrWhiteSpace($backup) -or $backup.ToLower() -eq "y" -or $backup.ToLower() -eq "yes") {
          $backupDir = Join-Path $commandsRoot ("memflow-vscode-backup." + (Get-Date -Format yyyyMMddHHmmss))
          New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
          Copy-Item -Path $promptsDir -Destination (Join-Path $backupDir "prompts") -Recurse -Force -ErrorAction SilentlyContinue
          Copy-Item -Path $legacyAgentsDir -Destination (Join-Path $backupDir "agents") -Recurse -Force -ErrorAction SilentlyContinue
          Write-Info "Backup criado: $backupDir"
        }
      }
    }

    Get-ChildItem -Path $promptsDir -Filter "memflow.*.prompt.md" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $legacyAgentsDir -Filter "memflow.*.agent.md" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

    $sourceFiles = @(Get-ChildItem -Path $sourceDir -File -Filter "*.md")
    if ($sourceFiles.Count -eq 0) {
      Stop-WithError "Nenhum comando encontrado em $sourceDir para instalação VSCode."
    }
    foreach ($srcFile in $sourceFiles) {
      $stem = [System.IO.Path]::GetFileNameWithoutExtension($srcFile.Name)
      $promptFile = Join-Path $promptsDir ("memflow.$stem.prompt.md")
      Render-VscodePromptWithShared -SourceFile $srcFile.FullName -DestinationFile $promptFile -SourceDir $sourceDir
    }

    Write-Manifest -ManifestPath $manifestPath -ResolvedVersion $ResolvedVersion -ResolvedScope $normalizedScope -ResolvedTarget $ResolvedTarget -ResolvedOs $ResolvedOs -InstallDir $promptsDir -CommandsRoot $commandsRoot -RepoName $Repo
    Write-Info "Instalação concluída com sucesso."
    Write-Info "Destino prompts: $promptsDir"
    return
  }

  if (Test-Path $installDir) {
    if (-not $NonInteractive) {
      $backup = Read-Host "Instalação existente detectada. Criar backup? [Y/n]"
      if ([string]::IsNullOrWhiteSpace($backup) -or $backup.ToLower() -eq "y" -or $backup.ToLower() -eq "yes") {
        $backupDir = "$installDir.bak.$(Get-Date -Format yyyyMMddHHmmss)"
        Copy-Item -Path $installDir -Destination $backupDir -Recurse
        Write-Info "Backup criado: $backupDir"
      }
    }
    Remove-Item -Path $installDir -Recurse -Force
  }

  New-Item -Path $installDir -ItemType Directory -Force | Out-Null
  Copy-Item -Path (Join-Path $sourceDir "*") -Destination $installDir -Recurse -Force

  Write-Manifest -ManifestPath $manifestPath -ResolvedVersion $ResolvedVersion -ResolvedScope $normalizedScope -ResolvedTarget $ResolvedTarget -ResolvedOs $ResolvedOs -InstallDir $installDir -CommandsRoot $commandsRoot -RepoName $Repo

  Write-Info "Instalação concluída com sucesso."
  Write-Info "Destino: $installDir"
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
    if ($target.Target -eq "vscode") {
      $promptsPath = Join-Path (Split-Path -Parent $target.ManifestPath) "prompts"
      Write-Host "Destino de remoção: $promptsPath"
    }
  }

  if (-not $NonInteractive) {
    $confirm = Read-Host "Confirmar remoção completa do MEMFLOW? [y/N]"
    if ($confirm.ToLower() -ne "y" -and $confirm.ToLower() -ne "yes") {
      Write-WarnLog "Remoção cancelada."
      return
    }
  }

  foreach ($target in $targetsToRemove) {
    if ($target.Target -eq "vscode") {
      $currentCommandsRoot = Split-Path -Parent $target.ManifestPath
      $agentsDir = Join-Path $currentCommandsRoot "agents"
      $promptsDir = Join-Path $currentCommandsRoot "prompts"
      Get-ChildItem -Path $agentsDir -Filter "memflow.*.agent.md" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
      Get-ChildItem -Path $promptsDir -Filter "memflow.*.prompt.md" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    } elseif (Test-Path $target.InstallDir) {
      Remove-Item -Path $target.InstallDir -Recurse -Force
    }
    if (Test-Path $target.ManifestPath) {
      Remove-Item -Path $target.ManifestPath -Force
    }
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

$resolved = Resolve-WizardValues
$resolvedOs = [string]$resolved.Os
$resolvedScope = [string]$resolved.Scope
$resolvedTarget = [string]$resolved.Target

if (-not $Version -and $Action -eq "install") {
  $Version = Get-LatestReleaseTag -RepoName $Repo
}

switch ($Action) {
  "install" {
    Write-Host ""
    Write-Host "Resumo da instalação"
    Write-Host "  Sistema operacional: $resolvedOs"
    Write-Host "  Target: $resolvedTarget"
    Write-Host "  Scope: $resolvedScope"
    Write-Host "  Versão: $Version"
    Write-Host ""
    if (-not $NonInteractive) {
      $confirmInstall = Read-Host "Confirmar instalação? [Y/n]"
      if ($confirmInstall.ToLower() -eq "n" -or $confirmInstall.ToLower() -eq "no") {
        Write-WarnLog "Instalação cancelada."
        exit 0
      }
    }
    Invoke-Install -ResolvedScope $resolvedScope -ResolvedTarget $resolvedTarget -ResolvedOs $resolvedOs -ResolvedVersion $Version
  }
  "update" {
    Invoke-Update -ResolvedScope $resolvedScope -ResolvedTarget $resolvedTarget -ResolvedOs $resolvedOs
  }
  "uninstall" {
    Invoke-Uninstall -ResolvedScope $resolvedScope -ResolvedTarget $resolvedTarget -ResolvedOs $resolvedOs
  }
  "check" {
    Invoke-Check -ResolvedScope $resolvedScope -ResolvedTarget $resolvedTarget -ResolvedOs $resolvedOs
  }
}
