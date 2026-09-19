# dotfiles

The parts of my [Omarchy](https://omarchy.org) setup that work anywhere: terminal, tmux, Neovim
(LazyVim), starship prompt, and shell aliases. Plus the personal layer on top of Omarchy itself, so
a fresh Omarchy machine ends up identical.

`install.sh` detects the platform (macOS, Omarchy, other Linux), symlinks configs into `~/.config`,
hooks the shell, installs packages where it can, and sets up Caps Lock as the tmux prefix. It is
safe to re-run. Anything it replaces is moved to `*.bak`.

## Installing on macOS

```bash
xcode-select --install                     # git, make, clang (Neovim needs them for treesitter)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone https://github.com/afonsodelgado/dotfiles ~/.dotfiles
~/.dotfiles/install.sh
```

After the Homebrew installer finishes, run the two `eval` lines it prints (or open a new terminal)
before the last command, otherwise `brew bundle` is skipped. Then:

1. Open Ghostty (or Alacritty). Start tmux with `t`.
2. Open Karabiner-Elements, go to Complex Modifications, Add rule, and enable
   "Caps Lock as tmux prefix". Grant it Input Monitoring when asked.
3. Run `nvim`. LazyVim installs its plugins on first launch.

## Installing on Linux

### On an Omarchy machine

Omarchy already ships the terminal, tmux, Neovim, prompt and shell setup. The installer only adds
the personal layer on top, and leaves Omarchy's theme switching intact:

```bash
git clone https://github.com/afonsodelgado/dotfiles ~/Projects/dotfiles
~/Projects/dotfiles/install.sh
```

What it does there:

- Links `tmux.conf` and `starship.toml`. The tmux file is Omarchy's, with one change: `Prefix ?`
  falls back to tmux's own key list on machines without the Omarchy menu.
- Overlays `keymaps.lua` (the `jk` mapping) into Omarchy's Neovim config. The rest of that
  directory stays Omarchy-managed so theme switching keeps working.
- Links `foot.ini`, pointed at Omarchy's live theme.
- Sources `shell/git-aliases.sh` from `~/.bashrc`. Omarchy's own rc handles everything else.
- Links `hypr/caps_lock_tmux_prefix.lua`, adds one `require` line to `hyprland.lua`, and reloads
  Hyprland. A tap of Caps Lock then sends Ctrl+Space in terminal windows only.

### On any other Linux

```bash
git clone https://github.com/afonsodelgado/dotfiles ~/.dotfiles
~/.dotfiles/install.sh
sudo mkdir -p /etc/keyd && sudo cp ~/.dotfiles/keyd/default.conf /etc/keyd/ && sudo systemctl enable --now keyd
```

The installer uses `pacman` or `apt` for packages. On Arch everything is in the repos. On
Debian/Ubuntu a few things need a manual step afterwards:

- **lazygit**: https://github.com/jesseduffield/lazygit/releases
- **Ghostty**: https://ghostty.org/download (foot is installed from apt and works on Wayland)
- **JetBrainsMono Nerd Font**: https://www.nerdfonts.com/font-downloads, unzip into `~/.local/share/fonts`, run `fc-cache -f`
- `starship` and `mise` are installed by their official scripts if apt lacks them.

The last command sets up **keyd** so a Caps Lock tap sends Ctrl+Space. Unlike the Omarchy and
Karabiner versions this applies in every app, since keyd sits below the desktop. Caps Lock's own
toggle is gone; hold Shift for capitals.

Pick a terminal: **foot** on Wayland desktops, **Ghostty** anywhere. Both configs are linked.

## What is here

| Path | What | Notes for macOS |
|---|---|---|
| `ghostty/`, `alacritty/` | Terminal config | Option is set to act as Alt, which the tmux bindings rely on. Font size raised from 9 to 13. |
| `themes/tokyo-night/` | Colors for terminals and btop | On Omarchy the live theme is used instead. Elsewhere `THEME=... ./install.sh` picks one. |
| `tmux/tmux.conf` | Prefix Ctrl+Space, Alt-based pane and window keys, vi copy mode | Unchanged except `?` uses tmux's own key list instead of the Omarchy menu. |
| `nvim/` | LazyVim config | Minus Omarchy's theme hot-reload. `jk` leaves insert mode. |
| `starship.toml` | Prompt | Unchanged. |
| `shell/` | Aliases, git aliases, and tmux layout functions shared by bash and zsh | `git-aliases.sh` is the oh-my-zsh git set (gst, gcmsg, gco...). Also sourced on the Linux machine. |
| `bash/`, `zsh/` | Shell entry points | zsh is the macOS default and gets the same history search and completion feel. |
| `foot/` | Terminal config for Wayland Linux | Same padding and CSI-u bindings as the others. |
| `hypr/` | Caps Lock as tmux prefix on Omarchy/Hyprland | Terminal windows only. Loaded by one `require` in `hyprland.lua`. |
| `keyd/` | Caps Lock as tmux prefix on other Linux | System-wide. |
| `karabiner/` | Caps Lock as tmux prefix on macOS | Ghostty and Alacritty only. |
| `Brewfile` | Everything the above needs, on macOS | Linux uses pacman/apt inside `install.sh`. |

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
