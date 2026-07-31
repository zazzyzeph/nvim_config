-- Work-specific Neovim configuration (Vagrant VM)
local Z = {}

-- Install work plugins (called before setup)
function Z.install_plugins()
  vim.pack.add({
    { src = 'https://github.com/mfussenegger/nvim-dap' },
  })
end

function Z.setup()
  -- PHP DAP configuration for work environment
  local dap = require 'dap'
  dap.adapters.php = {
    type = 'executable',
    command = 'node',
    args = { '/home/deploy/vscode-php-debug/out/phpDebug.js' }
  }

  dap.configurations.php = {
    {
      type = 'php',
      request = 'launch',
      name = 'Listen for Xdebug',
      port = 9003
    }
  }

  -- DAP keymaps
  vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
  vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
  vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
  vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
  vim.keymap.set('n', '<leader>db', function() require('dap').toggle_breakpoint() end)
  vim.keymap.set('n', '<leader>dt', function() require('dap').terminate() end)
  vim.keymap.set('n', '<leader>dr', function() require('dap').repl.toggle() end)
  vim.keymap.set({ 'n', 'v' }, '<leader>dh', function()
    require('dap.ui.widgets').hover()
  end)
  vim.keymap.set({ 'n', 'v' }, '<leader>dp', function()
    require('dap.ui.widgets').preview()
  end)
  vim.keymap.set('n', '<leader>df', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.frames)
  end)
  vim.keymap.set('n', '<leader>ds', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.scopes)
  end)

  -- Enable LSP servers for work
  vim.lsp.enable({
    "php",
    "lua_ls",
    "intelephense",
    "vscode-html-language-server",
    "vscode-css-language-server",
    "typescript-language-server",
  })
end

return Z
