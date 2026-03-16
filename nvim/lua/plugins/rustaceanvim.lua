return {
  "mrcjkb/rustaceanvim",
  version = "^6",
  ft = { "rust" },
  opts = {
    server = {
      on_attach = function(client, bufnr)
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end,
      default_settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
            buildScripts = {
              enable = true,
            },
          },
          check = {
            command = "clippy",
          },
          procMacro = {
            enable = true,
            ignored = {
              ["async-trait"] = { "async_trait" },
              ["napi-derive"] = { "napi" },
              ["async-recursion"] = { "async_recursion" },
            },
          },
          -- Inlay Hints Konfiguration
          inlayHints = {
            bindingModeHints = {
              enable = false,
            },
            chainingHints = {
              enable = true,
            },
            closingBraceHints = {
              enable = true,
              minLines = 25,
            },
            closureReturnTypeHints = {
              enable = "never",
            },
            lifetimeElisionHints = {
              enable = "never",
              useParameterNames = false,
            },
            maxLength = 25,
            parameterHints = {
              enable = true,
            },
            reborrowHints = {
              enable = "never",
            },
            renderColons = true,
            typeHints = {
              enable = true,
              hideClosureInitialization = false,
              hideNamedConstructor = false,
            },
          },
        },
      },
    },
  },
  config = function(_, opts)
    vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
  end,
}
