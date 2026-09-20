return {
  before_init = function(_, config)
    config.settings.yaml.schemas = require("schemastore").yaml.schemas()
  end,
  settings = {
    yaml = {
      -- schemastore uebernimmt; den eingebauten Store abschalten, sonst doppelt.
      schemaStore = { enable = false, url = "" },
      schemas = {},
      keyOrdering = false,
    },
  },
}
