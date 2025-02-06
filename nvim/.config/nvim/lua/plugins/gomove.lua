return {
  {
    "fedepujol/move.nvim",
    opts = {
      --- Config
    },
    keys = {
      { "<A-j>", ":MoveLine(1)<CR>", mode = "n", desc = "Move line down" },
      { "<A-k>", ":MoveLine(-1)<CR>", mode = "n", desc = "Move line up" },
      { "<leader>wf", ":MoveWord(1)<CR>", mode = "n", desc = "Move word forward" },
      { "<leader>wb", ":MoveWord(-1)<CR>", mode = "n", desc = "Move word backward" },

      { "<A-j>", ":MoveBlock(1)<CR>", mode = "v", desc = "Move block down" },
      { "<A-k>", ":MoveBlock(-1)<CR>", mode = "v", desc = "Move block up" },
      { "<A-h>", ":MoveHBlock(-1)<CR>", mode = "v", desc = "Move block left" },
      { "<A-l>", ":MoveHBlock(1)<CR>", mode = "v", desc = "Move block right" },
    },
  },
  -- {
  --   "willothy/moveline.nvim",
  --   build = "make",
  --   config = function()
  --     local moveline = require "moveline"
  --     vim.keymap.set("n", "<C-k>", moveline.up)
  --     vim.keymap.set("n", "<M-j>", moveline.down)
  --     vim.keymap.set("v", "<M-k>", moveline.block_up)
  --     vim.keymap.set("v", "<M-j>", moveline.block_down)
  --   end,
  -- },
}
