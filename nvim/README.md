# Neovim Config

Personal Neovim setup built on `lazy.nvim` (Neovim 0.12+).

## Highlights

- `fzf-lua` for files, grep, buffers, help, symbols, diagnostics and `vim.ui.select`.
- `nvim-lspconfig`, `mason.nvim` and `blink.cmp` for LSP and completion; per-server settings live in `lsp/<name>.lua`.
- `nvim-treesitter` (`main` branch) for highlighting, indentation and textobjects.
- `conform.nvim` for formatting (toggle autoformat with `<leader>uf`).
- `snacks.nvim` for explorer, notifications, toggles, quickfile and zen mode.
- `gitsigns.nvim` and Snacks lazygit for Git workflow.
- Rust support via `rustaceanvim`, debugging via `nvim-dap`.
- `persistence.nvim` saves project sessions on exit, with separate sessions for Git branches.
  Restore explicitly with `<leader>qs` or `s` on the dashboard.
- `overseer.nvim` runs tasks from Cargo, npm, Make and `.vscode/tasks.json`.
- Precognition and Hardtime start disabled; `<leader>uH` toggles both as a learning mode.

## Useful Keys

- `<leader><space>` / `<leader>ff` find files
- `<leader>fg` live grep, `<leader>fw` grep word/selection
- `<leader>fs` / `<leader>fS` document / workspace symbols
- `<leader>fd` / `<leader>fD` document / workspace diagnostics
- `<leader>fk` keymaps, `<leader>fR` resume last picker
- `<leader>e` explorer at current file, `<leader>E` at project root
- `<leader>cf` format buffer, `<leader>ca` code action, `<leader>cr` rename
- `gd` / `gD` / `gI` goto definition / declaration / implementation
- `<leader>gg` lazygit, `<leader>gl` log, `<leader>gf` file history, `<leader>gc` commits, `<leader>gS` status
- `]h` / `[h` next / previous Git hunk, `<leader>gp` preview hunk
- `]d` / `[d` diagnostics, `]e` / `[e` errors only, `]q` / `[q` quickfix
- `]f` / `[f` next / previous function
- `<C-h/j/k/l>` window navigation, `<A-j/k>` move lines
- `<C-n>` / `<C-p>` cycle yank ring after paste
- `<leader>u*` UI toggles (see which-key)
- `<leader>qs` restore project session, `<leader>qS` select session, `<leader>ql` restore last session
- `<leader>qd` stop saving the current session on exit
- `<leader>or` select/run task, `<leader>ot` task list, `<leader>oa` task actions, `<leader>ol` restart last task
- `<leader>uH` toggle learning mode

## Formatting latency

Format-on-save has a 200 ms budget. After a formatter timeout, that project and
filetype use asynchronous format-after-save for the rest of the Neovim session.
Conform writes the formatted result back to disk; changes made while formatting
are protected by Conform's concurrent-edit checks. Watchers may therefore see
the initial save and a second, formatted write in this mode.

`<leader>uf` disables both modes globally; `:let b:autoformat = v:false` disables
them for the current buffer. `<leader>cf` still formats manually.
`:lua print(vim.b.format_duration_ms)` shows the last synchronous format duration;
`:ConformInfo` shows the active formatters and log.

Local CLI sample measurements (three runs, September 2026): StyLua 9–10 ms,
Prettier TypeScript 62–79 ms, Prettier JSONC 89–105 ms, shfmt 1–2 ms.
Large projects and LSP formatting can take longer.
