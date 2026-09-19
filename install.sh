#!/usr/bin/env bash
# Link these dotfiles into place. Safe to re-run. Existing files are moved to *.bak.
#
#   git clone https://github.com/afonsodelgado/dotfiles ~/.dotfiles
#   ~/.dotfiles/install.sh
#
# Detects three platforms:
#   macos    Homebrew packages, Ghostty/Alacritty, Karabiner for Caps Lock
#   omarchy  Only the personal layer: Omarchy already ships the rest
#   linux    pacman/apt packages, foot/Ghostty/Alacritty, keyd for Caps Lock
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME="${THEME:-tokyo-night}"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

if [[ $(uname) == Darwin ]]; then
  PLATFORM=macos
elif [[ -d /usr/share/omarchy ]]; then
  PLATFORM=omarchy
else
  PLATFORM=linux
fi
echo "Platform: $PLATFORM"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -L $dst && $(readlink "$dst") == "$src" ]]; then
    echo "  ok      $dst"
    return
  fi
  if [[ -e $dst || -L $dst ]]; then
    mv "$dst" "$dst.bak"
    echo "  backup  $dst -> $dst.bak"
  fi
  ln -s "$src" "$dst"
  echo "  link    $dst"
}

ensure_line() {
  local file="$1" line="$2"
  touch "$file"
  grep -qxF "$line" "$file" || { printf '\n%s\n' "$line" >> "$file"; echo "  added   $line -> $file"; }
}

# ---------------------------------------------------------------------------
# Packages
# ---------------------------------------------------------------------------
install_packages_linux() {
  if command -v pacman &> /dev/null; then
    echo "Installing packages with pacman"
    sudo pacman -S --needed --noconfirm \
      tmux neovim starship zoxide fzf eza bat ripgrep fd lazygit btop mise jq \
      ttf-jetbrains-mono-nerd foot ghostty keyd
  elif command -v apt-get &> /dev/null; then
    echo "Installing packages with apt (some may be missing on older releases)"
    sudo apt-get update
    local pkg
    for pkg in tmux neovim zoxide fzf eza bat ripgrep fd-find btop jq keyd fonts-jetbrains-mono; do
      sudo apt-get install -y "$pkg" || echo "  skip    $pkg (not in this release; see README)"
    done
    command -v starship &> /dev/null || curl -sS https://starship.rs/install.sh | sh
    command -v mise &> /dev/null || curl https://mise.run | sh
    echo "  note    lazygit, ghostty and the Nerd Font are not in apt; see README."
  else
    echo "No pacman or apt found. Install the packages listed in Brewfile manually."
  fi
}

case $PLATFORM in
  macos)
    if command -v brew &> /dev/null; then
      echo "Installing Homebrew packages"
      brew bundle --file="$DOTFILES/Brewfile"
    else
      echo "Homebrew not found; skipping packages. Install it, then re-run."
    fi
    ;;
  linux) install_packages_linux ;;
  omarchy) echo "Packages: Omarchy already provides them." ;;
esac

# ---------------------------------------------------------------------------
# Configs
# ---------------------------------------------------------------------------
echo "Linking configs from $DOTFILES"
link "$DOTFILES/tmux/tmux.conf" "$CONFIG/tmux/tmux.conf"
link "$DOTFILES/starship.toml"  "$CONFIG/starship.toml"

if [[ $PLATFORM == omarchy ]]; then
  # Omarchy owns ~/.config/nvim (theme symlink, hot reload). Overlay personal files only.
  link "$DOTFILES/nvim/lua/config/keymaps.lua" "$CONFIG/nvim/lua/config/keymaps.lua"
  # foot follows the live Omarchy theme instead of the static one in this repo.
  link "$DOTFILES/foot/foot.ini"                              "$CONFIG/foot/foot.ini"
  link "$HOME/.local/state/omarchy/current/theme/foot.ini"    "$CONFIG/foot/theme.ini"
else
  link "$DOTFILES/nvim"                          "$CONFIG/nvim"
  link "$DOTFILES/alacritty/alacritty.toml"      "$CONFIG/alacritty/alacritty.toml"
  link "$DOTFILES/themes/$THEME/alacritty.toml"  "$CONFIG/alacritty/theme.toml"
  link "$DOTFILES/ghostty/config"                "$CONFIG/ghostty/config"
  link "$DOTFILES/themes/$THEME/ghostty.conf"    "$CONFIG/ghostty/theme.conf"
  link "$DOTFILES/themes/$THEME/btop.theme"      "$CONFIG/btop/themes/$THEME.theme"
  if [[ $PLATFORM == linux ]]; then
    link "$DOTFILES/foot/foot.ini"               "$CONFIG/foot/foot.ini"
    link "$DOTFILES/themes/$THEME/foot.ini"      "$CONFIG/foot/theme.ini"
  fi
fi

# ---------------------------------------------------------------------------
# Shell
# ---------------------------------------------------------------------------
echo "Hooking shells"
if [[ $PLATFORM == omarchy ]]; then
  # Omarchy's own rc handles prompt, aliases and tools. Add only the shared git aliases.
  ensure_line "$HOME/.bashrc" "source \"$DOTFILES/shell/git-aliases.sh\""
else
  ensure_line "$HOME/.bashrc" "export DOTFILES=\"$DOTFILES\"; source \"\$DOTFILES/bash/bashrc\""
  ensure_line "$HOME/.zshrc"  "export DOTFILES=\"$DOTFILES\"; source \"\$DOTFILES/zsh/zshrc\""
fi

# ---------------------------------------------------------------------------
# Caps Lock as tmux prefix
# ---------------------------------------------------------------------------
case $PLATFORM in
  macos)
    KARABINER_DIR="$CONFIG/karabiner/assets/complex_modifications"
    mkdir -p "$KARABINER_DIR"
    cp "$DOTFILES/karabiner/caps-lock-tmux-prefix.json" "$KARABINER_DIR/"
    echo "Karabiner rule copied. Enable it in Karabiner-Elements > Complex Modifications > Add rule."
    ;;
  omarchy)
    link "$DOTFILES/hypr/caps_lock_tmux_prefix.lua" "$CONFIG/hypr/caps_lock_tmux_prefix.lua"
    ensure_line "$CONFIG/hypr/hyprland.lua" 'require("hypr.caps_lock_tmux_prefix")'
    command -v hyprctl &> /dev/null && hyprctl reload > /dev/null && echo "Hyprland reloaded."
    ;;
  linux)
    echo "Caps Lock as tmux prefix needs keyd (root):"
    echo "  sudo mkdir -p /etc/keyd && sudo cp $DOTFILES/keyd/default.conf /etc/keyd/ && sudo systemctl enable --now keyd"
    ;;
esac

echo "Done. Open a new terminal. First Neovim start installs plugins."
