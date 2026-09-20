return {
  { "neovim/nvim-lspconfig" },
  {
    "mason-org/mason.nvim",
    opts = {
      PATH = "append",
      ensure_installed = { "codelldb", "stylua", "prettier", "shfmt" },
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    -- mason.nvim selbst kennt kein ensure_installed; Formatter/Debugger hier nachinstallieren.
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

      -- Per-Server-Settings liegen in lsp/<name>.lua und werden hierauf gemerged.
      vim.lsp.config("*", { capabilities = capabilities })

      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "astro", "eslint", "tailwindcss", "jsonls", "yamlls" },
        -- stylua/stylua3p_ls haben zwar lspconfig-Eintraege, sind aber reine
        -- Formatter -- die laufen ueber conform, nicht als zweiter LSP-Client.
        automatic_enable = { exclude = { "stylua", "stylua3p_ls" } },
      })
    end,
  },
}
