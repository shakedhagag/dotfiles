return {
  { "rose-pine/neovim", name = "rose-pine", opts = { transparent = true } },
  { "EdenEast/nightfox.nvim", name = "nightfox", opts = { transparent = true } },
  {
    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    opts = { transparent = true, colors = { theme = { all = { ui = { bg_gutter = "none" } } } } },
  },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,

    name = "solarized-osaka",
  },
  {
    "navarasu/onedark.nvim",
    name = "onedark",
    opts = {
      style = "darker",
      transparent = true,
      toggle_style_key = "<leader>ts",
    },
  },
}
