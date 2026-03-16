return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next Todo",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Prev Todo",
      },
      { "<leader>st", "<cmd>TodoFzfLua<cr>", desc = "Search Todos" },
    },
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup({
        options = {
          show_source = {
            enabled = true,
            if_many = false,
          },
          show_related = {
            enabled = true,
          },
        },
      })
      vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
    end,
  },
}
