return {
  -- Schemas lazy holen, damit lsp/jsonls.lua nicht beim Start schemastore laedt.
  before_init = function(_, config)
    config.settings.json.schemas = require("schemastore").json.schemas()
  end,
  settings = {
    json = { schemas = {}, validate = { enable = true } },
  },
}
