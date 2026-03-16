return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    dependencies = { "windwp/nvim-ts-autotag" },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        autotag = { enable = true },
        ensure_installed = { "lua", "vim", "vimdoc", "python", "javascript", "html", "css", "rust", "typescript" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
