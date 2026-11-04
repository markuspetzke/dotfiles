local function fzf(cmd, opts)
  return function()
    require("fzf-lua")[cmd](opts)
  end
end

return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    files = {
      cmd = "fd --type f --hidden --exclude .git --exclude node_modules --exclude .cargo --exclude target",
    },
    winopts = { preview = { layout = "vertical", vertical = "up:55%" } },
    lsp = { code_actions = { previewer = "codeaction_native" } },
    -- Show only the installed dark themes: builtins and light variants are left out.
    colorschemes = {
      ignore_patterns = {
        "^default$",
        "^vim$",
        "^blue$",
        "^darkblue$",
        "^delek$",
        "^desert$",
        "^elflord$",
        "^evening$",
        "^habamax$",
        "^industry$",
        "^koehler$",
        "^lunaperche$",
        "^morning$",
        "^murphy$",
        "^pablo$",
        "^peachpuff$",
        "^quiet$",
        "^retrobox$",
        "^ron$",
        "^shine$",
        "^slate$",
        "^sorbet$",
        "^torte$",
        "^unokai$",
        "^wildcharm$",
        "^zaibatsu$",
        "^zellner$",
        "day$",
        "latte$",
        "dawn$",
        "lotus$",
        "pearl$",
        "mist$",
      },
    },
  },
  config = function(_, opts)
    local fzf_lua = require("fzf-lua")
    fzf_lua.setup(opts)
    -- vim.ui.select (e.g. code actions) through fzf instead of the bare prompt.
    fzf_lua.register_ui_select()
  end,
  init = function()
    -- Also before fzf-lua was used once: the first vim.ui.select call loads the plugin,
    -- whose config registers the real handler.
    local builtin = vim.ui.select
    local function stub(...)
      require("lazy").load({ plugins = { "fzf-lua" } })
      if vim.ui.select == stub then
        vim.ui.select = builtin
      end
      return vim.ui.select(...)
    end
    vim.ui.select = stub
  end,
  keys = {
    { "<leader><space>", fzf("files"), desc = "Find Files" },
    { "<leader>ff", fzf("files"), desc = "Find Files (Project)" },
    {
      "<leader>fc",
      fzf("files", { cwd = vim.fn.stdpath("config"), prompt = "Config Files❯ " }),
      desc = "Find Config Files",
    },
    { "<leader>fr", fzf("oldfiles"), desc = "Recent Files" },
    { "<leader>fg", fzf("live_grep"), desc = "Live Grep" },
    { "<leader>fw", fzf("grep_cword"), desc = "Grep Word Under Cursor" },
    { "<leader>fw", fzf("grep_visual"), mode = "v", desc = "Grep Selection" },
    { "<leader>fb", fzf("buffers"), desc = "Buffers" },
    { "<leader>fh", fzf("help_tags"), desc = "Help Tags" },
    { "<leader>fk", fzf("keymaps"), desc = "Keymaps" },
    { "<leader>f:", fzf("command_history"), desc = "Command History" },
    { "<leader>fR", fzf("resume"), desc = "Resume Last Picker" },
    {
      "<leader>uC",
      function()
        -- Colorschemes are lazy; without loading them they are missing from the list.
        require("lazy").load({
          plugins = { "tokyonight.nvim", "catppuccin", "rose-pine", "kanagawa.nvim", "kanso", "gruvbox.nvim" },
        })
        require("fzf-lua").colorschemes()
      end,
      desc = "Colorscheme (Preview)",
    },
    { "<leader>fs", fzf("lsp_document_symbols"), desc = "Document Symbols" },
    { "<leader>fS", fzf("lsp_live_workspace_symbols"), desc = "Workspace Symbols" },
    { "<leader>fd", fzf("diagnostics_document"), desc = "Document Diagnostics" },
    { "<leader>fD", fzf("diagnostics_workspace"), desc = "Workspace Diagnostics" },
    { "<leader>gc", fzf("git_commits"), desc = "Git Commits" },
    { "<leader>gS", fzf("git_status"), desc = "Git Status" },
  },
}
