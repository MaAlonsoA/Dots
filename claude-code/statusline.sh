#!/usr/bin/env bash
# ~/.claude/statusline.sh — adaptado a macOS desde statusline-command.sh
# Cambios vs original (Linux/Git-bash):
#   - `stat -c %W/%Y` → BSD stat (`-f %B/%m`) con fallback a GNU.
#   - `sed 's/\x1b...'` → BSD sed no expande `\x1b`, se inyecta literal con printf.

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Worktree detection
worktree_branch=$(echo "$input" | jq -r '.worktree.branch // empty')
worktree_original_branch=$(echo "$input" | jq -r '.worktree.original_branch // empty')

# If inside a worktree, use the worktree path for git status (file changes)
# but show: original_branch → worktree_branch on line 1
# If not in a worktree, get branch normally from cwd
if [ -n "$worktree_branch" ]; then
  worktree_path=$(echo "$input" | jq -r '.worktree.path // empty')
  git_cwd="${worktree_path:-$cwd}"
  branch=""  # line 1 will use worktree_original_branch → worktree_branch format
else
  git_cwd="$cwd"
  branch=$(git -C "$git_cwd" --no-optional-locks branch --show-current 2>/dev/null)
fi

# Git modified file names (skip optional locks)
# Collect names of modified/added/deleted tracked files and untracked files separately
modified_files=()
untracked_files=()
git_branch_present="$branch"
[ -n "$worktree_branch" ] && git_branch_present="yes"

if [ -n "$git_branch_present" ]; then
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    xy="${line:0:2}"
    filepath="${line:3}"
    filepath="${filepath%% -> *}"
    filename=$(basename "$filepath")
    if [ "$xy" = "??" ]; then
      untracked_files+=("$filename")
    else
      modified_files+=("$filename")
    fi
  done < <(git -C "$git_cwd" --no-optional-locks status --porcelain 2>/dev/null)
fi

# Context usage
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Model short name
model=$(echo "$input" | jq -r '.model.display_name')

# Helper: truncate a string to max_len, appending "…" if truncated
truncate_str() {
  local s="$1"
  local max="$2"
  if [ "${#s}" -gt "$max" ]; then
    printf '%s' "${s:0:$((max - 1))}…"
  else
    printf '%s' "$s"
  fi
}

# Helper: join array into comma-separated string, truncating to total_max visible chars
# Appends "+N" suffix if items were cut
# Args: total_max, followed by the file names as positional params.
# (Positional params instead of `local -n` namerefs → compatible con bash 3.2,
#  el que trae macOS de fábrica, además de bash 4+/5 de Linux y Git Bash.)
join_files() {
  local total_max=$1
  shift
  local total=$#
  local result=""
  local remaining=0
  local used_chars=0
  local sep=""
  local i=0
  for name in "$@"; do
    # truncate individual filename to 20 chars
    name=$(truncate_str "$name" 20)
    candidate="${sep}${name}"
    if [ $((used_chars + ${#candidate})) -le $total_max ]; then
      result+="$candidate"
      used_chars=$((used_chars + ${#candidate}))
      sep=","
    else
      remaining=$(( total - i ))
      break
    fi
    i=$(( i + 1 ))
  done
  if [ "$remaining" -gt 0 ]; then
    result+="+${remaining}"
  fi
  printf '%s' "$result"
}

# Pre-computed ESC byte for sed substitutions (BSD sed no interpreta \x1b)
ESC=$(printf '\033')

# Build output with ANSI colors (dimmed-friendly)
out=""

# Nerd Font glyphs — literal UTF-8 characters embedded in the file.
GLYPH_BRANCH=$'\xee\x82\xa0'    # U+E0A0  nf-pl-branch (Powerline)
GLYPH_CPU=$'\xef\x84\xa1'       # U+F121  nf-fa-code (Font Awesome)
GLYPH_WORKTREE=$'\xee\x9c\xa5'  # U+E725  nf-dev-git_branch (Devicons)

# Branch segment
if [ -n "$worktree_branch" ]; then
  base="${worktree_original_branch:-develop}"
  out+="$(printf '\033[0;36m')${GLYPH_BRANCH} ${base}$(printf '\033[0m')"
elif [ -n "$branch" ]; then
  out+="$(printf '\033[0;36m')${GLYPH_BRANCH} ${branch}$(printf '\033[0m')"
fi

# Modified file names (shown in both worktree and normal sessions)
if [ -n "$git_branch_present" ]; then
  if [ "${#modified_files[@]}" -gt 0 ]; then
    files_str=$(join_files 60 "${modified_files[@]}")
    out+=" $(printf '\033[0;33m')M:${files_str}$(printf '\033[0m')"
  fi

  if [ "${#untracked_files[@]}" -gt 0 ]; then
    files_str=$(join_files 40 "${untracked_files[@]}")
    out+=" $(printf '\033[0;35m')U:${files_str}$(printf '\033[0m')"
  fi
fi

# Model segment
out+="  $(printf '\033[0;33m')${GLYPH_CPU} ${model}$(printf '\033[0m')"

# Context segment
if [ -n "$used" ]; then
  used_int=${used%.*}
  if [ "$used_int" -ge 80 ]; then
    color="$(printf '\033[0;31m')"   # red
  elif [ "$used_int" -ge 50 ]; then
    color="$(printf '\033[0;33m')"   # yellow
  else
    color="$(printf '\033[0;32m')"   # green
  fi
  out+="  ${color}ctx ${used}%$(printf '\033[0m')"
fi

# Session elapsed time — derive from transcript file birth/mtime (cross-platform)
session_time=""
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  # BSD stat (macOS): -f '%B' = birth, '%m' = mtime
  # GNU stat (Linux/Git-bash): -c '%W' = birth, '%Y' = mtime
  start_epoch=$(stat -f '%B' "$transcript_path" 2>/dev/null || stat -c '%W' "$transcript_path" 2>/dev/null)
  if [ -z "$start_epoch" ] || [ "$start_epoch" = "0" ]; then
    start_epoch=$(stat -f '%m' "$transcript_path" 2>/dev/null || stat -c '%Y' "$transcript_path" 2>/dev/null)
  fi
  if [ -n "$start_epoch" ] && [ "$start_epoch" != "0" ]; then
    now_epoch=$(date +%s)
    elapsed=$(( now_epoch - start_epoch ))
    if [ "$elapsed" -ge 0 ]; then
      hrs=$(( elapsed / 3600 ))
      mins=$(( (elapsed % 3600) / 60 ))
      secs=$(( elapsed % 60 ))
      if [ "$hrs" -gt 0 ]; then
        session_time=$(printf '%dh%02dm' "$hrs" "$mins")
      else
        session_time=$(printf '%dm%02ds' "$mins" "$secs")
      fi
    fi
  fi
fi

# Time segment (right-aligned)
time_str=$(date +%H:%M:%S)

# Line 1 right segment: current time only
right1_visible="${time_str}"
right1_colored="$(printf '\033[0;34m')${time_str}$(printf '\033[0m')"

# Strip ANSI escapes to measure visible length of left content
out_visible=$(printf '%s' "$out" | sed "s/${ESC}\[[0-9;]*m//g")
out_visible_len=${#out_visible}

# Get terminal width. Claude Code v2.1.153+ exporta COLUMNS al subproceso,
# pero por si llega vacío o stale (ej. terminal redimensionado a media pantalla),
# intentamos también /dev/tty con stty antes de caer a un default.
get_term_width() {
  local w
  if [ -n "$COLUMNS" ] && [ "$COLUMNS" -gt 0 ] 2>/dev/null; then
    printf '%s' "$COLUMNS"; return
  fi
  if w=$(stty size < /dev/tty 2>/dev/null); then
    w=${w#* }
    if [ -n "$w" ] && [ "$w" -gt 0 ] 2>/dev/null; then
      printf '%s' "$w"; return
    fi
  fi
  printf '120'
}
term_width=$(get_term_width)
# Claude Code añade un pequeño margen lateral al renderizar el statusline.
# Sin esta resta, la última columna se trunca con "…".
term_width=$(( term_width - 4 ))
[ "$term_width" -lt 20 ] && term_width=20

# Calculate padding needed between left content and right-aligned segment (line 1)
pad=$(( term_width - out_visible_len - ${#right1_visible} ))
if [ "$pad" -lt 2 ]; then pad=2; fi

padding=$(printf '%*s' "$pad" "")

printf '%s%s%s\n' "$out" "$padding" "$right1_colored"

# Second line: token stats
total_in=$(echo "$input"  | jq -r '.context_window.total_input_tokens  // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
cache_w=$(echo "$input"   | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_r=$(echo "$input"   | jq -r '.context_window.current_usage.cache_read_input_tokens    // 0')
ctx_size=$(echo "$input"  | jq -r '.context_window.context_window_size // 0')

# Format numbers with k suffix for readability
fmt_k() {
  local n=$1
  if [ "$n" -ge 1000 ]; then
    printf '%dk' $(( n / 1000 ))
  else
    printf '%d' "$n"
  fi
}

# Worktree segment (beginning of line 2) — branch already shown on line 1
worktree_name=$(echo "$input" | jq -r '.worktree.name // empty')

line2=""
if [ -n "$worktree_name" ]; then
  line2+="$(printf '\033[0;32m')${GLYPH_WORKTREE} ${worktree_name}$(printf '\033[0m')  "
fi
line2+="$(printf '\033[2;37m')in:$(fmt_k "$total_in")$(printf '\033[0m')"
line2+=" $(printf '\033[2;37m')out:$(fmt_k "$total_out")$(printf '\033[0m')"
if [ "$cache_w" -gt 0 ]; then
  line2+=" $(printf '\033[2;35m')cache-w:$(fmt_k "$cache_w")$(printf '\033[0m')"
fi
if [ "$cache_r" -gt 0 ]; then
  line2+=" $(printf '\033[2;36m')cache-r:$(fmt_k "$cache_r")$(printf '\033[0m')"
fi
if [ "$ctx_size" -gt 0 ]; then
  line2+=" $(printf '\033[2;37m')win:$(fmt_k "$ctx_size")$(printf '\033[0m')"
fi

# Line 2 right segment: session elapsed time (right-aligned)
if [ -n "$session_time" ]; then
  line2_visible=$(printf '%s' "$line2" | sed "s/${ESC}\[[0-9;]*m//g")
  right2_visible="${session_time}"
  right2_colored="$(printf '\033[0;35m')${session_time}$(printf '\033[0m')"
  pad2=$(( term_width - ${#line2_visible} - ${#right2_visible} ))
  if [ "$pad2" -lt 2 ]; then pad2=2; fi
  padding2=$(printf '%*s' "$pad2" "")
  printf '%s%s%s' "$line2" "$padding2" "$right2_colored"
else
  printf '%s' "$line2"
fi
