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

        map("n", "]h", function()
          gs.nav_hunk("next")
        end, "Next git hunk")
        map("n", "[h", function()
          gs.nav_hunk("prev")
        end, "Previous git hunk")
        map("n", "<leader>gp", gs.preview_hunk, "Preview git hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset git hunk")
        map("v", "<leader>gr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset git hunk")
        map("n", "<leader>gs", gs.stage_hunk, "Stage/unstage git hunk (toggle)")
        map("v", "<leader>gs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage git hunk")
        map("n", "<leader>gb", gs.blame_line, "Blame line")
        map("n", "<leader>gB", function()
          gs.blame_line({ full = true })
        end, "Blame line full")
        map("n", "<leader>gd", gs.diffthis, "Diff this")
        map("n", "<leader>gtb", gs.toggle_current_line_blame, "Toggle inline blame")
      end,
    },
  },
}
