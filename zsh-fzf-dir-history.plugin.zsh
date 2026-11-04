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
: ${ZFH_TOGGLE_SCOPE_KEY:="ctrl-s"}
: ${ZFH_CD_INSERT_KEY:="ctrl-j"}
: ${ZFH_INSERT_KEY:="enter"}
: ${ZFH_COPY_KEY:="ctrl-y"}
: ${ZFH_DELETE_KEY:="ctrl-d"}

# --- FZF default options (only set if user hasn't customized) ----------------
if [[ -z "$FZF_DEFAULT_OPTS" ]]; then
  export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --inline-info
    --exact
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
  local selected selected_key selected_entry selected_command selected_directory
  local history_header="$ZFH_TOGGLE_SCOPE_KEY all/current · $ZFH_CD_INSERT_KEY cd+insert · $ZFH_COPY_KEY copy · $ZFH_DELETE_KEY delete"
  history_header="${history_header//ctrl-/^}"
  local delete_command="ZFH_HISTORY_FILE=${(q)_cmd_dir_history} ${(q)_ZFH_DIR}/bin/fzf-hist-delete"
  local list_command="ZFH_HISTORY_FILE=${(q)_cmd_dir_history} ${(q)_ZFH_DIR}/bin/fzf-hist-list"
  local -x _ZFH_ALL_HISTORY_COMMAND="$list_command"
  local -x _ZFH_CURRENT_HISTORY_COMMAND="$list_command ${(q)PWD}"
  selected=$(ZFH_HISTORY_FILE="$_cmd_dir_history" "$_ZFH_DIR/bin/fzf-hist-list" | \
    fzf --ansi --delimiter='\t' \
        --with-nth=2 \
        --nth=1 \
        --no-preview \
        --scheme=history \
        --exact \
        --prompt 'All> ' \
        --expect="$ZFH_INSERT_KEY,$ZFH_CD_INSERT_KEY" \
        --header "$history_header" \
        --bind "${ZFH_TOGGLE_SCOPE_KEY}:transform:
          if [ \"\$FZF_PROMPT\" = 'All> ' ]; then
            printf '%s\n' \"change-prompt(Current dir> )+reload(\$_ZFH_CURRENT_HISTORY_COMMAND)\"
          else
            printf '%s\n' \"change-prompt(All> )+reload(\$_ZFH_ALL_HISTORY_COMMAND)\"
          fi
        " \
        --bind "${ZFH_COPY_KEY}:execute-silent(echo -n {1} | pbcopy)+abort" \
        --bind "${ZFH_DELETE_KEY}:wait+transform(
          [ \"\$FZF_MATCH_COUNT\" -gt 0 ] || exit 0
          if $delete_command {3} {1} {4}; then
            printf '%s\n' 'exclude+change-header($history_header)'
          else
            printf '%s\n' 'change-header(Delete failed · $ZFH_DELETE_KEY retry)'
          fi
        )")
  if [[ -z "$selected" ]]; then
    zle reset-prompt
    return
  fi

  selected_key=${selected%%$'\n'*}
  selected_entry=${selected#*$'\n'}
  selected_command=${selected_entry%%$'\t'*}
  selected_entry=${selected_entry%$'\t'*}
  selected_directory=${selected_entry##*$'\t'}

  if [[ "$selected_key" == "$ZFH_CD_INSERT_KEY" ]] && ! builtin cd -- "$selected_directory"; then
    zle -M "Cannot change directory: $selected_directory"
    zle reset-prompt
    return 1
  fi

  LBUFFER="$selected_command"
  zle reset-prompt
}
zle -N fzf-dir-history-widget
bindkey -M viins "$ZFH_BIND_KEY" fzf-dir-history-widget
bindkey -M vicmd "$ZFH_BIND_KEY" fzf-dir-history-widget
