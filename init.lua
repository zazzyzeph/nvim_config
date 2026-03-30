-- Bootstrap mini.nvim
local path_package = vim.fn.stdpath('data') .. '/site'
local mini_path = path_package .. '/pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/nvim-mini/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Detect environment (work or personal)
local env = require('env')

-- Display current environment at startup
vim.notify('Environment: ' .. env.current, vim.log.levels.INFO)

-- Load shared configuration
require('shared').setup()

-- Load environment-specific configuration
if env.is('work') then
  require('work').setup()
elseif env.is('personal') then
  require('personal').setup()
end

-- Things to remember
-- shift k = hover on the current string
-- ctrl w d = line diagnostics
-- clean long tidalcycles line: :s/[\$\#]/\r&/g | normal! ==
