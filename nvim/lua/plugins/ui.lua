return {

  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          section_separators = { left = "", right = "" },
        },
      })
    end,
  },
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "p", "<Plug>(YankyPutAfter)", desc = "Put After" },
      { "P", "<Plug>(YankyPutBefore)", desc = "Put Before" },
      { "<leader>p", "<cmd>YankyRingHistory<cr>", desc = "Yank History" },
    },
  },
  {
    "kylechui/nvim-surround",
    version = "^4.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
  },
}
