local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- Auto create dir when saving a file
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Datei von aussen geaendert? Neu laden statt still veralten.
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Splits beim Resize des Terminals neu verteilen
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Hilfs-/Listen-Buffer mit q schliessen
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "qf", "man", "checkhealth", "lspinfo", "notify", "startuptime", "dap-float" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true, desc = "Close" })
  end,
})

-- Wrap + Spell in Prosa-Dateien
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("astro_keywords"),
  pattern = "astro",
  callback = function()
    vim.opt_local.iskeyword:remove("-")
  end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Restore cursor to last known position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then
      return
    end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Terminal: Esc verlaesst den Terminal-Modus, in lazygit schliesst es das Fenster.
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("term_esc"),
  callback = function(event)
    if vim.bo[event.buf].filetype == "lazygit" or vim.api.nvim_buf_get_name(event.buf):match("lazygit") then
      vim.keymap.set("t", "<Esc>", "<cmd>close<CR>", { buffer = event.buf, silent = true, desc = "Close lazygit" })
    else
      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = event.buf, desc = "Exit terminal mode" })
    end
  end,
})

-- LSP keymaps. Neovim 0.11+ liefert grr/gra/grn/gri/grt und K bereits als
-- Defaults; hier nur, was darueber hinausgeht. Kein blankes `gr` mappen -- das
-- ist buffer-lokal und wuerde die globalen gr*-Defaults unerreichbar machen.
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("lsp_attach"),
  callback = function(args)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
    end

    map("n", "gd", vim.lsp.buf.definition, "Goto definition")
    map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
    map("n", "gI", vim.lsp.buf.implementation, "Goto implementation")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
    map("n", "<leader>cD", vim.lsp.buf.type_definition, "Type definition")
    map("n", "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "LSP info")

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- ESLint-Fixes nicht zusaetzlich synchron bei jedem Speichern ausfuehren:
    -- Conform uebernimmt das Formatieren; ESLint-Fixes bleiben manuell ueber
    -- Code Actions verfuegbar und blockieren dadurch kein `:wq`.
    -- Inlay Hints (Typen/Parameternamen im Code) standardmaessig an; <leader>uh toggelt.
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
    if client and client:supports_method("textDocument/documentHighlight") then
      local group = vim.api.nvim_create_augroup("user_lsp_highlight_" .. args.buf, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = group,
        buffer = args.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        buffer = args.buf,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        group = augroup("lsp_detach_" .. args.buf),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.clear_references()
          pcall(vim.api.nvim_del_augroup_by_name, "user_lsp_highlight_" .. args.buf)
        end,
      })
    end
  end,
})
