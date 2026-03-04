-- plugins/lspconfig.lua
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      -- "folke/neodev.nvim",
    },
    opts = {
      autoformat = false,
    },
    config = function()
      -- Neovim Lua API verstehen lassen
      -- require("neodev").setup()

      local lspconfig = require("lspconfig")

      -- Einheitliches on_attach (Keymaps, etc.)
      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
        end

        map("n", "gd", vim.lsp.buf.definition)
        map("n", "gr", vim.lsp.buf.references)
        map("n", "K", vim.lsp.buf.hover)
        map("n", "<leader>rn", vim.lsp.buf.rename)
        map("n", "<leader>ca", vim.lsp.buf.code_action)
      end

      -- Mason regelt Installation
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
        },
      })

      -- Default-Setup für alle Server
      -- require("mason-lspconfig").setup_handlers({
      --   function(server_name)
      --     lspconfig[server_name].setup({
      --       on_attach = on_attach,
      --     })
      --   end,
      -- })
    end,
  },
}
