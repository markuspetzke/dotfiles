return {
  { "neovim/nvim-lspconfig" },
  {
    "mason-org/mason.nvim",
    opts = {
      PATH = "append",
      ensure_installed = { "codelldb", "stylua", "prettierd", "prettier", "shfmt" },
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
    -- mason.nvim itself has no ensure_installed; install formatters/debuggers here.
    config = function(_, opts)
      require("mason").setup(opts)
      local registry = require("mason-registry")
      registry.refresh(function()
        for _, name in ipairs(opts.ensure_installed or {}) do
          local ok, pkg = pcall(registry.get_package, name)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end)
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig", "saghen/blink.cmp", "b0o/schemastore.nvim" },
    config = function()
      local ok, blink = pcall(require, "blink.cmp")
      local capabilities = ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

      -- Per-server settings live in lsp/<name>.lua and get merged onto this.
      vim.lsp.config("*", { capabilities = capabilities })

      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "astro", "eslint", "tailwindcss", "jsonls", "yamlls" },
        -- stylua/stylua3p_ls do have lspconfig entries, but they are pure
        -- formatters -- those run through conform, not as a second LSP client.
        automatic_enable = { exclude = { "stylua", "stylua3p_ls" } },
      })
    end,
  },
}
