local wezterm = require("wezterm")

local act = wezterm.action
local escape_key = act.SendKey({ key = "Escape" })

local function key(k)
	return act.SendKey({ key = k })
end

local function with_keybindings(config)
	config.keys = {
		-- Ctrl-f = ToggleFullScreen
		{
			key = "f",
			mods = "CTRL",
			action = wezterm.action.ToggleFullScreen,
		},
	}
end

return with_keybindings
