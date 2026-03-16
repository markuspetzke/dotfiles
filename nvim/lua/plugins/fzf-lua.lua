return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    files = {
      cmd = "fd --type f --hidden --exclude .git --exclude node_modules --exclude .cargo --exclude target",
    },
  },

  keys = {
    {
      "<leader>ff",
      function()
        require("fzf-lua").files()
      end,
      desc = "Find Files (Project)",
    },
    {
      "<leader>fc",
      function()
        require("fzf-lua").files({
          cwd = vim.fn.stdpath("config"),
          prompt = "Config Files❯ ",
        })
      end,
      desc = "Find Config Files",
    },
    {
      "<leader>fr",
      function()
        require("fzf-lua").oldfiles()
      end,
      desc = "Recent Files",
    },
    {
      "<leader>fg",
      function()
        require("fzf-lua").live_grep()
      end,
      desc = "Live Grep",
    },
    {
      "<leader>fb",
      function()
        require("fzf-lua").buffers()
      end,
      desc = "Buffers",
    },
    {
      "<leader>fh",
      function()
        require("fzf-lua").help_tags()
      end,
      desc = "Help Tags",
    },
  },
}
