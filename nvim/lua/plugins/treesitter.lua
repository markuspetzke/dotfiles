-- nvim-treesitter `main`: no configs module anymore, highlight/indent run
-- through the Neovim builtins per FileType. Parsers are built with the tree-sitter
-- CLI (`cargo install tree-sitter-cli`).
local ensure = {
  "lua",
  "vim",
  "vimdoc",
  "query",
  "html",
  "css",
  "rust",
  "typescript",
  "tsx",
  "astro",
  "markdown",
  "markdown_inline",
  "regex", -- noice: cmdline highlighting
  "bash",
  "json",
  "yaml",
  "toml",
  "javascript",
  "jsdoc",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup({})

      local installed = ts.get_installed()
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, ensure)
      if #missing > 0 then
        ts.install(missing)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if not lang then
            return
          end
          local function attach()
            if
              not vim.api.nvim_buf_is_valid(args.buf)
              or vim.treesitter.language.get_lang(vim.bo[args.buf].filetype) ~= lang
            then
              return
            end
            if pcall(vim.treesitter.start, args.buf, lang) then
              vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
          end
          -- Install missing parsers, start highlighting only after that.
          -- Silently ignore filetypes without a known parser (lazygit, dashboard, ...).
          if not vim.tbl_contains(ts.get_installed(), lang) then
            if not vim.tbl_contains(ts.get_available(), lang) then
              return
            end
            ts.install({ lang }):await(vim.schedule_wrap(attach))
            return
          end
          attach()
        end,
      })
    end,
  },
  {
    -- Close and rename HTML/JSX tags; only loaded for filetypes with tags.
    "windwp/nvim-ts-autotag",
    ft = { "html", "xml", "javascript", "javascriptreact", "typescriptreact", "astro", "vue", "svelte", "markdown" },
    opts = {},
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { desc = desc })
      end

      for lhs, obj in pairs({
        af = "@function.outer",
        ["if"] = "@function.inner",
        ac = "@class.outer",
        ic = "@class.inner",
        aa = "@parameter.outer",
        ia = "@parameter.inner",
      }) do
        map({ "x", "o" }, lhs, function()
          select.select_textobject(obj, "textobjects")
        end, "Select " .. obj)
      end

      map({ "n", "x", "o" }, "]f", function()
        move.goto_next_start("@function.outer", "textobjects")
      end, "Next function")
      map({ "n", "x", "o" }, "[f", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end, "Prev function")
      map({ "n", "x", "o" }, "]C", function()
        move.goto_next_start("@class.outer", "textobjects")
      end, "Next class")
      map({ "n", "x", "o" }, "[C", function()
        move.goto_previous_start("@class.outer", "textobjects")
      end, "Prev class")
    end,
  },
}
