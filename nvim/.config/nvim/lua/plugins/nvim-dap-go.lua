return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "leoluz/nvim-dap-go",
  },
  config = function(plugin, opts)
    local dap = require "dap"
    require "astronvim.plugins.configs.nvim-dap-ui"(plugin, opts)
    require("dap-go").setup()
    dap.adapters.go = {
      type = "executable",
      command = "node",
      args = { os.getenv "HOME" .. "/go/vscode-go/extension/dist/debugAdapter.js" },
    }
    dap.configurations.go = {
      {
        type = "go",
        name = "Debug",
        request = "launch",
        showLog = false,
        program = "${file}",
        dlvToolPath = vim.fn.exepath "dlv", -- Adjust to where delve is installed
      },
    }
  end,
}
