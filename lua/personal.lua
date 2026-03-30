-- Personal-specific Neovim configuration (Host machine)
local M = {}

function M.setup()
  -- Personal-specific plugins
  vim.pack.add({
    { src = 'https://github.com/tidalcycles/vim-tidal' },
  })

  -- TidalCycles configuration
  vim.g.tidal_target = "terminal"
  vim.g.tidal_boot = "/home/zazzy/tidal/BootTidal.hs"

  -- Hoogle-based completion for TidalCycles
  require('tidal_hoogle').setup()

  -- Additional treesitter languages for personal projects
  require('nvim-treesitter.configs').setup({
    ensure_installed = {
      'html', 'javascript', 'css', 'scss', 'php',
      'haskell', 'rust'  -- Additional for personal
    },
  })

  -- Additional LSP servers for personal projects
  vim.lsp.config("rust-analyzer", {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
  })
  vim.lsp.config("haskell-language-server", {
    cmd = { 'haskell-language-server-wrapper', '--lsp' },
    filetypes = { 'haskell' },
  })

  -- Enable all LSP servers including personal ones
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
end

return M
