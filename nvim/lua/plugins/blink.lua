return {
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "enter" },
      appearance = { nerd_font_variant = "mono" },
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
        accept = { auto_brackets = { enabled = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
        ghost_text = { enabled = true },
        menu = {
          border = "rounded",
          draw = {
            treesitter = { "lsp" },
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" } },
          },
        },
        list = { selection = { preselect = true, auto_insert = false } },
      },
      signature = { enabled = true, window = { border = "rounded" } },
    },
  },
}
