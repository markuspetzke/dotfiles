return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    triggers = {
      { "<auto>", mode = "nso" },
    },
    preset = "modern",
    delay = 300,
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
    win = {
      border = "rounded",
      padding = { 1, 2 },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    wk.add({
      -- [fzf-lua]
      { "<leader>f", group = "Find " },

      { "<leader>c", group = "LSP/Code" },
      { "<leader>cr", desc = "Rename" },
      { "<leader>ca", desc = "Code Action" },
      { "<leader>cd", desc = "Diagnostics" },

      -- [LazyGit]
      { "<leader>g", group = "Git" },
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },

      { "<leader>s", group = "Search" },
      { "<leader>ss", desc = "Search String" },
      { "<leader>sw", desc = "Search Word" },
      { "<leader>sr", desc = "Search & Replace" },

      { "<leader>w", group = "Window", proxy = "<c-w>" },
      { "<leader>q", group = "Quit/Session" },
      { "<leader>x", group = "Diagnostics/Quickfix" },

      -- [Buffer]
      { "<leader>b", group = "Buffer" },

      { "<leader>u", group = "UI/Toggle" },
      { "<leader>n", group = "Notifications" },
    })
  end,
}
