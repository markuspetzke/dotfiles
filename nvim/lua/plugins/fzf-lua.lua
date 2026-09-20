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
    -- Nur die installierten dunklen Themes anzeigen: Builtins und Light-Varianten raus.
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
    -- vim.ui.select (z.B. Code Actions) ueber fzf statt der nackten Prompt.
    fzf_lua.register_ui_select()
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
    { "<leader>uC", fzf("colorschemes"), desc = "Colorscheme (Preview)" },
    { "<leader>fs", fzf("lsp_document_symbols"), desc = "Document Symbols" },
    { "<leader>fS", fzf("lsp_live_workspace_symbols"), desc = "Workspace Symbols" },
    { "<leader>fd", fzf("diagnostics_document"), desc = "Document Diagnostics" },
    { "<leader>fD", fzf("diagnostics_workspace"), desc = "Workspace Diagnostics" },
    { "<leader>gc", fzf("git_commits"), desc = "Git Commits" },
    { "<leader>gS", fzf("git_status"), desc = "Git Status" },
  },
}
