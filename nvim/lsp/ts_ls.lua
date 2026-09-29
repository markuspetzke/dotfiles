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
  -- tsserver wirft bei Semantic Tokens staendig "Debug Failure" (TS-Bug);
  -- Treesitter hebt ohnehin hervor, also nur hier abschalten.
  on_init = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,
  filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  settings = {
    typescript = { inlayHints = inlay },
    javascript = { inlayHints = inlay },
  },
}
