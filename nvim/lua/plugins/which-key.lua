return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 300,
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
    win = {
      border = "rounded",
      padding = { 1, 2 },
    },
    -- Nur Gruppen; die einzelnen Keys beschreiben sich ueber ihre `desc` selbst.
    spec = {
      { "<leader>f", group = "Find" },
      { "<leader>c", group = "Code" },
      { "<leader>g", group = "Git" },
      { "<leader>gt", group = "Toggle" },
      { "<leader>s", group = "Search" },
      { "<leader>w", group = "Window", proxy = "<c-w>" },
      { "<leader>q", group = "Quit/Session" },
      { "<leader>o", group = "Tasks" },
      { "<leader>x", group = "Diagnostics/Quickfix" },
      { "<leader>b", group = "Buffer" },
      { "<leader>d", group = "Debug" },
      { "<leader>u", group = "UI/Toggle" },
      { "<leader>n", group = "Notifications/Messages" },
      { "[", group = "prev" },
      { "]", group = "next" },
      { "g", group = "goto" },
      { "z", group = "fold" },
    },
  },
}
