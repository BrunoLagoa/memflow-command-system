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

$scriptUrl = "https://raw.githubusercontent.com/$repo/$ref/scripts/install.ps1"
$tmpScript = Join-Path ([System.IO.Path]::GetTempPath()) ("memflow-install-" + [Guid]::NewGuid().ToString("N") + ".ps1")

try {
  Invoke-WebRequest -Uri $scriptUrl -OutFile $tmpScript
  & $tmpScript $Action @RemainingArgs
} finally {
  if (Test-Path $tmpScript) {
    Remove-Item -Path $tmpScript -Force
  }
}
