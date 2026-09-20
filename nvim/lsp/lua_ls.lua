return {
  settings = {
    Lua = {
      completion = { callSnippet = "Replace" },
      hint = { enable = true, setType = true, arrayIndex = "Disable" },
      diagnostics = { globals = { "vim", "Snacks" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}
