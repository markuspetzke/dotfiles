return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6", -- Recommended
    lazy = false, -- This plugin is already lazy
  },
  {
    {
      "julianolf/nvim-dap-lldb",
      dependencies = { "mfussenegger/nvim-dap" },
      opts = { codelldb_path = "/path/to/codelldb" },
    },
  },
}
