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
    config = function(_, opts)
      require("hardtime").setup(opts)

      -- Als Snacks-Toggle, damit which-key den Zustand anzeigt wie bei den anderen <leader>u-Schaltern.
      -- vim.g.learning_mode liest lualine fuer die Anzeige in der Statusleiste.
      Snacks.toggle
        .new({
          id = "learning_mode",
          name = "Learning Mode",
          get = function()
            return vim.g.learning_mode == true
          end,
          set = function(state)
            local hardtime = require("hardtime")
            local precognition = require("precognition")
            vim.g.learning_mode = state
            -- snacks.scroll animiert <C-d>/<C-u> in vielen Einzelschritten; precognition
            -- rechnet bei jedem CursorMoved neu -> Scrollen wird zaeh. Daher im
            -- Learning Mode die Scroll-Animation aus.
            if state then
              hardtime.enable()
              precognition.show()
              Snacks.scroll.disable()
            else
              hardtime.disable()
              precognition.hide()
              Snacks.scroll.enable()
            end
          end,
        })
        :map("<leader>uH")
    end,
    keys = {
      { "<leader>uR", "<cmd>Hardtime report<cr>", desc = "Hardtime report" },
    },
  },
}
