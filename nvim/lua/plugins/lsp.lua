return {
  { "neovim/nvim-lspconfig" },
  -- JSON/YAML schemas; loaded on the first require in lsp/jsonls.lua and lsp/yamlls.lua.
  { "b0o/schemastore.nvim" },
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonLog" },
    opts = {
      PATH = "append",
      -- Formatters, linters and debuggers; language servers: mason-lspconfig below.
      ensure_installed = { "codelldb", "stylua", "prettierd", "prettier", "shfmt", "shellcheck" },
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
    -- mason.nvim itself has no ensure_installed. Missing tools are installed a few seconds
    -- after startup, so the registry check does not delay opening a file.
    config = function(_, opts)
      require("mason").setup(opts)
      vim.defer_fn(function()
        local registry = require("mason-registry")
        registry.refresh(function()
          for _, name in ipairs(opts.ensure_installed or {}) do
            local ok, pkg = pcall(registry.get_package, name)
            if ok and not pkg:is_installed() then
              pkg:install()
            end
          end
        end)
      end, 3000)
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    -- blink.cmp has to load before the first server starts: on load it adds its completion
    -- capabilities to vim.lsp.config("*") (plugin/blink-cmp.lua).
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig", "saghen/blink.cmp" },
    opts = {
      -- Per-server settings live in lsp/<name>.lua. bashls runs shellcheck (installed above);
      -- ruff only lints Python, there is no Python formatting on save.
      ensure_installed = { "lua_ls", "ts_ls", "astro", "eslint", "tailwindcss", "jsonls", "yamlls", "bashls", "ruff" },
      -- stylua/stylua3p_ls do have lspconfig entries, but they are pure formatters --
      -- those run through conform, not as a second LSP client.
      automatic_enable = { exclude = { "stylua", "stylua3p_ls" } },
    },
  },
}
