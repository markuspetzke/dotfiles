local M = {}

-- Nur das langsame Projekt + Filetype umstellen, nicht alle Dateien derselben Sprache.
local slow = {}
local function project_key(bufnr)
  local root = vim.fs.root(bufnr, { { ".git", "package.json", "Cargo.toml", "pyproject.toml" } })
    or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
    or vim.fn.getcwd()
  return root .. "\0" .. vim.bo[bufnr].filetype
end

local function enabled(bufnr)
  return vim.g.autoformat and vim.b[bufnr].autoformat ~= false and vim.bo[bufnr].buftype == ""
end

function M.on_save(bufnr)
  if not enabled(bufnr) then
    return
  end
  local key = project_key(bufnr)
  if slow[key] then
    return
  end
  local started = vim.uv.hrtime()
  -- Save soll sich wie ein normaler Editorbefehl anfuehlen. Schnelle
  -- Formatter laufen synchron; langsame Projekte wechseln fuer die Sitzung
  -- automatisch in den asynchronen Modus.
  return { timeout_ms = 200, lsp_format = "fallback" }, function(err)
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.b[bufnr].format_duration_ms = math.floor((vim.uv.hrtime() - started) / 1e6)
    end
    if err and err:lower():match("timeout") then
      slow[key] = true
      vim.schedule(function()
        vim.notify("Slow formatter: this project/filetype now formats after save", vim.log.levels.INFO)
      end)
    end
  end
end

function M.after_save(bufnr)
  if enabled(bufnr) and slow[project_key(bufnr)] then
    return { timeout_ms = 1000, lsp_format = "fallback" }
  end
end

return M
