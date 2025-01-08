return {
  { "rose-pine/neovim", name = "rose-pine" },
  { "EdenEast/nightfox.nvim", name = "nightfox" },
  { "rebelot/kanagawa.nvim", name = "kanagawa" },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
      },
    },
    name = "solarized-osaka",
  },
}
