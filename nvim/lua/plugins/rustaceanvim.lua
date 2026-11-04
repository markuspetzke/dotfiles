return {
  "mrcjkb/rustaceanvim",
  version = "^9",
  ft = { "rust" },
  opts = {
    -- Debugging through codelldb from Mason (:MasonInstall codelldb).
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
      -- rust-analyzer reports extra tips (e.g. "prefix it with an underscore") twice:
      -- as relatedInformation of the warning AND as a separate hint diagnostic that points
      -- back to the warning with "original diagnostic". Drop the hint copies
      -- so every error shows up only once (with a ↳ tip).
      handlers = {
        ["textDocument/publishDiagnostics"] = function(err, result, ctx)
          if result and result.diagnostics then
            result.diagnostics = vim.tbl_filter(function(d)
              local rel = d.relatedInformation
              return not (
                d.severity == vim.lsp.protocol.DiagnosticSeverity.Hint
                and rel
                and rel[1]
                and rel[1].message == "original diagnostic"
              )
            end, result.diagnostics)
          end
          return vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
        end,
      },
      on_attach = function(_, bufnr)
        -- The global LspAttach already turns inlay hints on. Only the
        -- Rust-specific variants that override the LSP defaults live here.
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
          -- Inlay hints configuration
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
