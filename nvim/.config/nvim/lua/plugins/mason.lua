-- Customize Mason plugins

---@type LazySpec
return {
  -- use mason-lspconfig to configure LSP installations
  {
    "williamboman/mason-lspconfig.nvim",
    -- overrides `require("mason-lspconfig").setup(...)`
    opts = {
      commands = {
        OrganizeImports = {
          function()
            local params = {
              command = "_typescript.organizeImports",
              arguments = { vim.api.nvim_buf_get_name(0) },
              title = "",
            }
            vim.lsp.buf.execute_command(params)
          end,
          desc = "Organize Imports",
        },
        setup = function()
          vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = { "*.tsx", "*.ts" },
            callback = function() vim.cmd "OrganizeImports" end,
          })
        end,
      },
      ensure_installed = {
        "lua_ls",
        "ts_ls",
        "tailwindcss",
        -- add more arguments for adding more language servers
      },
    },
  },
  -- use mason-null-ls to configure Formatters/Linter installation for null-ls sources
  {
    "jay-babu/mason-null-ls.nvim",
    -- overrides `require("mason-null-ls").setup(...)`
    opts = {
      ensure_installed = {
        "stylua",
        -- add more arguments for adding more null-ls sources
      },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    -- overrides `require("mason-nvim-dap").setup(...)`
    opts = {
      ensure_installed = {
        "python",
        -- add more arguments for adding more debuggers
      },
    },
  },
}
