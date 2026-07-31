# Neovim Keymap Cheatsheet

Leader key: `<Space>`

## General (shared.lua)

| Keymap | Mode | Action |
|---|---|---|
| `<leader>w` | n | Write (save) file |
| `<leader>q` | n | Quit |
| `<leader>bw` | n | Close buffer (`:bw`) |
| `<leader>yy` | n, v, x | Yank to system clipboard |
| `<leader>xx` | n, v, x | Delete to system clipboard |
| `<leader>yf` | n | Yank current file's relative path to clipboard |
| `<leader>t` | n | Format buffer (`vim.lsp.buf.format`) |

## Window Navigation (shared.lua)

| Keymap | Mode | Action |
|---|---|---|
| `<C-h>` | n | Move to window left |
| `<C-j>` | n | Move to window below |
| `<C-k>` | n | Move to window above |
| `<C-l>` | n | Move to window right |

## Fuzzy Finding / Files (mini.pick, mini.files)

| Keymap | Mode | Action |
|---|---|---|
| `<leader>ff` | n | Pick files |
| `<leader>fg` | n | Live grep |
| `<leader>fr` | n | Resume last picker |
| `<leader>fh` | n | Pick help tags |
| `<leader>fb` | n | Pick buffers |
| `<leader>e` | n | Open file explorer (`MiniFiles`) |
| `]b` / `[b` | n | Next/previous buffer (mini.bracketed) |

## LSP (set on `LspAttach`, buffer-local)

> Re-homed under `<leader>l` because `mini.operators` claims `gr` and removes the default `grn`/`gra`/`gri`/`grr`/`grt` maps.

| Keymap | Mode | Action |
|---|---|---|
| `<leader>lr` | n | Rename symbol |
| `<leader>la` | n, x | Code action |
| `<leader>lR` | n | References |
| `<leader>li` | n | Implementation |
| `<leader>lt` | n | Type definition |
| `<leader>ld` | n | Definition |
| `<leader>ls` | n | Document symbols |
| `<leader>lh` | n | Hover |
| `<leader>le` | n | Open diagnostic float |
| `<C-k>` | i (insert) | Signature help |

## Debugging — work only (work.lua, nvim-dap)

| Keymap | Mode | Action |
|---|---|---|
| `<F5>` | n | Continue |
| `<F10>` | n | Step over |
| `<F11>` | n | Step into |
| `<F12>` | n | Step out |
| `<leader>db` | n | Toggle breakpoint |
| `<leader>dt` | n | Terminate session |
| `<leader>dr` | n | Toggle REPL |
| `<leader>dh` | n, v | Hover widget |
| `<leader>dp` | n, v | Preview widget |
| `<leader>df` | n | Centered float: stack frames |
| `<leader>ds` | n | Centered float: scopes |

## TidalCycles — personal only (personal.lua, tidal.nvim)

| Keymap | Mode | Action |
|---|---|---|
| `<S-CR>` | i, n | Send line |
| `<S-CR>` | x | Send visual selection |
| `<M-CR>` | i, n, x | Send block |
| `<leader><CR>` | n | Send node |
| `<leader>ms` | n | Send silence |
| `<leader>mh` | n | Send hush |
| `<leader>mq` | n | `:TidalQuit` |
| `<leader>ml` | n | Launch Tidal + SuperCollider (opens split terminal) |

## Notes (from init.lua comments)

- `<S-k>` (Shift-K) — hover on the current string (default LSP/vim behavior)
- `<C-w>d` — show line diagnostics
- Clean a long TidalCycles line: `:s/[\$\#]/\r&/g | normal! ==`
