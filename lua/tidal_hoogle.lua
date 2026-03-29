-- Hoogle-based completion for TidalCycles
-- Provides function signatures and documentation via hoogle queries

local M = {}

-- Cache for hoogle results to avoid repeated queries
M.cache = {}
M.cache_ttl = 300 -- seconds

-- Cache for documentation
M.doc_cache = {}

-- Get detailed documentation for a function
function M.get_doc(func_name)
  -- Check cache first
  if M.doc_cache[func_name] then
    return M.doc_cache[func_name]
  end

  local cmd = string.format("hoogle search --info %s 2>/dev/null", vim.fn.shellescape("module:Sound.Tidal " .. func_name))
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 or output == "" then
    -- Try without module filter
    cmd = string.format("hoogle search --info %s 2>/dev/null", vim.fn.shellescape(func_name))
    output = vim.fn.system(cmd)
  end

  if vim.v.shell_error ~= 0 or output == "" then
    return nil
  end

  -- Cache and return
  M.doc_cache[func_name] = output
  return output
end

-- Query hoogle and parse results
function M.hoogle_search(query, limit)
  limit = limit or 50
  local cmd = string.format("hoogle search --count=%d %s 2>/dev/null", limit, vim.fn.shellescape(query))
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    return {}
  end

  local results = {}
  for line in output:gmatch("[^\r\n]+") do
    -- Parse hoogle output: "Module.Name function :: Type -> Type"
    local module_name, func_name, signature = line:match("^([%w%.]+)%s+([%w_']+)%s+::%s+(.+)$")
    if func_name and signature then
      table.insert(results, {
        word = func_name,
        abbr = func_name,
        menu = ":: " .. signature,
        kind = "f",
        dup = 0,
        user_data = { module = module_name, signature = signature },
      })
    else
      -- Handle entries without signatures (like data types, modules)
      local mod, name = line:match("^([%w%.]+)%s+([%w_']+)%s*$")
      if name then
        table.insert(results, {
          word = name,
          abbr = name,
          menu = mod,
          kind = "t",
          dup = 0,
          user_data = { module = mod },
        })
      end
    end
  end
  return results
end

-- Omnifunc implementation for tidal files
function M.omnifunc(findstart, base)
  if findstart == 1 then
    -- Find the start of the word
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local start = col
    while start > 0 and line:sub(start, start):match("[%w_']") do
      start = start - 1
    end
    return start
  else
    -- Return completions
    if base == "" then
      return {}
    end

    -- Check cache
    local cache_key = base
    local cached = M.cache[cache_key]
    if cached and (os.time() - cached.time) < M.cache_ttl then
      return cached.results
    end

    -- Query hoogle with Tidal module filter
    local results = {}
    local seen = {}

    -- Search specifically in Sound.Tidal modules
    local tidal_results = M.hoogle_search("module:Sound.Tidal " .. base, 20)
    for _, item in ipairs(tidal_results) do
      if not seen[item.word] then
        seen[item.word] = true
        -- Fetch documentation for this item
        local doc = M.get_doc(item.word)
        if doc then
          item.info = doc
        else
          item.info = item.user_data.module .. "\n" .. item.word .. " " .. (item.menu or "")
        end
        table.insert(results, item)
      end
    end

    -- Also search without module filter for common Haskell functions
    if #results < 8 then
      local general_results = M.hoogle_search(base, 10)
      for _, item in ipairs(general_results) do
        if not seen[item.word] then
          seen[item.word] = true
          local doc = M.get_doc(item.word)
          if doc then
            item.info = doc
          else
            item.info = (item.user_data.module or "") .. "\n" .. item.word .. " " .. (item.menu or "")
          end
          table.insert(results, item)
        end
      end
    end

    -- Cache results
    M.cache[cache_key] = { results = results, time = os.time() }

    return results
  end
end

-- Show signature/documentation for word under cursor
function M.show_signature()
  local word = vim.fn.expand("<cword>")
  if word == "" then return end

  local doc = M.get_doc(word)

  if not doc then
    vim.notify("No documentation found for: " .. word, vim.log.levels.INFO)
    return
  end

  -- Split into lines
  local lines = {}
  for line in doc:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  -- Show in floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("filetype", "haskell", { buf = buf })
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

  local width = math.min(70, vim.o.columns - 4)
  local height = math.min(#lines, 20)
  local opts = {
    relative = "cursor",
    width = width,
    height = height,
    row = 1,
    col = 0,
    style = "minimal",
    border = "rounded",
  }
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- Close on escape or q
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, nowait = true })
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, nowait = true })
end

-- Manual completion trigger
function M.trigger_completion()
  -- Force omnifunc completion
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<C-x><C-o>", true, false, true),
    "n",
    false
  )
end

-- Clear caches (useful if hoogle database is updated)
function M.clear_cache()
  M.cache = {}
  M.doc_cache = {}
  vim.notify("Tidal Hoogle cache cleared", vim.log.levels.INFO)
end

-- Setup function to configure for tidal filetype
function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "tidal",
    callback = function()
      -- Set omnifunc for completion
      vim.bo.omnifunc = "v:lua.require'tidal_hoogle'.omnifunc"

      -- Keymap to show documentation (like K for LSP hover)
      vim.keymap.set("n", "K", M.show_signature, {
        buffer = true,
        desc = "Show Tidal function signature via Hoogle"
      })

      -- Manual completion trigger with Ctrl+Space
      vim.keymap.set("i", "<C-Space>", M.trigger_completion, {
        buffer = true,
        desc = "Trigger Hoogle completion"
      })
    end,
  })

  -- Command to clear cache
  vim.api.nvim_create_user_command("TidalClearCache", M.clear_cache, {})
end

return M
