return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  event = 'VeryLazy',
  keys = {
    { '<leader>ft', '<cmd>Neotree toggle<cr>', desc = 'NeoTree' },
    { '<S-h>', '<cmd>bprevious<cr>', desc = 'Prev Buffer' },
    { '<S-l>', '<cmd>bnext<cr>', desc = 'Next Buffer' },
    { '<leader>bd', '<cmd>bdelete<cr>', desc = 'Delete Buffer' },
    { '<leader>bD', '<cmd>bdelete!<cr>', desc = 'Delete Buffer (Force)' },
  },
  opts = {
    options = {

      mode = 'buffers',
      themable = true,

      -- Zahlen anzeigen
      numbers = 'none', -- "none" | "ordinal" | "buffer_id" | "both"

      -- Icons
      indicator = {
        icon = '▎',
        style = 'icon', -- 'icon' | 'underline' | 'none'
      },

      buffer_close_icon = '󰅖',
      modified_icon = '●',
      close_icon = '',
      left_trunc_marker = '',
      right_trunc_marker = '',

      -- Diagnostics
      diagnostics = 'nvim_lsp',
      diagnostics_update_in_insert = false,
      diagnostics_indicator = function(count, level, diagnostics_dict, context)
        local icon = level:match 'error' and ' ' or ' '
        return ' ' .. icon .. count
      end,

      -- Offsets (für File Explorer links)
      offsets = {
        {
          filetype = 'snacks_explorer',
          text = 'File Explorer',
          text_align = 'center',
          separator = true,
        },
      },

      -- Farbe basierend auf Buffer-Sichtbarkeit
      color_icons = true,
      show_buffer_icons = true,
      show_buffer_close_icons = false,
      show_close_icon = false,
      show_tab_indicators = true,
      show_duplicate_prefix = true,

      -- Separator Style
      separator_style = 'thin', -- "slant" | "slope" | "thick" | "thin" | { 'any', 'any' }

      -- Immer Tab-Leiste anzeigen
      always_show_bufferline = false,
    },
  },

  config = function(_, opts)
    require('bufferline').setup(opts)

    -- Fix bufferline wenn neovim mit Argumenten gestartet wird
    vim.api.nvim_create_autocmd('BufAdd', {
      callback = function()
        vim.schedule(function()
          pcall(function()
            require('bufferline.commands').refresh()
          end)
        end)
      end,
    })
  end,
}
