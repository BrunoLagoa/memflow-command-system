Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:MemflowRepoDefault = "BrunoLagoa/memflow-command-system"
$script:MemflowSchemaVersion = "1"

function Write-Info {
  param([string]$Message)
  Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-WarnLog {
  param([string]$Message)
  Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-ErrorLog {
  param([string]$Message)
  Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Stop-WithError {
  param([string]$Message)
  Write-ErrorLog $Message
  exit 1
}

function Show-MemflowBanner {
  @"
 __  __ _____ __  __ _____ _     _____        __
|  \/  | ____|  \/  |  ___| |   / _ \ \      / /
| |\/| |  _| | |\/| | |_  | |  | | | \ \ /\ / /
| |  | | |___| |  | |  _| | |__| |_| |\ V  V /
|_|  |_|_____|_|  |_|_|   |_____\___/  \_/\_/
"@
}

function Get-IsoTimestamp {
  return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Ensure-Command {
  param([string]$Name)
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    Stop-WithError "Pré-requisito ausente: $Name"
  }
}

function Select-Option {
  param(
    [string]$Prompt,
    [string[]]$Options
  )

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
