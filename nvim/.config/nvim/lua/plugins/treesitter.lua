return {
  {
    "nvim-treesitter/nvim-treesitter",
    tag = "v0.9.2",

    opts = {
      ignore_installed = { "printf", "ptf" },
      ensure_installed = {
        "javascript",
        "typescript",
        "css",
        "gitignore",
        "http",
        "json",
        "scss",
        "sql",
        "vim",
        "lua",
        "astro",
        "markdown",
        "rust",
        "yaml",
        "toml",
      },
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },
      highlight = { enable = true },
      auto_install = true,
      ignore_install = { "printf" },
    },
  },
}
