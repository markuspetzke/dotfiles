return {
  'm4xshen/hardtime.nvim',
  lazy = false,
  dependencies = { 'MunifTanjim/nui.nvim' },
  opts = {
    disabled_keys = {
      ['<Up>'] = {},
      ['<Down>'] = {},
    },
    disabled_filetypes = {
      'qf',
      'netrw',
      'lazy',
      'mason',
      'dashboard',
      'snacks_explorer',
      'TelescopePrompt',
    },
  },
}
