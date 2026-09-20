return {

  -- Colorschemes. Alle geladen (kostet fast nichts, nur rtp), der aktive wird in
  -- config/options.lua gesetzt; <leader>uC zeigt die Auswahl mit Live-Preview.
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, opts = { style = "moon" } },
  { "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000, opts = { flavour = "mocha" } },
  { "rose-pine/neovim", name = "rose-pine", lazy = false, priority = 1000, opts = { variant = "moon" } },
  { "rebelot/kanagawa.nvim", lazy = false, priority = 1000, opts = {} },
  { "webhooked/kanso.nvim", name = "kanso", lazy = false, priority = 1000 },
  { "ellisonleao/gruvbox.nvim", lazy = false, priority = 1000, opts = {} },

  {
    -- Blockman-Port: verschachtelte Bloecke als abgestufte Hintergrundflaechen.
    "HampusHauffman/block.nvim",
    cmd = { "Block", "BlockOn", "BlockOff" },
    keys = { { "<leader>uB", "<cmd>Block<cr>", desc = "Toggle Block (Blockman)" } },
    opts = {
      percent = 0.85, -- Aufhellung/Abdunklung pro Ebene (naeher an 1 = subtiler)
      depth = 4, -- Anzahl der Farbstufen
      automatic = false, -- nur per Toggle, nicht in jedem Buffer
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      local function lsp_clients()
        local names = {}
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          names[#names + 1] = c.name
        end
        return #names > 0 and (" " .. table.concat(names, " ")) or ""
      end
      local function autoformat()
        return vim.g.autoformat and "󰉶" or "󰉸"
      end
      return {
        options = {
          theme = "auto",
          globalstatus = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = { statusline = { "dashboard", "snacks_dashboard" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            {
              "diagnostics",
              symbols = { error = " ", warn = " ", info = " ", hint = " " },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1, symbols = { modified = "●", readonly = "", unnamed = "" } },
          },
          lualine_x = {
            {
              function()
                return require("noice").api.status.mode.get()
              end,
              cond = function()
                return package.loaded["noice"] and require("noice").api.status.mode.has()
              end,
              color = { fg = "#ff9e64" },
            },
            {
              function()
                return require("dap").status()
              end,
              cond = function()
                return package.loaded["dap"] and require("dap").status() ~= ""
              end,
              icon = " ",
            },
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = { fg = "#ff9e64" },
            },
            {
              "diff",
              symbols = { added = " ", modified = " ", removed = " " },
              source = function()
                local g = vim.b.gitsigns_status_dict
                if g then
                  return { added = g.added, modified = g.changed, removed = g.removed }
                end
              end,
            },
          },
          lualine_y = { { lsp_clients }, { autoformat } },
          lualine_z = { { "location", padding = { left = 0, right = 1 } }, "progress" },
        },
        extensions = { "lazy", "nvim-dap-ui", "quickfix", "man" },
      }
    end,
  },
  {
    -- Breadcrumbs in der Winbar: datei > struct > fn, klickbar.
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      {
        "<leader>;",
        function()
          require("dropbar.api").pick()
        end,
        desc = "Dropbar pick",
      },
    },
    opts = {},
  },
  {
    -- Cmdline/Suche als Popup, Messages als Notifications, LSP-Progress.
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      routes = {
        -- "written"-Meldungen und Suchtreffer-Zaehler nicht als Notification.
        {
          filter = {
            event = "msg_show",
            any = { { find = "%d+L, %d+B" }, { find = "; after #%d+" }, { find = "; before #%d+" } },
          },
          view = "mini",
        },
        { filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
    keys = {
      {
        "<leader>nl",
        function()
          require("noice").cmd("last")
        end,
        desc = "Last message",
      },
      {
        "<leader>na",
        function()
          require("noice").cmd("all")
        end,
        desc = "All messages",
      },
      {
        "<leader>nd",
        function()
          require("noice").cmd("dismiss")
        end,
        desc = "Dismiss all",
      },
      {
        "<c-f>",
        function()
          if not require("noice.lsp").scroll(4) then
            return "<c-f>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll forward",
        mode = { "i", "n", "s" },
      },
      {
        "<c-b>",
        function()
          if not require("noice.lsp").scroll(-4) then
            return "<c-b>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll backward",
        mode = { "i", "n", "s" },
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      code = { sign = false, width = "block", right_pad = 1 },
      heading = { sign = false, icons = {} },
      checkbox = { enabled = true },
      completions = { lsp = { enabled = true } },
    },
    keys = { { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Render Markdown" } },
  },
  {
    -- Aktuelle Funktion/Klasse bleibt beim Scrollen oben stehen.
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = { max_lines = 3, multiline_threshold = 1, trim_scope = "outer", mode = "cursor" },
    keys = { { "<leader>ut", "<cmd>TSContext toggle<cr>", desc = "Toggle Treesitter Context" } },
  },
  {
    -- Aktiver Split bekommt einen farbigen Rahmen.
    "nvim-zh/colorful-winsep.nvim",
    event = "WinNew",
    opts = {},
  },
  {
    -- Farbige Klammern nach Verschachtelungstiefe.
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "rainbow-delimiters.setup",
    opts = {},
  },
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put After" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put Before" },
      { "<C-n>", "<Plug>(YankyNextEntry)", desc = "Next yank entry" },
      { "<C-p>", "<Plug>(YankyPreviousEntry)", desc = "Previous yank entry" },
      { "<leader>p", "<cmd>YankyRingHistory<cr>", desc = "Yank History" },
    },
  },
  {
    "kylechui/nvim-surround",
    version = "^4.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
  },
}
