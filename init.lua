-- Put this at the top of 'init.lua'
local path_package = vim.fn.stdpath('data') .. '/site'
local mini_path = path_package .. '/pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    -- Uncomment next line to use 'stable' branch
    -- '--branch', 'stable',
    'https://github.com/nvim-mini/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

vim.o.number = true
vim.o.relativenumber = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = false
vim.o.smartindent = true
vim.o.wrap = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.swapfile = false
vim.o.termguicolors = true
vim.o.undofile = true
vim.o.incsearch = true
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.signcolumn = 'yes'
vim.o.winborder = 'rounded'
vim.o.clipboard = 'unnamedplus'
vim.o.scrolloff = 10
vim.opt.iskeyword:append("-")
-- don't save blank buffers to sessions (like neo-tree, trouble etc.)
vim.opt.sessionoptions:remove('blank')
vim.o.listchars = table.concat({ "extends:…", "nbsp:␣", "precedes:…", "tab:> " }, ",")
vim.o.expandtab = true
vim.o.softtabstop = 2
vim.o.autoindent = true

vim.o.conceallevel = 1

vim.g.tidal_target = "terminal"
vim.g.tidal_boot = "/home/zazzy/tidal/BootTidal.hs"

-- Hoogle-based completion for TidalCycles
require('tidal_hoogle').setup()

vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set('n', '<leader>bw', ':bw<CR>')
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>y', '"+y<CR>')
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>d', '"+d<CR>')

vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/ellisonleao/gruvbox.nvim' },
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/mason-org/mason.nvim' },
  { src = 'https://github.com/tidalcycles/vim-tidal' },
  { src = 'https://github.com/mfussenegger/nvim-dap' },
  { src = 'https://github.com/tpope/vim-sleuth' },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
  { src = 'https://github.com/windwp/nvim-autopairs' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
})

require 'mason'.setup()
require 'mini.pick'.setup()
require 'mini.files'.setup()
require 'mini.icons'.setup()
require 'mini.ai'.setup()
require 'mini.operators'.setup()
require 'mini.surround'.setup()
require 'mini.bracketed'.setup()
require 'mini.statusline'.setup()
require 'mini.tabline'.setup()
require 'mini.completion'.setup()
require 'mini.indentscope'.setup({
  draw = {
    -- Delay (in ms) between event and start of drawing scope indicator
    delay = 0,
    animation = require('mini.indentscope').gen_animation.none()
  },
  symbol = '▏',
})

local gen_loader = require('mini.snippets').gen_loader
require('mini.snippets').setup({
  snippets = {
    -- Load custom file with global snippets first (adjust for Windows)
    gen_loader.from_file('~/.config/nvim/snippets/global.json'),

    -- Load snippets based on current language by reading files from
    -- "snippets/" subdirectories from 'runtimepath' directories.
    gen_loader.from_lang(),
  },
})

local ap = require('nvim-autopairs')
local apRule = require('nvim-autopairs.rule')
local apConds = require('nvim-autopairs.conds')
ap.setup()
-- Add a custom rule for single quotes
ap.add_rules({
  apRule("'", "'")
    :with_pair(function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local before = line:sub(1, col)
      local _, count = before:gsub('"', '')
      return count % 2 == 0
    end)
})

require 'nvim-treesitter.configs'.setup({
  indent = { enable = true },
  ensure_installed = {
    'html',
    'javascript',
    'css',
    'scss',
    'php',
    'haskell',
    'rust'
  },
  highlight = { enable = true },
})
vim.treesitter.language.register('javascript', 'es6')

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

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method('textDocument/completion') then
      -- Optional: trigger autocompletion on EVERY keypress. May be slow!
      local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})
vim.cmd('set completeopt+=noselect')


vim.keymap.set('n', '<leader>t', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>ff', ':Pick files<CR>')
vim.keymap.set("n", '<leader>fg', ':Pick grep_live<CR>')
vim.keymap.set("n", '<leader>fr', ':Pick resume<CR>')
vim.keymap.set('n', '<leader>fh', ':Pick help<CR>')
vim.keymap.set('n', '<leader>e', ':lua MiniFiles.open()<CR>')
vim.keymap.set("n", "<leader>l", ':bnext<CR>')
vim.keymap.set("n", "<leader>h", ':bprevious<CR>')


vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
-- vim.keymap.set('n', '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
-- vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
-- vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
  require('dap.ui.widgets').hover()
end)
vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
  require('dap.ui.widgets').preview()
end)
vim.keymap.set('n', '<Leader>df', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.frames)
end)
vim.keymap.set('n', '<Leader>ds', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end)

vim.cmd('colorscheme gruvbox')

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      }
    }
  }
})
vim.diagnostic.config({ virtual_text = true })
vim.lsp.config("intelephense", {
  cmd = { "intelephense", "--stdio" },
  filetypes = { 'php' },
  root_markers = { "composer.json" }
})
vim.lsp.config("vscode-html-language-server", {
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html' },
})
vim.lsp.config("vscode-css-language-server", {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss' },
})
vim.lsp.config("typescript-language-server", {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
})
vim.lsp.config("rust-analyzer", {
  cmd = { 'rust-analyzer', '--stdio' },
  filetypes = { 'rust' },
})
vim.lsp.config("haskell-language-server", {
  cmd = { 'haskell-language-server' },
  filetypes = { 'haskell' },
})
vim.lsp.enable({
  "php",
  "lua_ls",
  "intelephense",
  "vscode-html-language-server",
  "vscode-css-language-server",
  "typescript-language-server",
  "haskell-language-server",
  "rust-analyzer"
})


-- things to remember
-- shift k = hover on the current string
-- ctrl w d = line diagnostics
--
-- clean long tidalcycles line - :s/[\$\#]/\r&/g | normal! == -- issue: # won't reindent for some reason :thinking_face:
