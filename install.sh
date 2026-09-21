#!/usr/bin/env bash
# Link these dotfiles into place. Safe to re-run. Existing files are moved to *.bak.
#
#   git clone https://github.com/afonsodelgado/dotfiles ~/.dotfiles
#   ~/.dotfiles/install.sh            install, then report what is wired up
#   ~/.dotfiles/install.sh --check    only report: tools, versions, links, shell hook
#
# Detects three platforms:
#   macos    Homebrew packages, Ghostty, Karabiner for Caps Lock
#   omarchy  Only the personal layer: Omarchy already ships the rest
#   linux    pacman/apt packages, foot/Ghostty, keyd for Caps Lock
#
# Written for the bash 3.2 that macOS ships, so no -v tests, negative array indices or mapfile.
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

# A fresh macOS shell does not have Homebrew on PATH until its shellenv line is run. Find it anyway.
if [[ $PLATFORM == macos ]] && ! command -v brew &> /dev/null; then
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x $b ]] && eval "$("$b" shellenv)" && break
  done
fi

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
# Checks: what is installed, linked and hooked. Run alone with --check.
# ---------------------------------------------------------------------------
STATUS=0
ok()   { echo "  ok      $*"; }
warn() { echo "  WARN    $*"; STATUS=1; }

# version_ge 3.5 3.3 -> true
version_ge() {
  [[ $(printf '%s\n%s\n' "$1" "$2" | sort -t. -k1,1n -k2,2n | head -1) == "$2" ]]
}

# check_cmd <name> [<minimum major.minor>]
check_cmd() {
  local name="$1" min="${2:-}" path ver
  path=$(command -v "$name" 2> /dev/null) || { warn "$name not found on PATH"; return 0; }
  ver=$({ "$name" --version 2> /dev/null || "$name" -V 2> /dev/null; } | grep -oE '[0-9]+\.[0-9]+' | head -1) || ver=""
  if [[ -n $min && -n $ver ]] && ! version_ge "$ver" "$min"; then
    warn "$name $ver at $path is older than $min"
  else
    ok "$name ${ver:+$ver }at $path"
  fi
}

check_link() {
  local dst="$1" src="$2"
  if [[ -L $dst && $(readlink "$dst") == "$src" ]]; then
    ok "$dst"
  else
    warn "$dst is not linked to $src"
  fi
}

check_line() {
  local file="$1" line="$2"
  if [[ -f $file ]] && grep -qxF "$line" "$file"; then
    ok "$file sources the dotfiles"
  else
    warn "$file does not source the dotfiles"
  fi
}

run_checks() {
  echo "Checking the $PLATFORM setup"

  if [[ $PLATFORM == macos ]]; then
    if command -v brew &> /dev/null; then
      ok "brew at $(command -v brew)"
    else
      warn "brew is not on PATH; run the shellenv line the Homebrew installer printed"
    fi
    if [[ -d /Applications/Ghostty.app || -d $HOME/Applications/Ghostty.app ]]; then
      ok "Ghostty.app"
    else
      warn "Ghostty.app not found in /Applications"
    fi
    if ls "$HOME/Library/Fonts" /Library/Fonts 2> /dev/null | grep -i 'JetBrainsMonoNerdFont' > /dev/null; then
      ok "JetBrainsMono Nerd Font"
    else
      warn "JetBrainsMono Nerd Font not installed (brew install --cask font-jetbrains-mono-nerd-font)"
    fi
  elif command -v fc-list &> /dev/null; then
    if fc-list 2> /dev/null | grep -i 'JetBrainsMono.*Nerd' > /dev/null; then
      ok "JetBrainsMono Nerd Font"
    else
      warn "JetBrainsMono Nerd Font not installed"
    fi
  fi

  # Versions the configs rely on: tmux 3.5 for extended-keys-format, Neovim 0.10 for LazyVim.
  check_cmd tmux 3.5
  check_cmd nvim 0.10
  check_cmd starship
  check_cmd zoxide
  check_cmd fzf 0.48
  check_cmd eza
  check_cmd bat
  check_cmd rg
  check_cmd fd
  check_cmd lazygit

  if [[ -e $HOME/.tmux.conf || -L $HOME/.tmux.conf ]]; then
    warn "$HOME/.tmux.conf exists; tmux reads it instead of $CONFIG/tmux/tmux.conf. Remove or rename it."
  fi
  check_link "$CONFIG/tmux/tmux.conf" "$DOTFILES/tmux/tmux.conf"
  check_link "$CONFIG/starship.toml" "$DOTFILES/starship.toml"

  if [[ $PLATFORM == omarchy ]]; then
    check_link "$CONFIG/nvim/lua/config/keymaps.lua" "$DOTFILES/nvim/lua/config/keymaps.lua"
    check_line "$HOME/.bashrc" "source \"$DOTFILES/shell/git-aliases.sh\""
  else
    check_link "$CONFIG/nvim" "$DOTFILES/nvim"
    check_link "$CONFIG/ghostty/config" "$DOTFILES/ghostty/config"
    if [[ $PLATFORM == macos ]]; then
      check_line "$HOME/.zshrc" "export DOTFILES=\"$DOTFILES\"; source \"\$DOTFILES/zsh/zshrc\""
    else
      check_line "$HOME/.bashrc" "export DOTFILES=\"$DOTFILES\"; source \"\$DOTFILES/bash/bashrc\""
    fi
  fi

  if [[ $PLATFORM == macos ]]; then
    if [[ -f $CONFIG/karabiner/karabiner.json ]] && grep -q 'Caps Lock sends Ctrl+Space' "$CONFIG/karabiner/karabiner.json"; then
      ok "Karabiner rule enabled"
      if pgrep -q karabiner_grabber; then
        ok "Karabiner grabber running"
      else
        warn "Karabiner is installed but its grabber is not running: open Karabiner-Elements and approve it in System Settings > Privacy & Security (Input Monitoring, and the driver extension)"
      fi
      if grep -q '"from": *{ *"key_code": *"caps_lock"' "$CONFIG/karabiner/karabiner.json" && grep -q 'simple_modifications' "$CONFIG/karabiner/karabiner.json"; then
        echo "  note    If Karabiner > Simple Modifications also remaps caps_lock, remove that entry; it runs before this rule."
      fi
    elif [[ -d /Applications/Karabiner-Elements.app ]]; then
      warn "Karabiner rule not enabled yet: Karabiner-Elements > Complex Modifications > Add rule > Caps Lock as tmux prefix"
    else
      warn "Karabiner-Elements not installed (brew install --cask karabiner-elements)"
    fi
    echo "  note    If Ctrl+Space does nothing: System Settings > Keyboard > Keyboard Shortcuts > Input Sources,"
    echo "          untick 'Select the previous input source'. macOS grabs Ctrl+Space when that is on."
  fi

  if [[ $STATUS == 0 ]]; then
    echo "All good. Open a new terminal (or run: exec \$SHELL) and start tmux with: t"
  else
    echo "Fix the WARN lines above, then open a new terminal."
  fi
}

if [[ ${1:-} == --check ]]; then
  run_checks
  exit $STATUS
fi

# ---------------------------------------------------------------------------
# Packages
# ---------------------------------------------------------------------------
install_packages_linux() {
  if command -v pacman &> /dev/null; then
    echo "Installing packages with pacman"
    sudo pacman -S --needed --noconfirm \
      tmux neovim starship zoxide fzf eza bat ripgrep fd lazygit btop mise jq \
      ttf-jetbrains-mono-nerd foot ghostty keyd \
      || echo "  WARN    pacman failed; continuing with the configs"
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
      # A single failing item (an app already installed by hand, say) must not stop the
      # configs below from being linked. The check at the end reports what is missing.
      brew bundle --file="$DOTFILES/Brewfile" --no-upgrade \
        || echo "  WARN    some Homebrew items failed; continuing with the configs"
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

# tmux reads ~/.tmux.conf first and then ignores ~/.config/tmux/tmux.conf entirely.
if [[ -e $HOME/.tmux.conf || -L $HOME/.tmux.conf ]]; then
  mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak"
  echo "  backup  $HOME/.tmux.conf -> $HOME/.tmux.conf.bak (it would shadow the tmux.conf in ~/.config)"
fi
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
  # Appended at the end on purpose: it must run after anything already in the file
  # (oh-my-zsh, an old PATH= line) so these settings win.
  ensure_line "$HOME/.bashrc" "export DOTFILES=\"$DOTFILES\"; source \"\$DOTFILES/bash/bashrc\""
  ensure_line "$HOME/.zshrc"  "export DOTFILES=\"$DOTFILES\"; source \"\$DOTFILES/zsh/zshrc\""
fi

# ---------------------------------------------------------------------------
# Caps Lock as tmux prefix
# ---------------------------------------------------------------------------
case $PLATFORM in
  macos)
    KARABINER_DIR="$CONFIG/karabiner/assets/complex_modifications"
    KARABINER_JSON="$CONFIG/karabiner/karabiner.json"
    RULE="$DOTFILES/karabiner/caps-lock-tmux-prefix.json"
    mkdir -p "$KARABINER_DIR"
    cp "$RULE" "$KARABINER_DIR/"
    # Karabiner reloads karabiner.json on change, so the rule can be enabled directly:
    # replace any earlier copy in the selected profile and append the current one.
    if [[ -f $KARABINER_JSON ]] && command -v jq &> /dev/null; then
      jq --slurpfile r "$RULE" '
        ($r[0].rules[0]) as $rule
        | .profiles |= map(
            if .selected == true then
              .complex_modifications.rules =
                ((.complex_modifications.rules // []) | map(select(.description != $rule.description))) + [$rule]
            else . end)' "$KARABINER_JSON" > "$KARABINER_JSON.tmp" && mv "$KARABINER_JSON.tmp" "$KARABINER_JSON"
      echo "Karabiner rule enabled in $KARABINER_JSON."
    else
      echo "Karabiner rule copied. Open Karabiner-Elements once (it creates karabiner.json), then re-run install.sh to enable it."
    fi
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

echo
run_checks
echo "First Neovim start installs plugins; wait for it to finish, then restart nvim."
