#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

echo "==> Installing dotfiles (Linux)"
echo "    Source: $DOTFILES_DIR"

# 1. Install packages via apt
echo ""
echo "==> Installing packages via apt..."
sudo apt update && sudo apt install -y neovim ripgrep fd-find fzf bat tmux jq curl

# Install eza
echo ""
echo "==> Installing eza..."
if command -v eza &>/dev/null; then
  echo "  eza already installed"
elif apt-cache show eza &>/dev/null 2>&1; then
  sudo apt install -y eza
else
  echo "  Installing eza via cargo..."
  if ! command -v cargo &>/dev/null; then
    echo "  cargo not found — install Rust first: https://rustup.rs"
    echo "  Skipping eza install"
  else
    cargo install eza
  fi
fi

# Install zoxide
echo ""
echo "==> Installing zoxide..."
if command -v zoxide &>/dev/null; then
  echo "  zoxide already installed"
else
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# 2. Create ~/bin symlinks for tools with different binary names on Debian/Ubuntu
echo ""
echo "==> Setting up ~/bin symlinks for bat/fd..."
mkdir -p "$HOME/bin"
if [[ -x /usr/bin/batcat ]] && ! command -v bat &>/dev/null; then
  ln -sf /usr/bin/batcat "$HOME/bin/bat"
  echo "  Linked ~/bin/bat -> /usr/bin/batcat"
fi
if [[ -x /usr/bin/fdfind ]] && ! command -v fd &>/dev/null; then
  ln -sf /usr/bin/fdfind "$HOME/bin/fd"
  echo "  Linked ~/bin/fd -> /usr/bin/fdfind"
fi

# 3. Backup existing files, then symlink
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

# 4. TPM
echo ""
echo "==> Setting up tmux plugin manager (TPM)..."
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  echo "  TPM installed"
else
  echo "  TPM already installed"
fi

# 5. zshrc_local template
echo ""
echo "==> Setting up ~/.zshrc_local..."
if [[ ! -f "$HOME/.zshrc_local" ]]; then
  cp "$DOTFILES_DIR/zsh/zshrc_local.template" "$HOME/.zshrc_local"
  echo "  Created ~/.zshrc_local from template"
else
  echo "  ~/.zshrc_local already exists, skipping"
fi

# 6. Summary
echo ""
echo "==> Done!"
if [[ -d "$BACKUP_DIR" ]]; then
  echo "    Backups saved to: $BACKUP_DIR"
fi
echo "    Edit ~/.zshrc_local for secrets and machine-specific config."
echo "    Open tmux and press prefix+I to install TPM plugins."
echo "    Open nvim — lazy.nvim will bootstrap and install plugins automatically."
