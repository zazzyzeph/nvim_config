-- Work-specific Neovim configuration (Vagrant VM)
local Z = {}

-- Install work plugins (called before setup)
-- nvim-dap and the php/xdebug wiring moved to shared.lua - xdebug is set up on the host
-- too, so both environments want it
function Z.install_plugins()
end

function Z.setup()
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
