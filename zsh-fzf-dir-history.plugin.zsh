# =============================================================================
# zsh-fzf-dir-history: directory-aware command history with fzf
# =============================================================================

0=${(%):-%N}
_ZFH_DIR="${0:A:h}"

# --- Dependencies -----------------------------------------------------------
# Source fzf key bindings and completion (platform-aware)
if [[ "$OSTYPE" == darwin* ]]; then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
elif (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi

# Add plugin bin/ to PATH (idempotent)
[[ ":$PATH:" != *":${_ZFH_DIR}/bin:"* ]] && export PATH="${_ZFH_DIR}/bin:$PATH"

# --- Configuration (override via env vars before sourcing) -------------------
: ${ZFH_HISTORY_FILE:="$HOME/.zsh_dir_history"}
: ${ZFH_BIND_KEY:="^R"}

# --- FZF default options (only set if user hasn't customized) ----------------
if [[ -z "$FZF_DEFAULT_OPTS" ]]; then
  export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --inline-info
    --exact
    --bind 'ctrl-y:execute-silent(echo -n {} | pbcopy)+abort'
  "
fi

# --- History hook ------------------------------------------------------------
_cmd_dir_history="$ZFH_HISTORY_FILE"

zshaddhistory() {
  local cmd="${1%%$'\n'}"
  cmd="${cmd//$'\n'/ }"
  [[ -z "$cmd" || "$cmd" == " "* ]] && return 0
  if [[ -f "$_cmd_dir_history" ]]; then
    _DEL_CMD="$cmd" LC_ALL=C awk -F'\t' '
      BEGIN { c = ENVIRON["_DEL_CMD"]; gsub(/[[:space:]]+$/, "", c) }
      { f2 = $2; gsub(/[[:space:]]+$/, "", f2); if (f2 != c) print }
    ' "$_cmd_dir_history" > "$_cmd_dir_history.tmp" \
      && mv "$_cmd_dir_history.tmp" "$_cmd_dir_history"
  fi
  printf '%s\t%s\n' "$PWD" "$cmd" >> "$_cmd_dir_history"
  return 0
}

# --- Ctrl+R widget -----------------------------------------------------------
fzf-dir-history-widget() {
  local selected
  selected=$(ZFH_HISTORY_FILE="$_cmd_dir_history" fzf-hist-list | \
    fzf --ansi --delimiter='\t' \
        --with-nth=2 \
        --nth=1 \
        --no-preview \
        --scheme=history \
        --exact \
        --header '⌃Y copy · ⌃D delete' \
        --bind "ctrl-y:execute-silent(echo -n {1} | pbcopy)+abort" \
        --bind "ctrl-d:execute-silent(ZFH_HISTORY_FILE=\"$_cmd_dir_history\" fzf-hist-delete {3} {1})+reload(ZFH_HISTORY_FILE=\"$_cmd_dir_history\" fzf-hist-list)" | \
    cut -f1)
  if [[ -n "$selected" ]]; then
    LBUFFER="$selected"
  fi
  zle reset-prompt
}
zle -N fzf-dir-history-widget
bindkey -M viins "$ZFH_BIND_KEY" fzf-dir-history-widget
bindkey -M vicmd "$ZFH_BIND_KEY" fzf-dir-history-widget
