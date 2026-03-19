# VHS demo for zsh-fzf-dir-history
Output demo.gif

Set Shell "zsh"
Set FontSize 16
Set Width 1000
Set Height 600
Set Theme "Catppuccin Mocha"
Set Padding 20
Set TypingSpeed 60ms

# Setup: create sample history and source plugin
Hide
Type `export ZFH_HISTORY_FILE="/tmp/demo_dir_history"` Enter
Sleep 300ms
Type `rm -f /tmp/demo_dir_history` Enter
Sleep 300ms
# Populate sample history
Type `printf '%s\t%s\n' '/Users/neo/projects/web-app' 'npm run dev' >> /tmp/demo_dir_history` Enter
Type `printf '%s\t%s\n' '/Users/neo/projects/web-app' 'npm test' >> /tmp/demo_dir_history` Enter
Type `printf '%s\t%s\n' '/Users/neo/projects/api-server' 'cargo build --release' >> /tmp/demo_dir_history` Enter
Type `printf '%s\t%s\n' '/Users/neo/projects/api-server' 'cargo test' >> /tmp/demo_dir_history` Enter
Type `printf '%s\t%s\n' '/Users/neo/dotfiles' 'vim .zshrc' >> /tmp/demo_dir_history` Enter
Type `printf '%s\t%s\n' '/Users/neo/projects/web-app' 'git push origin main' >> /tmp/demo_dir_history` Enter
Type `printf '%s\t%s\n' '/Users/neo/projects/api-server' 'docker compose up -d' >> /tmp/demo_dir_history` Enter
Type `printf '%s\t%s\n' '/Users/neo/projects/web-app' 'npx prettier --write .' >> /tmp/demo_dir_history` Enter
Type `printf '%s\t%s\n' '/Users/neo/dotfiles' 'brew update && brew upgrade' >> /tmp/demo_dir_history` Enter
Type `printf '%s\t%s\n' '/Users/neo/projects/api-server' 'git log --oneline -10' >> /tmp/demo_dir_history` Enter
Type `printf '%s\t%s\n' '/Users/neo/projects/web-app' 'npm install axios' >> /tmp/demo_dir_history` Enter
Type `printf '%s\t%s\n' '/Users/neo/dotfiles' 'stow zsh' >> /tmp/demo_dir_history` Enter

# Source the plugin
Type `source ./zsh-fzf-dir-history.plugin.zsh` Enter
Sleep 500ms
Type `clear` Enter
Sleep 300ms
Show

# Demo 1: Open history with Ctrl+R
Sleep 1s
Type "# Press Ctrl+R to search history with directory context" Enter
Sleep 1.5s
Ctrl+R
Sleep 2s

# Type to filter
Type "git"
Sleep 2s

# Select with Enter
Enter
Sleep 1.5s

# Demo 2: Filter by another keyword
Type "# Search again — try filtering by 'npm'" Enter
Sleep 1.5s
Ctrl+R
Sleep 2s
Type "npm"
Sleep 2s

# Escape to cancel
Escape
Sleep 1s

Type "# Each command shows which directory it was run in" Enter
Sleep 2s
