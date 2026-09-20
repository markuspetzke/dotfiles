return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    animate = { enabled = true },

    bigfile = {
      enabled = true,
      notify = true,
      size = 1.5 * 1024 * 1024, -- 1.5MB
    },

    dashboard = {
      enabled = true,
      width = 60,
      preset = {
        header = table.concat({
          "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
          "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
          "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
          "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
          "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
          "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
        }, "\n"),
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua require('fzf-lua').files()" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua require('fzf-lua').oldfiles()" },
          { icon = " ", key = "s", desc = "Restore Session", action = ":lua require('persistence').load()" },
          { icon = " ", key = "g", desc = "Find Word", action = ":lua require('fzf-lua').live_grep()" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "e", desc = "Explorer", action = ":lua Snacks.explorer()" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua require('fzf-lua').files({ cwd = vim.fn.stdpath('config'), prompt = 'Config Files❯ ' })",
          },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", cwd = true, indent = 2, padding = 1 },
        { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        { section = "startup" },
      },
    },

    explorer = {
      enabled = true,
      win = {
        position = "left",
        width = 30,
        border = "rounded",
      },
      filters = {
        hidden = false,
        custom = { "^%.git$", "^node_modules$", "^%.DS_Store$", "^dist$", "^target$" },
      },
      icons = {
        folder_closed = "",
        folder_open = "",
        file = "",
        symlink = "",
      },
      format = {
        filename = {
          width = 0, -- 0 = no limit
          hl = "Normal",
        },
        indent = {
          size = 2,
          hl = "Comment",
        },
      },
    },

    indent = { enabled = true },

    input = { enabled = true },

    -- Der Explorer laeuft auf dem Picker, deshalb bleibt der an; nur die
    -- vim.ui.select-Uebernahme ist hier nicht erwuenscht.
    picker = { enabled = true, ui_select = false },

    notifier = {
      enabled = true,
      timeout = 3000,
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      margin = { top = 0, right = 1, bottom = 0 },
      padding = true,
      sort = { "level", "added" },
      level = vim.log.levels.TRACE,
      icons = {
        error = " ",
        warn = " ",
        info = " ",
        debug = " ",
        trace = " ",
      },
      style = "fancy", -- "compact" oder "fancy" oder "minimal"
    },

    quickfile = { enabled = true },

    lazygit = { enabled = true },

    scope = { enabled = true },

    scroll = { enabled = true },

    -- Statuscolumn: aus -- reserviert zusaetzliche Spalten links und macht
    -- den Rand unnoetig breit. Signcolumn + Zeilennummern reichen.
    statuscolumn = { enabled = false },

    -- Zen Mode (optional, sehr nützlich!)
    zen = {
      enabled = true, -- Aktiviere wenn du willst
    },

    -- Styles für verschiedene Windows
    styles = {
      notification = {
        wo = { wrap = true },
        border = "rounded",
      },
    },
  },

  keys = {
    -- Explorer
    {
      "<leader>E",
      function()
        Snacks.explorer()
      end,
      desc = "Explorer (Root Dir)",
    },
    {
      "<leader>e",
      function()
        -- Terminal-/Scratch-Buffer haben kein echtes Verzeichnis -> cwd nehmen.
        local dir = vim.fn.expand("%:p:h")
        if vim.bo.buftype ~= "" or vim.fn.isdirectory(dir) == 0 then
          dir = vim.fn.getcwd()
        end
        Snacks.explorer({ cwd = dir })
      end,
      desc = "Explorer (Current File)",
    },

    -- Git
    {
      "<leader>gg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
    {
      "<leader>gl",
      function()
        Snacks.lazygit.log()
      end,
      desc = "Lazygit Log",
    },
    {
      "<leader>gf",
      function()
        Snacks.lazygit.log_file()
      end,
      desc = "Lazygit Current File History",
    },

    -- Notifier
    {
      "<leader>un",
      function()
        Snacks.notifier.hide()
      end,
      desc = "Dismiss All Notifications",
    },
    {
      "<leader>nh",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Notification History",
    },

    -- Zen Mode (wenn aktiviert)
    {
      "<leader>z",
      function()
        Snacks.zen()
      end,
      desc = "Toggle Zen Mode",
    },
  },

  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Snacks Shortcuts
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd

        -- Toggle features
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle
          .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
      end,
    })
  end,
}
