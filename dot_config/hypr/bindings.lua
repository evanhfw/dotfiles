-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + G", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })

-- SUPER + SPACE runs omacast (bind in hypr/omacast.lua); the Omarchy root
-- menu lives on ALT + SPACE instead.
hl.unbind("SUPER + SPACE")
o.bind("ALT + SPACE", "Omarchy menu", { menu = "root" })

-- Vim-style focus navigation: SUPER + hjkl mirrors SUPER + arrows.
o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.rebind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))
o.rebind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.rebind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))

-- Previous SUPER + J/K/L actions, moved out of the navigation keys.
o.bind("SUPER + ALT + J", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + SHIFT + K", "Keybindings", "omarchy-menu-keybindings")
o.bind("SUPER + SHIFT + L", "Cycle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

-- Touchpad on/off: one key toggles it. Omarchy persists the disabled state
-- across reloads and shows an OSD on each change.
o.rebind("SUPER + T", "Toggle touchpad", "omarchy-toggle-touchpad")

-- Floating/tiling moved off SUPER + T to make room for the touchpad toggle.
o.rebind("SUPER + ALT + T", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))

