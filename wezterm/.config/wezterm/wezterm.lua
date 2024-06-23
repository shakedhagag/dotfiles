local wezterm = require("wezterm")
local with_keybindings = require("keybindings")
local with_ui = require("ui")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

with_ui(config)
with_keybindings(config)

-- and finally, return the configuration to wezterm
return config
