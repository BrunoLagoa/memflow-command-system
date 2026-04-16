param(
  [Parameter(Position = 0)]
  [ValidateSet("install", "update", "uninstall")]
  [string]$Action = "install",
  [ValidateSet("global", "local")]
  [string]$Scope,
  [ValidateSet("opencode")]
  [string]$Target = "opencode",
  [ValidateSet("linux", "macos", "windows")]
  [string]$Os,
  [string]$Version,
  [string]$ProjectDir = (Get-Location).Path,
  [string]$Repo = "BrunoLagoa/memflow-command-system",
  [switch]$NonInteractive
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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

function Resolve-CommandsRoot {
  param(
    [string]$ResolvedScope,
    [string]$ResolvedOs,
    [string]$ResolvedProjectDir
  )

  if ($ResolvedScope -eq "global") {
    if ($ResolvedOs -eq "windows") {
      return (Join-Path $env:USERPROFILE ".config\opencode\commands")
    }
    return (Join-Path $HOME ".config/opencode/commands")
  }
  return (Join-Path $ResolvedProjectDir ".opencode\commands")
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

function Invoke-Install {
  param(
    [string]$ResolvedScope,
    [string]$ResolvedTarget,
    [string]$ResolvedOs,
    [string]$ResolvedVersion
  )

  $commandsRoot = Resolve-CommandsRoot -ResolvedScope $ResolvedScope -ResolvedOs $ResolvedOs -ResolvedProjectDir $ProjectDir
  $installDir = Join-Path $commandsRoot "memflow"
  $manifestPath = Join-Path $commandsRoot ".memflow-install.json"

  New-Item -Path $commandsRoot -ItemType Directory -Force | Out-Null

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

  $sourceDir = Resolve-SourceDir -RepoName $Repo -RequestedVersion $ResolvedVersion -InstallerScriptDir $ScriptDir
  New-Item -Path $installDir -ItemType Directory -Force | Out-Null
  Copy-Item -Path (Join-Path $sourceDir "*") -Destination $installDir -Recurse -Force

  Write-Manifest -ManifestPath $manifestPath -ResolvedVersion $ResolvedVersion -ResolvedScope $ResolvedScope -ResolvedTarget $ResolvedTarget -ResolvedOs $ResolvedOs -InstallDir $installDir -CommandsRoot $commandsRoot -RepoName $Repo

  Write-Info "Instalação concluída com sucesso."
  Write-Info "Destino: $installDir"
  Write-Info "Próximos passos: /context e /workflow"
}

function Invoke-Update {
  param(
    [string]$ResolvedScope,
    [string]$ResolvedTarget,
    [string]$ResolvedOs
  )

  $commandsRoot = Resolve-CommandsRoot -ResolvedScope $ResolvedScope -ResolvedOs $ResolvedOs -ResolvedProjectDir $ProjectDir
  $manifestPath = Join-Path $commandsRoot ".memflow-install.json"

  $installedVersion = $null
  if (Test-Path $manifestPath) {
    try {
      $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
      $installedVersion = $manifest.version
    } catch {
      # Se o manifest estiver corrompido/inválido, segue o update normalmente.
    }
  }

  $nextVersion = if ($Version) { $Version } else { Get-LatestReleaseTag -RepoName $Repo }

  if ($installedVersion -and ($installedVersion -eq $nextVersion)) {
    Write-Info "MEMFLOW já está na versão mais recente ($installedVersion). Nenhuma atualização é necessária agora."
    return
  }

  Write-Info "Recomendando atualização do MEMFLOW para versão $nextVersion"
  Invoke-Install -ResolvedScope $ResolvedScope -ResolvedTarget $ResolvedTarget -ResolvedOs $ResolvedOs -ResolvedVersion $nextVersion
}

function Invoke-Uninstall {
  param(
    [string]$ResolvedScope,
    [string]$ResolvedOs
  )
  $commandsRoot = Resolve-CommandsRoot -ResolvedScope $ResolvedScope -ResolvedOs $ResolvedOs -ResolvedProjectDir $ProjectDir
  $installDir = Join-Path $commandsRoot "memflow"
  $manifestPath = Join-Path $commandsRoot ".memflow-install.json"

  if (-not (Test-Path $installDir) -and -not (Test-Path $manifestPath)) {
    Write-WarnLog "Nenhuma instalação MEMFLOW encontrada em $commandsRoot."
    return
  }

  if (-not $NonInteractive) {
    $confirm = Read-Host "Confirmar remoção completa do MEMFLOW? [y/N]"
    if ($confirm.ToLower() -ne "y" -and $confirm.ToLower() -ne "yes") {
      Write-WarnLog "Remoção cancelada."
      return
    }
  }

  if (Test-Path $installDir) {
    Remove-Item -Path $installDir -Recurse -Force
  }
  if (Test-Path $manifestPath) {
    Remove-Item -Path $manifestPath -Force
  }

  Write-Info "MEMFLOW removido com sucesso."
}

function Resolve-WizardValues {
  $resolvedOs = $Os
  $resolvedScope = $Scope
  $resolvedTarget = $Target

  if (-not $NonInteractive) {
    Show-MemflowBanner
    Write-Host ""
    Write-Host "MEMFLOW - sistema open source de engenharia com IA para SDLC (Software Development Life Cycle) completo e automação de comandos em múltiplas plataformas."
    Write-Host "Um conjunto de ferramentas de código aberto para focar em cenários de produto e resultados previsíveis, em vez de desenvolver cada parte do zero com base em intuição."
    Write-Host ""

    if (-not $resolvedOs) {
      $resolvedOs = Select-Option -Prompt "1 - Escolha seu sistema operacional" -Options @("windows", "linux", "macos")
    }
    if (-not $resolvedTarget) {
      $resolvedTarget = Select-Option -Prompt "2 - Selecione o local de instalação" -Options @("opencode")
    } else {
      Write-Host "2 - Selecione o local de instalação"
      Write-Host "  > $resolvedTarget"
    }
    if (-not $resolvedScope) {
      $resolvedScope = Select-Option -Prompt "3 - Essa instalação vai ser local ou global?" -Options @("local", "global")
    }
  } else {
    if (-not $resolvedOs) { $resolvedOs = "windows" }
    if (-not $resolvedScope) { $resolvedScope = "global" }
    if (-not $resolvedTarget) { $resolvedTarget = "opencode" }
  }

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
    Invoke-Uninstall -ResolvedScope $resolvedScope -ResolvedOs $resolvedOs
  }
}
