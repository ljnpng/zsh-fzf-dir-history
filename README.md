# zsh-fzf-dir-history

Directory-aware command history for Zsh, powered by [fzf](https://github.com/junegunn/fzf).

Standard Zsh history is global — you get the same results no matter where you are. This plugin records **which directory** each command was run in, and shows that context when you search with `Ctrl+R`.

![demo](https://github.com/user-attachments/assets/placeholder)

## Features

- Every command is saved with its working directory
- `Ctrl+R` opens fzf with directory context shown alongside each command
- Automatic deduplication — only the most recent occurrence is kept
- `Ctrl+D` to delete an entry inline, `Ctrl+Y` to copy

## Requirements

- Zsh
- [fzf](https://github.com/junegunn/fzf) (v0.30+)
- awk (system default is fine)

## Install

### zinit

```zsh
zinit light ljnpng/zsh-fzf-dir-history
```

### oh-my-zsh

```zsh
git clone https://github.com/ljnpng/zsh-fzf-dir-history \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-fzf-dir-history
```

Add to `.zshrc`:

```zsh
plugins=(... zsh-fzf-dir-history)
```

### Manual

```zsh
git clone https://github.com/ljnpng/zsh-fzf-dir-history ~/.zsh-fzf-dir-history
echo 'source ~/.zsh-fzf-dir-history/zsh-fzf-dir-history.plugin.zsh' >> ~/.zshrc
```

## Configuration

Set these environment variables **before** sourcing the plugin:

| Variable | Default | Description |
|---|---|---|
| `ZFH_HISTORY_FILE` | `~/.zsh_dir_history` | Path to the history file |
| `ZFH_BIND_KEY` | `^R` | Key binding for the history widget |

Example:

```zsh
export ZFH_HISTORY_FILE="$HOME/.my_dir_history"
export ZFH_BIND_KEY="^R"
```

## Keybindings (inside fzf)

| Key | Action |
|---|---|
| `Ctrl+Y` | Copy selected command to clipboard |
| `Ctrl+D` | Delete selected entry from history |
| `Enter` | Insert command into prompt |

## How it works

1. `zshaddhistory` hook captures every command with `$PWD`, saved to a TSV file
2. On `Ctrl+R`, `fzf-hist-list` reads the file in reverse, deduplicates, and formats entries
3. fzf displays commands with abbreviated directory paths in gray
4. Selected command is inserted into the current prompt

## License

MIT
