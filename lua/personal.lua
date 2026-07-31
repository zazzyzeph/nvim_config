-- Personal-specific Neovim configuration (Host machine)
local Z = {}

-- Install personal plugins (called before setup)
function Z.install_plugins()
  vim.pack.add({
    { src = 'https://codeberg.org/MrReason/tidal.nvim' },
    { src = 'https://github.com/madskjeldgaard/tree-sitter-supercollider' },
  })
end

function Z.setup()
  -- Additional treesitter languages for personal projects
  require('nvim-treesitter.configs').setup({
    ensure_installed = {
      'html', 'javascript', 'css', 'scss', 'php',
      'haskell', 'rust', 'supercollider'  -- Additional for personal
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
  -- vim.lsp.config.tidal_ls = {
  --   cmd = { 'node', '/home/zazzy/Code/tidal_ls/dist/server.js', '--stdio' },
  --   filetypes = { 'tidal' },
  --   root_markers = { '.git' },
  -- }

  -- Enable all LSP servers including personal ones
  vim.lsp.enable({
    "php",
    "lua_ls",
    "intelephense",
    "vscode-html-language-server",
    "vscode-css-language-server",
    "typescript-language-server",
    "haskell-language-server",
    "rust-analyzer",
    -- 'tidal_ls'
  })

  -- Setup tidal.nvim
  require('tidal').setup({
    --- Configure TidalLaunch command
    boot = {
      tidal = {
        --- Command to launch ghci with tidal installation
        cmd = "ghci",
        args = {
          "-v0",
        },
        --- Tidal boot file path
        file = "/home/zazzy/tidal/BootTidal.hs",
        enabled = true,
        highlight = {
          styles = {
            osc = {
              ip = "127.0.0.1",
              port = 3335,
            },
            -- [Tidal ID] -> hl style
            custom = {
              ["drums"] = { bg = "#e7b9ed", foreground = "#000000" },
              ["2"] = { bg = "#b9edc7", foreground = "#000000" },
            },
            global = { baseName = "CodeHighlight", style = { bg = "#7eaefc", foreground = "#000000" } },
          },
          events = {
            osc = {
              ip = "127.0.0.1",
              port = 6013,
            },
          },
          fps = 30,
        },
      },
      split = "v",
    },
    --- Default keymaps
    --- Set to false to disable all default mappings
    --- @type table | nil
    mappings = {
      send_line = { mode = { "i", "n" }, key = "<S-CR>" },
      send_visual = { mode = { "x" }, key = "<S-CR>" },
      send_block = { mode = { "i", "n", "x" }, key = "<M-CR>" },
      send_node = { mode = "n", key = "<leader><CR>" },
      send_silence = { mode = "n", key = "<leader>ms" },
      send_hush = { mode = "n", key = "<leader>mh" },
    },
    ---- Configure highlight applied to selections sent to tidal interpreter
    selection_highlight = {
      --- Highlight definition table
      --- see ':h nvim_set_hl' for details
      --- @type vim.api.keyset.highlight
      highlight = { link = "IncSearch" },
      --- Duration to apply the highlight for
      timeout = 150,
    },
  })

  -- Tidal session management
  vim.keymap.set('n', '<leader>mq', ':TidalQuit<CR>', { desc = 'Quit Tidal session' })
  vim.keymap.set('n', '<leader>ml', function()
    vim.cmd('TidalLaunch')
    vim.cmd('TidalNotification')
    vim.cmd('belowright split')
    vim.cmd('terminal sclang ~/tidal/startup.scd')
    vim.cmd('vertical resize ' .. math.floor(vim.o.columns * 0.3))
    vim.cmd('wincmd l')
  end, { desc = 'Launch Tidal + SuperCollider' })
end

return Z
