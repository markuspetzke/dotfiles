local disabled_fts = {
  "qf",
  "netrw",
  "lazy",
  "mason",
  "dashboard",
  "snacks_explorer",
  "TelescopePrompt",
}
return {
  {
    "tris203/precognition.nvim",
    event = "BufReadPost",
    opts = {
      disabled_fts = disabled_fts,
    },
  },
  {
    "m4xshen/hardtime.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      disabled_keys = {
        ["<Up>"] = false,
        ["<Down>"] = false,
      },
      disabled_filetypes = disabled_fts,
    },
  },
}
