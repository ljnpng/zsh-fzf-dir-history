# zsh-fzf-dir-history

Directory-aware command history for Zsh, powered by [fzf](https://github.com/junegunn/fzf).

Standard Zsh history is global — you get the same results no matter where you are. This plugin records **which directory** each command was run in, and shows that context when you search with `Ctrl+R`.

![demo](demo.gif)

## Features

- Every command is saved with its working directory
- `Ctrl+R` opens fzf with directory context shown alongside each command
- Automatic deduplication — only the most recent occurrence is kept
- `Ctrl+D` to delete an entry inline, `Ctrl+Y` to copy
- `Ctrl+S` to switch between all history and the current directory
- `Ctrl+J` to change to the recorded directory and insert the command

## Requirements

- Zsh
- [fzf](https://github.com/junegunn/fzf) (v0.74+)
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
| `ZFH_TOGGLE_SCOPE_KEY` | `ctrl-s` | Toggle all / current directory history |
| `ZFH_CD_INSERT_KEY` | `ctrl-j` | Change directory and insert the command |
| `ZFH_INSERT_KEY` | `enter` | Insert the command |
| `ZFH_COPY_KEY` | `ctrl-y` | Copy the command |
| `ZFH_DELETE_KEY` | `ctrl-d` | Delete the entry |

`ZFH_BIND_KEY` uses Zsh `bindkey` notation. Picker bindings use fzf key names, such as `ctrl-s`, `alt-j`, or `f2`. Assign a distinct key to each action. The picker header omits plain insertion and abbreviates `ctrl-` as `^`.

Example:

```zsh
export ZFH_HISTORY_FILE="$HOME/.my_dir_history"
export ZFH_BIND_KEY="^R"
export ZFH_TOGGLE_SCOPE_KEY="alt-s"
export ZFH_CD_INSERT_KEY="alt-j"
```

## Keybindings (inside fzf)

| Key | Action |
|---|---|
| `Ctrl+Y` | Copy selected command to clipboard |
| `Ctrl+D` | Delete selected entry from history |
| `Ctrl+S` | Toggle all history / current directory, preserving the search query |
| `Enter` | Insert command into prompt |
| `Ctrl+J` | Change to the recorded directory, then insert the command |

The picker starts with all history. Current directory filtering uses the exact directory where the picker was opened, excluding subdirectories.

The command is not executed. If changing directory fails, the prompt content is preserved.

`Ctrl+D` removes an entry from the list after the history file is updated. If the update fails, the entry remains and the header shows an error.

## How it works

1. `zshaddhistory` hook captures every command with `$PWD`, saved to a TSV file
2. On `Ctrl+R`, `fzf-hist-list` reads the file in reverse, deduplicates, and formats entries
3. fzf displays commands with abbreviated directory paths in gray
4. Selected command is inserted into the current prompt

Commands are deduplicated globally by command text. When a command is used in several directories, only its most recent directory is retained. Shared commands are treated as global; the directory is secondary context. Current directory filtering therefore shows commands whose retained directory matches the current directory.

## License

MIT
