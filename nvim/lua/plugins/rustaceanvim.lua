return {
  "mrcjkb/rustaceanvim",
  version = "^6",
  ft = { "rust" },
  opts = {
    -- Debugging ueber codelldb aus Mason (:MasonInstall codelldb).
    dap = {
      adapter = function()
        local ext = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"
        return require("rustaceanvim.config").get_codelldb_adapter(
          ext .. "adapter/codelldb",
          ext .. "lldb/lib/liblldb.so"
        )
      end,
    },
    server = {
      on_attach = function(_, bufnr)
        -- Inlay Hints schaltet bereits das globale LspAttach ein. Hier nur die
        -- Rust-spezifischen Varianten, die die LSP-Defaults ueberschreiben.
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end
        map({ "n", "v" }, "<leader>ca", function()
          vim.cmd.RustLsp("codeAction")
        end, "Code action (Rust, grouped)")
        map("n", "K", function()
          vim.cmd.RustLsp({ "hover", "actions" })
        end, "Hover actions")
        map("n", "<leader>cR", function()
          vim.cmd.RustLsp("runnables")
        end, "Runnables")
        map("n", "<leader>dd", function()
          vim.cmd.RustLsp("debuggables")
        end, "Debuggables (Rust)")
        map("n", "<leader>cx", function()
          vim.cmd.RustLsp("explainError")
        end, "Explain error")
        map("n", "<leader>cE", function()
          vim.cmd.RustLsp("expandMacro")
        end, "Expand macro")
        map("n", "<leader>cp", function()
          vim.cmd.RustLsp("parentModule")
        end, "Parent module")
        map("n", "<leader>cJ", function()
          vim.cmd.RustLsp("joinLines")
        end, "Join lines (Rust)")
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
