# neovim-config

My personal Neovim setup.

## Structure

- `init.lua` — all settings, keymaps, and plugins
- `lazy-lock.json` — plugin version lockfile

## Plugins

Managed by [lazy.nvim](https://github.com/folke/lazy.nvim) (bootstrapped automatically).

- `mason.nvim` + `mason-lspconfig.nvim` — install LSP servers
- `nvim-lspconfig` — LSP client config

LSP servers: `lua_ls`, `pylsp`, `clangd`

Treesitter parsers: `lua`, `python`, `vim`, `markdown`, `c`, `cpp`
