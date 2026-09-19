# dotfiles

The parts of my [Omarchy](https://omarchy.org) setup that work anywhere: terminal, tmux, Neovim
(LazyVim), starship prompt, and shell aliases. Hyprland and the rest of the desktop stay on the
Linux machine.

## Install on macOS

```bash
xcode-select --install                     # git, make, clang (Neovim needs them for treesitter)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone https://github.com/afonsodelgado/dotfiles ~/.dotfiles
~/.dotfiles/install.sh
```

`install.sh` symlinks everything into `~/.config`, hooks `~/.zshrc` and `~/.bashrc`, runs
`brew bundle`, and drops the Karabiner rule in place. Re-running it is safe. Anything it replaces
is moved to `*.bak`.

Then:

1. Open Ghostty (or Alacritty). Start tmux with `t`.
2. Open Karabiner-Elements, go to Complex Modifications, Add rule, and enable
   "Caps Lock as tmux prefix". Grant it Input Monitoring when asked.
3. Run `nvim`. LazyVim installs its plugins on first launch.

## What is here

| Path | What | Notes for macOS |
|---|---|---|
| `ghostty/`, `alacritty/` | Terminal config | Option is set to act as Alt, which the tmux bindings rely on. Font size raised from 9 to 13. |
| `themes/tokyo-night/` | Colors for terminal and btop | Omarchy swaps these on theme change. Here `THEME=... ./install.sh` picks one. |
| `tmux/tmux.conf` | Prefix Ctrl+Space, Alt-based pane and window keys, vi copy mode | Unchanged except `?` uses tmux's own key list instead of the Omarchy menu. |
| `nvim/` | LazyVim config | Minus Omarchy's theme hot-reload. `jk` leaves insert mode. |
| `starship.toml` | Prompt | Unchanged. |
| `shell/` | Aliases, git aliases, and tmux layout functions shared by bash and zsh | `git-aliases.sh` is the oh-my-zsh git set (gst, gcmsg, gco...). Also sourced on the Linux machine. |
| `bash/`, `zsh/` | Shell entry points | zsh is the macOS default and gets the same history search and completion feel. |
| `karabiner/` | Caps Lock tap sends Ctrl+Space in terminals | Same behaviour as the Hyprland bind on Linux. |
| `Brewfile` | Everything the above needs | |

## Keys worth knowing

tmux prefix is a tap of Caps Lock (or Ctrl+Space).

| Keys | Action |
|---|---|
| Alt+Enter / Alt+Shift+Enter | Split pane down / right |
| Ctrl+Alt+arrows | Move between panes |
| Alt+1..9 | Switch window |
| Alt+Left / Alt+Right | Previous / next window |
| Prefix c, r, x, k | New window, rename, kill pane, kill window |
| Prefix [ then v, y | Copy mode: select, yank |
| Prefix ? | List all bindings |

In Neovim, LazyVim defaults apply: Space Space finds files, Space / greps, gd goes to definition.
