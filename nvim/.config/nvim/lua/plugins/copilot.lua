return {
  -- This is the copilot-cmp plugin
  {
    "zbirenbaum/copilot-cmp",
    enabled = true,
    event = { "BufEnter" },
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  {
    "github/copilot.vim",
  },
}
