-- Shared configuration for both work and personal environments
local Z = {}

function Z.setup()
  -- Basic settings
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
  vim.opt.sessionoptions:remove('blank')
  vim.o.listchars = table.concat({ "extends:…", "nbsp:␣", "precedes:…", "tab:> " }, ",")
  vim.o.expandtab = true
  vim.o.softtabstop = 2
  vim.o.autoindent = true
  vim.o.conceallevel = 1

  -- Shared keymaps
  vim.keymap.set('n', '<leader>w', ':write<CR>')
  vim.keymap.set('n', '<leader>q', ':quit<CR>')
  vim.keymap.set('n', '<leader>bw', ':bw<CR>')
  vim.keymap.set({ 'n', 'v', 'x' }, '<leader>y', '"+y<CR>')
  vim.keymap.set({ 'n', 'v', 'x' }, '<leader>d', '"+d<CR>')

  -- Shared plugins
  vim.pack.add({
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
    { src = 'https://github.com/ellisonleao/gruvbox.nvim' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/mason-org/mason.nvim' },
    { src = 'https://github.com/tpope/vim-sleuth' },
    { src = 'https://github.com/rafamadriz/friendly-snippets' },
    { src = 'https://github.com/windwp/nvim-autopairs' },
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/m4xshen/hardtime.nvim' },
  })

  -- Mini.nvim setup
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
      delay = 0,
      animation = require('mini.indentscope').gen_animation.none()
    },
    symbol = '▏',
  })

  local gen_loader = require('mini.snippets').gen_loader
  require('mini.snippets').setup({
    snippets = {
      gen_loader.from_file('~/.config/nvim/snippets/global.json'),
      gen_loader.from_lang(),
    },
  })

  -- Autopairs
  local ap = require('nvim-autopairs')
  local apRule = require('nvim-autopairs.rule')
  ap.setup()
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

  -- Treesitter (base config, languages can be added per-environment)
  require 'nvim-treesitter.configs'.setup({
    indent = { enable = true },
    ensure_installed = {
      'html',
      'javascript',
      'css',
      'scss',
      'php',
    },
    highlight = { enable = true },
  })
  vim.treesitter.language.register('javascript', 'es6')

  -- LSP setup
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(args)
      local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
      if client:supports_method('textDocument/completion') then
        local chars = {}
        for i = 32, 126 do
          table.insert(chars, string.char(i))
        end
        client.server_capabilities.completionProvider.triggerCharacters = chars
        vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
      end
    end,
  })
  vim.cmd('set completeopt+=noselect')

  -- Shared LSP servers (PHP, HTML, CSS, JS/TS)
  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
        }
      }
    }
  })
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

  -- Keymaps for mini.pick and files
  vim.keymap.set('n', '<leader>t', vim.lsp.buf.format)
  vim.keymap.set('n', '<leader>ff', ':Pick files<CR>')
  vim.keymap.set("n", '<leader>fg', ':Pick grep_live<CR>')
  vim.keymap.set("n", '<leader>fr', ':Pick resume<CR>')
  vim.keymap.set('n', '<leader>fh', ':Pick help<CR>')
  vim.keymap.set('n', '<leader>e', ':lua MiniFiles.open()<CR>')
  vim.keymap.set("n", "<leader>l", ':bnext<CR>')
  vim.keymap.set("n", "<leader>h", ':bprevious<CR>')

  -- Colorscheme
  vim.cmd('colorscheme gruvbox')

  -- Diagnostics
  vim.diagnostic.config({ virtual_text = true })
end

return Z
