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
$script:MemflowRef = if ($env:MEMFLOW_REF) { $env:MEMFLOW_REF } else { "main" }
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

function Import-InstallerModule {
  param(
    [string]$LocalRelativePath,
    [string]$RemoteRelativePath
  )
  $modulePath = Join-Path $ScriptDir $LocalRelativePath
  if (Test-Path $modulePath) {
    . $modulePath
    return
  }

  $moduleUrl = "https://raw.githubusercontent.com/$Repo/$($script:MemflowRef)/$RemoteRelativePath"
  $tmpModule = Join-Path ([System.IO.Path]::GetTempPath()) ("memflow-module-" + [Guid]::NewGuid().ToString("N") + ".ps1")
  try {
    Invoke-WebRequest -Uri $moduleUrl -OutFile $tmpModule
    . $tmpModule
  } catch {
    Stop-WithError "Não foi possível carregar módulo remoto: $moduleUrl"
  } finally {
    if (Test-Path $tmpModule) {
      Remove-Item -Path $tmpModule -Force
    }
  }
}

Import-InstallerModule -LocalRelativePath "installers/powershell/core.ps1" -RemoteRelativePath "scripts/installers/powershell/core.ps1"
Import-InstallerModule -LocalRelativePath "installers/powershell/targets.ps1" -RemoteRelativePath "scripts/installers/powershell/targets.ps1"
Import-InstallerModule -LocalRelativePath "installers/powershell/actions.ps1" -RemoteRelativePath "scripts/installers/powershell/actions.ps1"

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
