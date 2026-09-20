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
  filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  settings = {
    typescript = { inlayHints = inlay },
    javascript = { inlayHints = inlay },
  },
}
