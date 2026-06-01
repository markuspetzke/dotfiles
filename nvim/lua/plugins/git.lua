return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "]h", gs.next_hunk, "Next git hunk")
        map("n", "[h", gs.prev_hunk, "Previous git hunk")
        map("n", "<leader>gp", gs.preview_hunk, "Preview git hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset git hunk")
        map("v", "<leader>gr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset git hunk")
        map("n", "<leader>gb", gs.blame_line, "Blame line")
        map("n", "<leader>gB", function()
          gs.blame_line({ full = true })
        end, "Blame line full")
        map("n", "<leader>gd", gs.diffthis, "Diff this")
      end,
    },
  },
}
