# Sourced by both bash and zsh.

# macOS: put Homebrew on PATH here, not only in ~/.zprofile. An older ~/.zshrc that
# starts with PATH=... would otherwise drop it, and the brew tmux/nvim/starship vanish.
if [[ $OSTYPE == darwin* ]] && ! command -v brew &> /dev/null; then
  for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x $_brew ]]; then
      eval "$("$_brew" shellenv)"
      break
    fi
  done
  unset _brew
fi

export EDITOR="${EDITOR:-nvim}"
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi

# Color man pages with bat
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$PATH:$HOME/.local/bin" ;;
esac
