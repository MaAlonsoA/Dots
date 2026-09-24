# Claude Code — Status Line

Status line de dos líneas para [Claude Code](https://claude.com/claude-code), portable entre **macOS**, **Linux** y **Windows**.

Todo lo necesario está en esta carpeta: no hay que descargar nada aparte del propio repo.

## Qué muestra

**Línea 1:**
- Rama de git (o `original → worktree` si estás en un worktree)
- Archivos modificados (`M:`) y sin trackear (`U:`), truncados si son muchos
- Modelo activo
- Uso de contexto `ctx %` (verde <50%, amarillo <80%, rojo ≥80%)
- Hora actual (alineada a la derecha)

**Línea 2:**
- Nombre del worktree (si aplica)
- Tokens: `in`, `out`, `cache-w`, `cache-r`, tamaño de ventana `win`
- Cuota de uso `5h %` y `7d %` (verde <50%, amarillo <80%, rojo ≥80%) — solo aparece en cuentas con suscripción Claude.ai (Pro/Max) y tras la primera respuesta de la API en la sesión; si no aplica, el segmento simplemente no se muestra
- Tiempo transcurrido de la sesión (alineado a la derecha)

## Contenido de la carpeta

| Archivo | Para qué |
|---------|----------|
| `statusline.sh` | El script de la status line (corre bajo bash en los tres sistemas) |
| `install.sh` | Instalador para macOS / Linux |
| `install.ps1` | Instalador para Windows (PowerShell) |
| `settings.example.json` | El bloque que se añade a `~/.claude/settings.json` |

---

## Instalación asistida por Claude Code (recomendado)

Abre Claude Code **dentro de este repo** y dile:

> «Instala la status line de `claude-code/` siguiendo su README»

Claude puede hacerlo sin descargar nada, solo con los archivos de esta carpeta. Los pasos que seguirá:

1. Copiar `claude-code/statusline.sh` → `~/.claude/statusline.sh`.
2. Añadir/actualizar la clave `statusLine` en `~/.claude/settings.json` con el contenido de `settings.example.json` (**conservando** el resto de ajustes; creando el archivo si no existe). Claude edita el JSON directamente, así que **no hace falta `jq` para instalar**.
3. Comprobar si `jq` está disponible (necesario en ejecución) y, si falta, indicar el comando para instalarlo.

> El único requisito en ejecución es **`jq`**, porque la status line corre bajo bash. En Windows, Claude Code ya usa el bash de Git for Windows.

---

## Instalación manual

### macOS / Linux

```bash
cd claude-code
./install.sh
```

### Windows (PowerShell)

```powershell
cd claude-code
.\install.ps1
```

### A mano (cualquier sistema)

```bash
cp statusline.sh ~/.claude/statusline.sh      # Windows: copia a %USERPROFILE%\.claude\
chmod +x ~/.claude/statusline.sh              # solo macOS/Linux
```

Y añade a `~/.claude/settings.json` el bloque de `settings.example.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline.sh"
  }
}
```

Reinicia Claude Code o abre una sesión nueva para verla.

## Requisitos

- **`jq`** — parseo del JSON que Claude Code pasa al script (en ejecución)
  - macOS: `brew install jq`
  - Debian/Ubuntu: `sudo apt install jq`
  - Windows: `winget install jqlang.jq` (o `scoop install jq`)
- **Nerd Font** en la terminal para los iconos (opcional; sin ella salen cuadraditos, el resto funciona)

## Actualizar el repo desde tu máquina

Si cambias el script en `~/.claude/statusline.sh` y quieres subirlo:

```bash
cp ~/.claude/statusline.sh claude-code/statusline.sh
```
