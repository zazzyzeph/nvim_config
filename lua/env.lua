-- Environment detection for work vs personal Neovim configs
local M = {}

-- Detect current environment
-- Priority order:
-- 1. Check for marker file ~/.config/nvim/.nvim_env
-- 2. Check NVIM_ENV environment variable
-- 3. Check hostname patterns
-- 4. Default to 'personal'
function M.detect()
  -- Method 1: Marker file (most explicit)
  local marker_file = vim.fn.stdpath('config') .. '/.nvim_env'
  if vim.fn.filereadable(marker_file) == 1 then
    local env = vim.fn.readfile(marker_file)[1]
    if env then
      env = env:gsub('^%s*(.-)%s*$', '%1') -- trim whitespace
      return env
    end
  end

  -- Method 2: Environment variable
  local env_var = vim.fn.getenv('NVIM_ENV')
  if env_var ~= vim.NIL and env_var ~= '' then
    return env_var
  end

  -- Method 3: Hostname detection
  local hostname = vim.fn.hostname()
  -- Adjust these patterns to match your actual hostnames
  if hostname:match('vagrant') or hostname:match('vm') or hostname:match('work') then
    return 'work'
  end

  -- Default to personal
  return 'personal'
end

-- Get current environment
M.current = M.detect()

-- Helper to check if we're in a specific environment
function M.is(env_name)
  return M.current == env_name
end

return M
