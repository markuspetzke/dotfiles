return {
  "ibhagwan/fzf-lua",
  lazy = false, -- Suchwerkzeuge sollten immer da sein
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    files = {
      find_opts = [[-type f \! -path '*/.git/*' \! -path '*/.node_modules/*' \! -path '*/.cargo/*' \! -path '*/target/*' \! -path '*/mason.nvim/*' \! -path '*/.npm/*' \! -path '*/.zoom/*' \! -path '*/.cache/*' \! -path '*/Games/*' \! -name "*.crate" \! -path "*/.local/*"  \! -name "*.dll" \! -name "*.jpg" \! -name "*.png" \! -name "*.dll"  \! -name "*.history" \! -name "*.tar.gz" \! -name "*.gif"  ]],
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
  },
}
