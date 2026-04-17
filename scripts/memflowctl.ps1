param(
  [Parameter(Position = 0)]
  [ValidateSet("install", "update", "uninstall", "check")]
  [string]$Action,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repo = if ($env:MEMFLOW_REPO) { $env:MEMFLOW_REPO } else { "BrunoLagoa/memflow-command-system" }
$ref = if ($env:MEMFLOW_REF) { $env:MEMFLOW_REF } else { "main" }

if (-not $Action) {
  Write-Host "Uso: memflowctl.ps1 [install|update|uninstall|check] [opções]" -ForegroundColor Yellow
  exit 1
}

$baseUrl = "https://raw.githubusercontent.com/$repo/$ref"
$tmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("memflow-install-" + [Guid]::NewGuid().ToString("N"))
$tmpScript = Join-Path $tmpRoot "scripts/install.ps1"
$downloadFiles = @(
  "scripts/install.ps1",
  "scripts/installers/powershell/core.ps1",
  "scripts/installers/powershell/targets.ps1",
  "scripts/installers/powershell/actions.ps1",
  "scripts/lib/common.ps1"
)

try {
  New-Item -Path $tmpRoot -ItemType Directory -Force | Out-Null
  foreach ($relativePath in $downloadFiles) {
    $destinationPath = Join-Path $tmpRoot $relativePath
    $destinationDir = Split-Path -Parent $destinationPath
    New-Item -Path $destinationDir -ItemType Directory -Force | Out-Null
    Invoke-WebRequest -Uri "$baseUrl/$relativePath" -OutFile $destinationPath
  }
  & $tmpScript $Action @RemainingArgs
} finally {
  if (Test-Path $tmpRoot) {
    Remove-Item -Path $tmpRoot -Recurse -Force
  }
}
