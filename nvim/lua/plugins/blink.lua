
-- plugins/blink.lua
return {
  {
    "saghen/blink.cmp",
    version = "*",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
				preset = "enter",
			},

      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },

      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },


      completion = {
        accept = {
          auto_brackets = { enabled = true },
        },
      },
    },
  },
}

