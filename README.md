# dotfiles

Personal dotfiles for zsh, neovim, and tmux.

## What's included

| Config | Description |
|--------|-------------|
| `zsh/.zshrc` | Shell config: history, completion, aliases, functions, tool integrations |
| `nvim/` | Neovim IDE setup: lazy.nvim, Catppuccin, Treesitter, LSP, nvim-cmp |
| `tmux/.tmux.conf` | tmux with Catppuccin Mocha theme and TPM plugins |

## Quick start

```sh
git clone https://github.com/arnehjain/dotfiles.git ~/dotfiles
cd ~/dotfiles

# macOS
./install-mac.sh

# Linux (Debian/Ubuntu)
./install-linux.sh
```

The install scripts will:
1. Install required packages (neovim, ripgrep, fd, fzf, bat, eza, zoxide, tmux, jq)
2. Back up any existing config files to `~/.dotfiles-backup/<timestamp>/`
3. Symlink `~/.zshrc`, `~/.config/nvim`, and `~/.tmux.conf` into place
4. Install TPM (tmux plugin manager)
5. Create `~/.zshrc_local` from the template (if it doesn't exist)

## ~/.zshrc_local

Machine-specific config that shouldn't be tracked in git goes in `~/.zshrc_local`.
Use `zsh/zshrc_local.template` as a starting point.

```sh
cp zsh/zshrc_local.template ~/.zshrc_local
# then edit ~/.zshrc_local to add secrets, tokens, PATH entries, etc.
```

## Post-install

**tmux**: Open a session and press `prefix + I` to install TPM plugins.

**neovim**: Open nvim — lazy.nvim will bootstrap itself and install all plugins on first launch.

## Tools

| Tool | Purpose |
|------|---------|
| [neovim](https://neovim.io) | Editor |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast grep (`rg`) |
| [fd](https://github.com/sharkdp/fd) | Fast find |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder (Ctrl-R, Ctrl-T, Alt-C) |
| [bat](https://github.com/sharkdp/bat) | Better `cat` |
| [eza](https://github.com/eza-community/eza) | Better `ls` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` with `z` |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer |
| [jq](https://stedolan.github.io/jq/) | JSON processor |
