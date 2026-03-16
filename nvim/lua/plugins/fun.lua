return {
  {
    "tamton-aquib/zone.nvim",
    enabled = false,
    event = "VeryLazy", -- lädt das Plugin verzögert
    opts = {
      style = "vanish", -- Animation: "dvd", "epilepsy", "vanish", "matrix", "treadmill", "shuffle"
      after = 30, -- Sekunden bis der Screensaver startet (bei Inaktivität)
      exclude_filetypes = { -- In diesen Dateitypen wird der Screensaver nicht aktiviert
        "TelescopePrompt",
        "NvimTree",
        "neo-tree",
        "dashboard",
        "lazy",
      },
    },
  },

  {
    "folke/drop.nvim",
    event = "VimEnter",
    opts = {
      theme = "leaves",
    },
  },
}
