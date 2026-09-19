# Sourced by both bash and zsh.
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
