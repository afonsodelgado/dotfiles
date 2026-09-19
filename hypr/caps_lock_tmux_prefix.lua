-- Caps Lock as the tmux prefix, for Omarchy / Hyprland.
-- Loaded from ~/.config/hypr/hyprland.lua via require("hypr.caps_lock_tmux_prefix").
--
-- Caps Lock is a lock modifier, so it is first disabled at the keyboard level
-- (caps:none). Its keycode (66) is then bound: in a terminal window a tap
-- injects Ctrl+Space, which is the tmux prefix. Anywhere else it does nothing.
-- Holding Shift still gives capitals; the caps toggle itself is gone.

hl.config({ input = { kb_options = "caps:none" } })

-- Same approach Omarchy uses for universal copy/paste
-- (see /usr/share/omarchy/default/hypr/bindings/clipboard.lua).
local function send_shortcut_once(mods, key)
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
    end, { timeout = 50, type = "oneshot" })
  end
end

local function active_window_is_terminal()
  local window = hl.get_active_window()
  if not window then
    return false
  end
  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end
  return false
end

o.bind("code:66", "tmux prefix (Caps Lock)", function()
  if active_window_is_terminal() then
    send_shortcut_once("CTRL", "space")()
  end
end)
