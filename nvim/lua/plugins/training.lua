local disabled_fts = {
  "qf",
  "netrw",
  "lazy",
  "mason",
  "dashboard",
  "snacks_dashboard",
  "snacks_explorer",
  "TelescopePrompt",
  "noice",
  "dropbar_menu",
  "snacks_input",
  "snacks_picker_input",
  "dap-repl",
  "dapui_watches",
  "dapui_scopes",
}
return {
  {
    "tris203/precognition.nvim",
    event = "BufReadPost",
    opts = {
      startVisible = false,
      showBlankVirtLine = false,
      disabled_fts = disabled_fts,
    },
  },
  {
    "m4xshen/hardtime.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      enabled = false,
      disabled_keys = {
        ["<Up>"] = false,
        ["<Down>"] = false,
      },
      disabled_filetypes = disabled_fts,
    },
    keys = {
      {
        "<leader>uH",
        function()
          local hardtime = require("hardtime")
          local precognition = require("precognition")
          if hardtime.is_plugin_enabled then
            hardtime.disable()
            precognition.hide()
            vim.notify("Learning mode disabled")
          else
            hardtime.enable()
            precognition.show()
            vim.notify("Learning mode enabled")
          end
        end,
        desc = "Toggle learning mode",
      },
    },
  },
}
