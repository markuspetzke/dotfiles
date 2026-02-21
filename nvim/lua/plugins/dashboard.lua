return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      auto_toggle_bufferline = false,
    },
  },
  config = function()
    local fzf = require("fzf-lua")
    require('dashboard').setup {
      theme = 'doom', -- 'doom' oder 'hyper'
      config = {

        header = {
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
          '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
          '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
          '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
          '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
          '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
          '',
          '',
        },
        center = {
          {
            icon = '  ',
            icon_hl = 'Title',
            desc = 'Find File           ',
            desc_hl = 'String',
            key = 'f',
            key_hl = 'Number',
            key_format = ' %s',
            action = function() fzf.files() end,
          },
          {
            icon = '  ',
            desc = 'Recent Files        ',
            key = 'r',
            key_format = ' %s',
            action = function() fzf.oldfiles() end,
          },
          {
            icon = '  ',
            desc = 'Find Word           ',
            key = 'g',
            key_format = ' %s',
            action = function() fzf.live_grep() end,
          },
          -- {
          --   icon = '  ',
          --   desc = 'Projects            ',
          --   key = 'p',
          --   key_format = ' %s',
          --   action = function() fzf.grep_projects() end,
          -- },
          {
            icon = '  ',
            desc = 'New File            ',
            key = 'n',
            key_format = ' %s',
            action = 'enew',
          },
          {
            icon = '  ',
            desc = 'Configuration       ',
            key = 'c',
            key_format = ' %s',
            action = function()
              fzf.files{
                cwd = vim.fn.stdpath("config"),
                prompt = "Neovim Config❯ ",
              }
            end,
          },
          {
            icon = '  ',
            desc = 'Lazy       ',
            key = 'l',
            key_format = ' %s',
            action = 'Lazy',
          },
          {
            icon = '  ',
            desc = 'Quit                ',
            key = 'q',
            key_format = ' %s',
            action = 'quit',
          },
        },
        footer = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return {
            '',
            '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms',
          }
        end,
      },
      hide = {
        statusline = true,
        bufferline = true,
        winbar = true,
      },
    }
  end,
}
