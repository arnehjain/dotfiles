#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

echo "==> Installing dotfiles (macOS)"
echo "    Source: $DOTFILES_DIR"

# 1. Install packages
echo ""
echo "==> Installing packages via Homebrew..."
brew install neovim ripgrep fd fzf bat eza zoxide tmux jq

# 2. Backup existing files, then symlink
backup_and_link() {
  local src="$1" dst="$2"
  if [[ -e "$dst" || -L "$dst" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/"
    echo "  Backed up $dst"
  fi
  ln -sf "$src" "$dst"
  echo "  Linked $dst -> $src"
}

echo ""
echo "==> Symlinking config files..."
backup_and_link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
mkdir -p "$HOME/.config"
backup_and_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
backup_and_link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# 3. TPM
echo ""
echo "==> Setting up tmux plugin manager (TPM)..."
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  echo "  TPM installed"
else
  echo "  TPM already installed"
fi

# 4. zshrc_local template
echo ""
echo "==> Setting up ~/.zshrc_local..."
if [[ ! -f "$HOME/.zshrc_local" ]]; then
  cp "$DOTFILES_DIR/zsh/zshrc_local.template" "$HOME/.zshrc_local"
  echo "  Created ~/.zshrc_local from template"
else
  echo "  ~/.zshrc_local already exists, skipping"
fi

# 5. Summary
echo ""
echo "==> Done!"
if [[ -d "$BACKUP_DIR" ]]; then
  echo "    Backups saved to: $BACKUP_DIR"
fi
echo "    Edit ~/.zshrc_local for secrets and machine-specific config."
echo "    Open tmux and press prefix+I to install TPM plugins."
echo "    Open nvim — lazy.nvim will bootstrap and install plugins automatically."
