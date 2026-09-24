#!/usr/bin/env bash
# Instala la status line de Claude Code en ~/.claude
# Portable: funciona en macOS (BSD) y Linux (GNU).
#
# Uso:
#   ./install.sh
#
# Qué hace:
#   1. Copia statusline.sh a ~/.claude/statusline.sh
#   2. Registra el bloque "statusLine" en ~/.claude/settings.json
#      (conserva el resto de tus ajustes; crea el archivo si no existe)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"

# --- Requisito: jq ---
if ! command -v jq >/dev/null 2>&1; then
  echo "❌ Falta 'jq'. Instálalo primero:"
  echo "   macOS:  brew install jq"
  echo "   Debian: sudo apt install jq"
  exit 1
fi

mkdir -p "$CLAUDE_DIR"

# --- 1) Copiar el script ---
cp "$SCRIPT_DIR/statusline.sh" "$CLAUDE_DIR/statusline.sh"
chmod +x "$CLAUDE_DIR/statusline.sh"
echo "✅ Copiado statusline.sh → $CLAUDE_DIR/statusline.sh"

# --- 2) Registrar en settings.json ---
STATUSLINE_JSON='{"type":"command","command":"bash ~/.claude/statusline.sh"}'

if [ -f "$SETTINGS" ]; then
  tmp="$(mktemp)"
  jq --argjson sl "$STATUSLINE_JSON" '.statusLine = $sl' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  echo "✅ Actualizado 'statusLine' en $SETTINGS (resto de ajustes intacto)"
else
  jq -n --argjson sl "$STATUSLINE_JSON" '{statusLine: $sl}' > "$SETTINGS"
  echo "✅ Creado $SETTINGS con la status line"
fi

echo
echo "🎉 Listo. Reinicia Claude Code (o abre una sesión nueva) para verla."
echo "   Nota: para los iconos necesitas una Nerd Font en tu terminal."
