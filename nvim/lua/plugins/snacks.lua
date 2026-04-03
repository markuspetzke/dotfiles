return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    animate = {
      enabled = false,
    },

    bigfile = {
      enabled = true,
      notify = true,
      size = 1.5 * 1024 * 1024, -- 1.5MB
      setup = function(ctx)
        vim.cmd([[NoMatchParen]])
        vim.schedule(function()
          vim.bo[ctx.buf].syntax = ctx.ft
        end)
      end,
    },

    dashboard = { enabled = false },

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

    input = {
      enabled = false,
    },

    picker = { enabled = false },

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

    scope = {
      enabled = false,
    },

    scroll = {
      enabled = false,
    },

    -- Statuscolumn (Zeilen-Nummern, Signs, Folds)
    statuscolumn = {
      enabled = false,
    },

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
      input = {
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
        Snacks.explorer({ cwd = vim.fn.expand("%:p:h") })
      end,
      desc = "Explorer (Current File)",
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
