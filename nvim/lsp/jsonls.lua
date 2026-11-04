return {
  -- Fetch schemas lazily so lsp/jsonls.lua does not load schemastore at startup.
  before_init = function(_, config)
    config.settings.json.schemas = require("schemastore").json.schemas()
  end,
  settings = {
    json = { schemas = {}, validate = { enable = true } },
  },
}
