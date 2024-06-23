local wezterm = require("wezterm")

local function with_ui(config)
	config.color_scheme = "Solarized (dark) (terminal.sexy)"
	colors, metadata =
		wezterm.color.load_scheme("Users/shaked.hagag@openweb.com/.config/wezterm/colors/solarized-osaka.toml")
	config.colors = colors
	config.hide_tab_bar_if_only_one_tab = true
	config.window_decorations = "RESIZE"
	config.window_padding = {
		left = 8,
		right = 8,
		top = 8,
		bottom = 8,
	}
	config.bidi_enabled = true
	config.line_height = 1.2
	config.font = wezterm.font({
		family = "FiraCode Nerd Font Mono",
	})
	-- config.native_macos_fullscreen_mode = true
	config.window_background_opacity = 0.8
	config.macos_window_background_blur = 50

	config.font_size = 16.0
end

return with_ui
