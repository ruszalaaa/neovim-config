-- Neovim configuration

-- General settings
vim.opt.number = true              -- Show line numbers
vim.opt.relativenumber = true      -- Show relative line numbers
vim.opt.expandtab = true           -- Use spaces instead of tabs
vim.opt.tabstop = 2                -- Number of spaces per tab
vim.opt.shiftwidth = 2             -- Number of spaces for indentation
vim.opt.smartindent = true         -- Auto-indent new lines
vim.opt.wrap = true                -- Wrap long lines
vim.opt.ignorecase = true          -- Case-insensitive search
vim.opt.smartcase = true           -- Case-sensitive if uppercase in search
vim.opt.hlsearch = true            -- Highlight search results
vim.opt.incsearch = true           -- Incremental search
vim.opt.undofile = true            -- Persistent undo history
vim.opt.hidden = true              -- Allow hidden buffers
vim.opt.mouse = 'a'                -- Enable mouse support
vim.opt.termguicolors = true       -- Enable true color support
vim.opt.signcolumn = 'yes'         -- Always show sign column (for LSP diagnostics)
vim.opt.updatetime = 250           -- Faster completion / diagnostics

-- Leader key (must be set before plugins load)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Key mappings
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Navigate between windows
map('n', '<leader>h', '<C-w>h', opts)
map('n', '<leader>j', '<C-w>j', opts)
map('n', '<leader>k', '<C-w>k', opts)
map('n', '<leader>l', '<C-w>l', opts)

-- Save and quit shortcuts
map('n', '<leader>w', ':w<CR>', opts)
map('n', '<leader>q', ':q<CR>', opts)

-- Clear search highlighting
map('n', '<Esc>', ':nohlsearch<CR>', opts)

-- Diagnostics
map('n', '<leader>e', vim.diagnostic.open_float, opts)  -- Float for current line
map('n', '<leader>d', vim.diagnostic.setqflist, opts)   -- All diagnostics in quickfix

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require('lazy').setup({
  -- Mason 
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'pylsp' },
      })
    end,
  },

  -- LSP configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason-lspconfig.nvim' },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local bufopts = { noremap = true, silent = true, buffer = ev.buf }
          map('n', 'gd', vim.lsp.buf.definition, bufopts)      -- Go to definition
          map('n', 'gD', vim.lsp.buf.declaration, bufopts)     -- Go to declaration
          map('n', 'gr', vim.lsp.buf.references, bufopts)      -- List all references
          map('n', 'gi', vim.lsp.buf.implementation, bufopts)  -- Go to implementation
          map('n', 'K', vim.lsp.buf.hover, bufopts)            -- Show hover documentation
          map('n', '<leader>rn', vim.lsp.buf.rename, bufopts)  -- Rename symbol under cursor
          map('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)  -- Show code actions
          map('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, bufopts)  -- Format buffer
          map('n', '[d', vim.diagnostic.goto_prev, bufopts)    -- Jump to previous diagnostic
          map('n', ']d', vim.diagnostic.goto_next, bufopts)    -- Jump to next diagnostic
        end,
      })
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })
      vim.lsp.enable({ 'lua_ls', 'pylsp' })
    end,
  },
})
