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
  { import = "astrocommunity.completion.copilot-lua" },
  { import = "astrocommunity.completion.copilot-cmp" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.mdx" },
  { import = "astrocommunity.color.headlines-nvim" },
}
