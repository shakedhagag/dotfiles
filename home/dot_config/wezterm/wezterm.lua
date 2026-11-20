-- WezTerm: the Windows stand-in for Ghostty (~/.config/ghostty/config).
-- Same Solarized Osaka Vivid palette, font fallback, split/tab keys and vim
-- scroll mode, translated to WezTerm. Default shell is zsh in WSL (your real
-- ~/.zshrc); Ctrl+Shift+Alt+T opens a native PowerShell tab instead.
local wezterm = require('wezterm')
local act = wezterm.action
local config = wezterm.config_builder()

-- ── Shells ───────────────────────────────────────────────────────────────────
config.default_domain = 'WSL:Ubuntu'
local pwsh = { 'pwsh.exe', '-NoLogo' }
config.launch_menu = {
  { label = 'zsh (WSL)', domain = { DomainName = 'WSL:Ubuntu' } },
  { label = 'PowerShell', args = pwsh, domain = { DomainName = 'local' } },
}

-- ── Font (Ghostty: Ioskeley Mono, Nerd Font fallback) ────────────────────────
-- scoop installs Nerd Fonts per-user; WezTerm doesn't always enumerate those.
if wezterm.target_triple:find('windows') then
  config.font_dirs = { os.getenv('LOCALAPPDATA') .. '\\Microsoft\\Windows\\Fonts' }
end
-- Ioskeley (Ghostty's first choice) isn't installed on Windows; Geist Mono
-- Nerd Font is the one in packages.yaml and the VS Code editor font.
config.font = wezterm.font_with_fallback({ 'GeistMono Nerd Font' })
config.warn_about_missing_glyphs = false
config.font_size = 11 -- Ghostty's 14 on macOS points ~ 11 on Windows at 100% scale
config.line_height = 1.17 -- adjust-cell-height = 17%

-- ── Theme: Solarized Osaka Vivid (same values as ghostty/themes/) ────────────
config.colors = {
  foreground = '#b6c5c6',
  background = '#001d24',
  cursor_bg = '#b6c5c6',
  cursor_fg = '#001d24',
  cursor_border = '#b6c5c6',
  selection_bg = '#1a6397',
  selection_fg = '#b6c5c6',
  ansi = { '#001d24', '#ff6c6a', '#a2bb00', '#dba500', '#5aaefa', '#fe67a8', '#34c5b9', '#fff8e7' },
  brights = { '#063540', '#ff8c8a', '#c4ff5d', '#ffd28c', '#87c4ff', '#ff8bbc', '#2dfbea', '#ffffff' },
  tab_bar = {
    background = '#001d24',
    active_tab = { bg_color = '#063540', fg_color = '#b6c5c6' },
    inactive_tab = { bg_color = '#001d24', fg_color = '#586e75' },
    inactive_tab_hover = { bg_color = '#063540', fg_color = '#b6c5c6' },
    new_tab = { bg_color = '#001d24', fg_color = '#586e75' },
    new_tab_hover = { bg_color = '#063540', fg_color = '#b6c5c6' },
  },
}

-- ── Window ───────────────────────────────────────────────────────────────────
config.window_decorations = 'RESIZE'
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.window_padding = { left = 6, right = 6, top = 6, bottom = 6 }
config.inactive_pane_hsb = { brightness = 0.8 } -- unfocused-split-opacity = 0.8
config.pane_focus_follows_mouse = true
config.audible_bell = 'Disabled'
config.window_close_confirmation = 'NeverPrompt'

wezterm.on('gui-startup', function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize() -- maximize = true
end)

-- Open clicked web links in Chrome, whatever Windows' default browser is
-- (e.g. a stale Arc registration fails with "file not found"). Other links
-- (mailto:, file:) still go to Windows' default handler.
local chrome = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
wezterm.on('open-uri', function(_, _, uri)
  local url = uri
  -- A bare `localhost:3000/` or `host:port/...` (no scheme) -> http://
  if not url:match('^%a[%w+.-]*://') and (url:match('^localhost') or url:match('^[%w.-]+:%d+')) then
    url = 'http://' .. url
  end
  if url:match('^https?://') then
    local f = io.open(chrome, 'r')
    if f then
      f:close()
      wezterm.background_child_process({ chrome, url })
      return false -- handled; skip the default opener
    end
  end
end)

-- ── Keys (Ghostty keybinds; `super` chords moved off the Windows key) ────────
config.keys = {
  -- General
  { key = 'z', mods = 'CTRL', action = act.CloseCurrentPane({ confirm = false }) },
  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab('CurrentPaneDomain') },
  { key = 'o', mods = 'CTRL|SHIFT', action = act.ShowTabNavigator },
  -- Ghostty's quick-terminal chord: here, a native PowerShell tab
  { key = 't', mods = 'CTRL|SHIFT|ALT', action = act.SpawnCommandInNewTab({ args = pwsh, domain = { DomainName = 'local' } }) },
  { key = 'l', mods = 'CTRL|SHIFT|ALT', action = act.ShowLauncherArgs({ flags = 'LAUNCH_MENU_ITEMS' }) },

  -- Splits
  { key = 'v', mods = 'CTRL|SHIFT', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = 'd', mods = 'CTRL|SHIFT', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  { key = 'm', mods = 'CTRL|SHIFT', action = act.TogglePaneZoomState },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize({ 'Right', 5 }) },
  { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize({ 'Left', 5 }) },
  -- Ghostty: super+h/l. Win+L locks Windows, so use herdr's ctrl+alt+hjkl.
  { key = 'h', mods = 'CTRL|ALT', action = act.ActivatePaneDirection('Left') },
  { key = 'j', mods = 'CTRL|ALT', action = act.ActivatePaneDirection('Down') },
  { key = 'k', mods = 'CTRL|ALT', action = act.ActivatePaneDirection('Up') },
  { key = 'l', mods = 'CTRL|ALT', action = act.ActivatePaneDirection('Right') },

  -- Paste on Ctrl+V like the rest of Windows (Ghostty's Cmd+V). Ctrl+Shift+V
  -- stays a split, as in Ghostty. In nvim, use Ctrl+Q for visual-block mode
  -- (Vim's built-in alias for Ctrl+V). Ctrl+Alt+V and Shift+Insert also paste;
  -- copy is Ctrl+Shift+C or just select text.
  { key = 'v', mods = 'CTRL', action = act.PasteFrom('Clipboard') },
  { key = 'v', mods = 'CTRL|ALT', action = act.PasteFrom('Clipboard') },
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') },

  -- Ghostty `alt+v` vim key table -> WezTerm copy mode (vim keys built in:
  -- j/k, ctrl+d/u, gg/G, / search, v/y copy, q/Esc exit)
  { key = 'v', mods = 'ALT', action = act.ActivateCopyMode },
  { key = ':', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },
}
-- Hyper (super+ctrl+alt+shift) chords are not ported: Windows reserves that
-- combination for the Office key and swallows it before WezTerm sees it.

return config
