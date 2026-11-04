return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
      -- Lua workspaces with their own .luarc.json are not Neovim Lua (hypr/: Hyprland API stubs).
      enabled = function(root_dir)
        return not vim.uv.fs_stat(vim.fs.joinpath(root_dir, ".luarc.json"))
      end,
    },
  },
}
