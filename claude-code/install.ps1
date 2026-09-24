# Instala la status line de Claude Code en Windows (~\.claude)
#
# Uso (PowerShell):
#   .\install.ps1
#
# Qué hace:
#   1. Copia statusline.sh a %USERPROFILE%\.claude\statusline.sh
#   2. Registra el bloque "statusLine" en settings.json (conserva el resto)
#
# No necesita jq para instalar (usa el JSON nativo de PowerShell).
# jq SÍ hace falta en tiempo de ejecución: la status line corre bajo el
# bash de Git for Windows, que Claude Code ya usa.

$ErrorActionPreference = "Stop"

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir  = Join-Path $env:USERPROFILE ".claude"
$Settings   = Join-Path $ClaudeDir "settings.json"

New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null

# --- 1) Copiar el script ---
Copy-Item -Force (Join-Path $ScriptDir "statusline.sh") (Join-Path $ClaudeDir "statusline.sh")
Write-Host "OK  Copiado statusline.sh -> $ClaudeDir\statusline.sh"

# --- 2) Registrar en settings.json ---
$statusLine = [PSCustomObject]@{
    type    = "command"
    command = "bash ~/.claude/statusline.sh"
}

if (Test-Path $Settings) {
    $json = Get-Content $Settings -Raw | ConvertFrom-Json
    $json | Add-Member -NotePropertyName statusLine -NotePropertyValue $statusLine -Force
    $json | ConvertTo-Json -Depth 20 | Set-Content $Settings -Encoding UTF8
    Write-Host "OK  Actualizado 'statusLine' en $Settings (resto de ajustes intacto)"
} else {
    [PSCustomObject]@{ statusLine = $statusLine } |
        ConvertTo-Json -Depth 20 | Set-Content $Settings -Encoding UTF8
    Write-Host "OK  Creado $Settings con la status line"
}

# --- Aviso jq ---
$hasJq = $null -ne (Get-Command jq -ErrorAction SilentlyContinue)
Write-Host ""
if (-not $hasJq) {
    Write-Host "AVISO  Falta 'jq' (necesario en ejecucion). Instalalo con:"
    Write-Host "       winget install jqlang.jq    (o)    scoop install jq"
}
Write-Host "Listo. Reinicia Claude Code para ver la status line."
Write-Host "Nota: para los iconos necesitas una Nerd Font en tu terminal."
