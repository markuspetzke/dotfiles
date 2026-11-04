return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
    {
      "<leader>uf",
      function()
        vim.g.autoformat = not vim.g.autoformat
        vim.notify("Autoformat " .. (vim.g.autoformat and "enabled" or "disabled"))
      end,
      desc = "Toggle Autoformat",
    },
  },
  opts = function()
    -- prettierd keeps prettier running as a daemon (it still uses the version and
    -- plugins from the project); prettier only as a fallback if prettierd is missing.
    local prettier = { "prettierd", "prettier", stop_after_first = true }
    return {
      default_format_opts = { lsp_format = "fallback" },
      formatters_by_ft = {
        -- Lua
        lua = { "stylua" },
        -- JavaScript/TypeScript
        javascript = prettier,
        typescript = prettier,
        javascriptreact = prettier,
        typescriptreact = prettier,
        -- Web
        html = prettier,
        css = prettier,
        astro = prettier,
        scss = prettier,
        json = prettier,
        jsonc = prettier,
        yaml = prettier,
        markdown = prettier,
        -- Rust
        rust = { "rustfmt" },
        -- Shell
        sh = { "shfmt" },
        ["_"] = { "trim_whitespace" },
      },
      format_on_save = function(bufnr)
        return require("config.formatting").on_save(bufnr)
      end,
      format_after_save = function(bufnr)
        return require("config.formatting").after_save(bufnr)
      end,
      notify_on_error = true,
    }
  end,
  init = function()
    vim.g.autoformat = true
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
