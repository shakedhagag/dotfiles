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
  { import = "astrocommunity.scrolling.mini-animate" },
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
  },
  { import = "astrocommunity.completion.copilot-lua" },
  { import = "astrocommunity.completion.copilot-cmp" },
  { import = "astrocommunity.pack.typescript" },
}
