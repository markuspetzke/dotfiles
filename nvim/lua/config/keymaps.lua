local map = vim.keymap.set

map("i", "jj", "<ESC>", { silent = true, desc = "Exit insert mode" })

map({ "i", "n", "v", "x" }, "<C-s>", function()
  vim.cmd("update")
end, { desc = "Save file" })

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>ww", "<C-W>p", { desc = "Other window" })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })
map("n", "<leader>w-", "<C-W>s", { desc = "Split window below" })
map("n", "<leader>w|", "<C-W>v", { desc = "Split window right" })

map("n", "<leader>xl", vim.diagnostic.setloclist, { desc = "Diagnostic location list" })
map("n", "<leader>xq", vim.diagnostic.setqflist, { desc = "Diagnostic quickfix list" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })

map("t", "<esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
