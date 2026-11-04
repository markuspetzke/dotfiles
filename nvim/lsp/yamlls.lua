return {
  before_init = function(_, config)
    config.settings.yaml.schemas = require("schemastore").yaml.schemas()
  end,
  settings = {
    yaml = {
      -- schemastore takes over; turn off the built-in store, otherwise everything shows up twice.
      schemaStore = { enable = false, url = "" },
      schemas = {},
      keyOrdering = false,
    },
  },
}
