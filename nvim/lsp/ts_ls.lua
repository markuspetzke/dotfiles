local inlay = {
  includeInlayParameterNameHints = "all",
  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = true,
  includeInlayVariableTypeHintsWhenTypeMatchesName = false,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}

return {
  -- tsserver keeps throwing "Debug Failure" on semantic tokens (TS bug);
  -- treesitter highlights anyway, so turn them off here only.
  on_init = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,
  filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  settings = {
    typescript = { inlayHints = inlay },
    javascript = { inlayHints = inlay },
  },
}
