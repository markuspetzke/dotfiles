local map = vim.keymap.set

map("i", "jj", "<ESC>", { silent = true, desc = "Exit insert mode" })

map("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

map({ "i", "n", "v" }, "<C-s>", function()
  vim.cmd("update")
end, { desc = "Save file" })

-- Move through wrapped lines like real lines unless a count is given.
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })

-- Keep the cursor centered while searching/scrolling
map("n", "n", "nzzzv", { desc = "Next match" })
map("n", "N", "Nzzzv", { desc = "Prev match" })
-- <C-d>/<C-u> deliberately without "zz": recentering clashes with the scroll animation
-- of snacks.scroll, and then a keypress gets "swallowed" now and then.

-- Move lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { silent = true, desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { silent = true, desc = "Move selection up" })

-- Keep the selection after indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Do not overwrite the register when pasting over a selection
map("x", "<leader>P", [["_dP]], { desc = "Paste without yanking" })

-- Windows
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
map("n", "<leader>ww", "<C-W>w", { desc = "Next window" })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })
map("n", "<leader>w-", "<C-W>s", { desc = "Split window below" })
map("n", "<leader>w|", "<C-W>v", { desc = "Split window right" })
map("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
map("n", "<leader>|", "<C-W>v", { desc = "Split window right" })

-- Buffer
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to other buffer" })
map("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New buffer" })

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Built-in undotree (Neovim 0.12): moving the cursor in the tree walks through the undo states.
map("n", "<leader>uu", function()
  vim.cmd.packadd("nvim.undotree")
  require("undotree").open()
end, { desc = "Toggle undotree" })

-- Diagnostics / Quickfix
map("n", "<leader>xl", vim.diagnostic.setloclist, { desc = "Diagnostic location list" })
map("n", "<leader>xq", vim.diagnostic.setqflist, { desc = "Diagnostic quickfix list" })
-- [q / ]q (quickfix), [l / ]l (location list), [b / ]b (buffers): Neovim defaults.
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })
map("n", "]e", function()
  vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next error" })
map("n", "[e", function()
  vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous error" })
