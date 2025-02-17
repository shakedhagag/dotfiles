-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  -- import/override with your plugins folder
  { import = "astrocommunity.pack.tailwindcss" },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.utility.hover-nvim" },
  { import = "astrocommunity.motion.mini-ai" },
  { import = "astrocommunity.motion.mini-surround" },
  {
    import = "astrocommunity.note-taking.obsidian-nvim",
    lazy = false,
    opts = {
      workspaces = {
        {
          name = "second-brain",
          path = "~/Obsidian/second-brain",
        },
      },
    },
  },
  {
    import = "astrocommunity.completion.avante-nvim",
    opts = {
      provider = "claude",
      auto_suggestions_provider = "copilot",
      mappings = {
        ask = "<leader>aa",
      },
    },
  },
  {
    import = "astrocommunity.completion.blink-cmp",
    opts = {
      keymap = { preset = "enter", accept = "<Tab>", accept_word = false, accept_line = false },
      sources = {
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-cmp-copilot",
            score_offset = 100,
            async = true,
            transform_items = function(_, items)
              local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
              local kind_idx = #CompletionItemKind + 1
              CompletionItemKind[kind_idx] = "Copilot"
              for _, item in ipairs(items) do
                item.kind = kind_idx
              end
              return items
            end,
          },
        },
        completion = {
          enabled_providers = { "copilot", "lsp", "path", "buffer" },
        },
      },
      appearance = {
        -- Blink does not expose its default kind icons so you must copy them all (or set your custom ones) and add Copilot
        kind_icons = {
          Copilot = "",
          Text = "󰉿",
          Method = "󰊕",
          Function = "󰊕",
          Constructor = "󰒓",

          Field = "󰜢",
          Variable = "󰆦",
          Property = "󰖷",

          Class = "󱡠",
          Interface = "󱡠",
          Struct = "󱡠",
          Module = "󰅩",

          Unit = "󰪚",
          Value = "󰦨",
          Enum = "󰦨",
          EnumMember = "󰦨",

          Keyword = "󰻾",
          Constant = "󰏿",

          Snippet = "󱄽",
          Color = "󰏘",
          File = "󰈔",
          Reference = "󰬲",
          Folder = "󰉋",
          Event = "󱐋",
          Operator = "󰪚",
          TypeParameter = "󰬛",
        },
      },
    },
    dependencies = {
      {
        "giuxtaposition/blink-cmp-copilot",
        "rafamadriz/friendly-snippets",
      },
    },
  },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.mdx" },
  { import = "astrocommunity.color.headlines-nvim" },
  { import = "astrocommunity.recipes.vscode" },
  { import = "astrocommunity.file-explorer.mini-files" },
}
