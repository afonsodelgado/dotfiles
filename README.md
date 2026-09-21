# dotfiles

The parts of my [Omarchy](https://omarchy.org) setup that work anywhere: terminal, tmux, Neovim
(LazyVim), starship prompt, and shell aliases. Plus the personal layer on top of Omarchy itself, so
a fresh Omarchy machine ends up identical.

`install.sh` detects the platform (macOS, Omarchy, other Linux), symlinks configs into `~/.config`,
hooks the shell, installs packages where it can, and sets up Caps Lock as the tmux prefix. It is
safe to re-run. Anything it replaces is moved to `*.bak`. It ends with a check of tools, versions
and links; `install.sh --check` runs only that.

## Installing on macOS

```bash
xcode-select --install                     # git, make, clang (Neovim needs them for treesitter)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone https://github.com/afonsodelgado/dotfiles ~/.dotfiles
~/.dotfiles/install.sh
```

The installer finds Homebrew on its own, installs the Brewfile, links the configs, appends one
line to `~/.zshrc`, and ends with a check of what is installed and linked. Fix any `WARN` line it
prints. You can re-run just that check at any time:

```bash
~/.dotfiles/install.sh --check
```

Then:

1. Open Ghostty (or Alacritty). It runs zsh, the macOS login shell; that is expected, and
   `zsh/zshrc` gives it the same aliases, prompt and tools as bash on Linux. Start tmux with `t`.
2. Open Karabiner-Elements, go to Complex Modifications, Add rule, and enable
   "Caps Lock as tmux prefix". Grant it Input Monitoring when asked.
3. Run `nvim`. LazyVim installs its plugins on first launch; wait for it to finish and restart.

### If it does not look like the Linux machine

Run `~/.dotfiles/install.sh --check` first. Beyond what it reports:

- **tmux still has Ctrl+b as prefix, or nvim is plain.** The configs are not being read. The
  usual causes: an old `~/.tmux.conf` (tmux then ignores `~/.config/tmux/tmux.conf`), or the
  install stopped early before linking anything. Both are handled by re-running `install.sh`.
- **`nvim` or `tmux` is an old version, or not found.** Homebrew is not on PATH in that shell.
  An old `~/.zshrc` that starts with `PATH=...` wipes it. The dotfiles now re-add Homebrew
  themselves, but the cleanest fix is to delete that line and anything else you no longer want
  from `~/.zshrc`, keeping only the `source` line the installer added. oh-my-zsh is not needed:
  its git aliases are in `shell/git-aliases.sh`.
- **Ctrl+Space does nothing.** macOS grabs it for "Select the previous input source". Turn that
  off in System Settings > Keyboard > Keyboard Shortcuts > Input Sources.
- **Alt shortcuts type odd characters.** Option is not acting as Alt. Make sure the Ghostty
  config is the linked one (`macos-option-as-alt = true`); a `~/Library/Application
  Support/com.mitchellh.ghostty/config` file would take precedence over `~/.config/ghostty`.
- **Alt+Left/Right do not switch tmux windows.** Ghostty binds those to word movement on macOS
  by default. The linked config unbinds them; restart Ghostty after linking.
- **Yank in nvim does not reach the system clipboard.** On macOS Neovim uses pbcopy/pbpaste
  directly, also inside tmux. If `:checkhealth` shows no clipboard tool, something shadows them.
- **Shell keys feel like vi.** zsh switches to vi mode when `EDITOR` contains "vi". The zshrc
  forces emacs mode; if you see vi behaviour, the dotfiles line in `~/.zshrc` is not running.

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
