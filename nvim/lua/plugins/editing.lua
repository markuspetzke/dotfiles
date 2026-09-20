return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
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
    end,
  },
}
