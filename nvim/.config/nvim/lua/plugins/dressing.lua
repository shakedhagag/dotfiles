return {
  {
    "stevearc/dressing.nvim",
    config = function()
      require("dressing").setup()
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "markdown", "Avante" },
    },
    ft = { "markdown", "Avante" },
  },
}
