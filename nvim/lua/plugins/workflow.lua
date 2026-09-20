return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { branch = true },
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore project session",
      },
      {
        "<leader>qS",
        function()
          require("persistence").select()
        end,
        desc = "Select session",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore last session",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't save session on exit",
      },
    },
  },
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerTaskAction", "OverseerShell" },
    opts = {},
    keys = {
      { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Run task (cargo/npm/make)" },
      { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Toggle task list" },
      { "<leader>oa", "<cmd>OverseerTaskAction<cr>", desc = "Task actions" },
      {
        "<leader>ol",
        function()
          local overseer = require("overseer")
          local task = overseer.list_tasks({ recent_first = true })[1]
          if task then
            overseer.run_action(task, "restart")
          else
            vim.notify("No previous task", vim.log.levels.INFO)
          end
        end,
        desc = "Restart last task",
      },
    },
  },
}
