#!/usr/bin/env bash
# Link these dotfiles into place. Safe to re-run. Existing files are moved to *.bak.
#
#   git clone https://github.com/afonsodelgado/dotfiles ~/.dotfiles
#   ~/.dotfiles/install.sh
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME="${THEME:-tokyo-night}"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

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

echo "Linking configs from $DOTFILES"
link "$DOTFILES/nvim"                              "$CONFIG/nvim"
link "$DOTFILES/tmux/tmux.conf"                    "$CONFIG/tmux/tmux.conf"
link "$DOTFILES/starship.toml"                     "$CONFIG/starship.toml"
link "$DOTFILES/alacritty/alacritty.toml"          "$CONFIG/alacritty/alacritty.toml"
link "$DOTFILES/themes/$THEME/alacritty.toml"      "$CONFIG/alacritty/theme.toml"
link "$DOTFILES/ghostty/config"                    "$CONFIG/ghostty/config"
link "$DOTFILES/themes/$THEME/ghostty.conf"        "$CONFIG/ghostty/theme.conf"
link "$DOTFILES/themes/$THEME/btop.theme"          "$CONFIG/btop/themes/$THEME.theme"

ensure_line() {
  local file="$1" line="$2"
  touch "$file"
  grep -qxF "$line" "$file" || { printf '\n%s\n' "$line" >> "$file"; echo "  added   $line -> $file"; }
}

echo "Hooking shells"
ensure_line "$HOME/.bashrc" "export DOTFILES=\"$DOTFILES\"; source \"\$DOTFILES/bash/bashrc\""
ensure_line "$HOME/.zshrc"  "export DOTFILES=\"$DOTFILES\"; source \"\$DOTFILES/zsh/zshrc\""

if [[ $(uname) == Darwin ]] && command -v brew &> /dev/null; then
  echo "Installing Homebrew packages"
  brew bundle --file="$DOTFILES/Brewfile"
fi

if [[ $(uname) == Darwin ]]; then
  KARABINER_DIR="$CONFIG/karabiner/assets/complex_modifications"
  mkdir -p "$KARABINER_DIR"
  cp "$DOTFILES/karabiner/caps-lock-tmux-prefix.json" "$KARABINER_DIR/"
  echo "Karabiner rule copied. Enable it in Karabiner-Elements > Complex Modifications > Add rule."
fi

echo "Done. Open a new terminal. First Neovim start installs plugins."
