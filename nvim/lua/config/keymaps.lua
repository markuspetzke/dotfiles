local map = require("utils.utils").map

-- Insert mode
vim.keymap.set("i", "jj", "<ESC>", { silent = true, desc = "Exit insert mode" })

-- Speichern
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- Besseres j/k bei wrapped lines
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })

-- Terminal
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
