-- neovim configuration

-- general settings
vim.opt.number = true              -- show line numbers
vim.opt.relativenumber = false     -- absolute line numbers only
vim.opt.expandtab = true           -- use spaces instead of tabs
vim.opt.tabstop = 2                -- number of spaces per tab
vim.opt.shiftwidth = 2             -- number of spaces for indentation
vim.opt.smartindent = true         -- auto-indent new lines
vim.opt.wrap = true                -- wrap long lines
vim.opt.ignorecase = true          -- case-insensitive search
vim.opt.smartcase = true           -- case-sensitive if uppercase in search
vim.opt.hlsearch = true            -- highlight search results
vim.opt.incsearch = true           -- incremental search
vim.opt.undofile = true            -- persistent undo history
vim.opt.hidden = true              -- allow hidden buffers
vim.opt.mouse = 'a'                -- enable mouse support
vim.opt.termguicolors = true       -- enable true color support
vim.opt.signcolumn = 'yes'         -- always show sign column (for lsp diagnostics)
vim.opt.updatetime = 250           -- faster completion / diagnostics

-- hide lsp warnings, warnings are for weak
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { severity = vim.diagnostic.severity.ERROR },
  signs = { severity = vim.diagnostic.severity.ERROR },
  underline = { severity = vim.diagnostic.severity.ERROR },
})


-- leader key 
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- key mappings
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- navigate between windows
map('n', '<leader>h', '<C-w>h', opts)
map('n', '<leader>j', '<C-w>j', opts)
map('n', '<leader>k', '<C-w>k', opts)
map('n', '<leader>l', '<C-w>l', opts)

-- save and quit shortcuts
map('n', '<leader>w', ':w<CR>', opts)
map('n', '<leader>q', ':q<CR>', opts)

-- clear search highlighting
map('n', '<Esc>', ':nohlsearch<CR>', opts)

-- toggle comments 
map('n', '<leader>/', 'gcc', { remap = true, desc = 'Toggle comment line' })
map('x', '<leader>/', 'gc', { remap = true, desc = 'Toggle comment selection' })

-- diagnostics
map('n', '<leader>e', vim.diagnostic.open_float, opts)  -- float for current line
map('n', '<leader>d', vim.diagnostic.setqflist, opts)   -- all diagnostics in quickfix

-- bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- plugins
require('lazy').setup({
  -- mason
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  
  -- mason lsp
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'pylsp', 'clangd' },
      })
    end,
  },

  -- autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',   -- lsp completion source
      'hrsh7th/cmp-buffer',     -- words from current buffer
      'hrsh7th/cmp-path',       -- filesystem paths
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'path' },
        }),
      })
    end,
  },

  -- lsp configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason-lspconfig.nvim', 'hrsh7th/cmp-nvim-lsp' },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = false
      vim.lsp.config('*', { capabilities = capabilities })

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local bufopts = { noremap = true, silent = true, buffer = ev.buf }
          map('n', 'gd', vim.lsp.buf.definition, bufopts)      -- go to definition
          map('n', 'gD', vim.lsp.buf.declaration, bufopts)     -- go to declaration
          map('n', 'gr', vim.lsp.buf.references, bufopts)      -- list all references
          map('n', 'gi', vim.lsp.buf.implementation, bufopts)  -- go to implementation
          map('n', 'K', vim.lsp.buf.hover, bufopts)            -- show hover documentation
          map('n', '<leader>rn', vim.lsp.buf.rename, bufopts)  -- rename symbol under cursor
          map('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)  -- show code actions
          map('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, bufopts)  -- format buffer
          map('n', '[d', vim.diagnostic.goto_prev, bufopts)    -- jump to previous diagnostic
          map('n', ']d', vim.diagnostic.goto_next, bufopts)    -- jump to next diagnostic
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
      vim.lsp.enable({ 'lua_ls', 'pylsp', 'clangd' })
    end,
  },

  -- telescope (fuzzy finder)
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          layout_strategy = 'horizontal',
          layout_config = { width = 0.9, height = 0.8 },
        },
      })
    end,
    keys = {
      { '<leader>ff', function() require('telescope.builtin').find_files() end, desc = 'Find files' },
      { '<leader>fg', function() require('telescope.builtin').live_grep() end, desc = 'Live grep' },
      { '<leader>fb', function() require('telescope.builtin').buffers() end, desc = 'Buffers' },
      { '<leader>fh', function() require('telescope.builtin').help_tags() end, desc = 'Help tags' },
    },
  },

  -- tree sitter 
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ensure_installed = { 'lua', 'python', 'vim', 'markdown', 'c', 'cpp' }
      require('nvim-treesitter').install(ensure_installed)

      vim.api.nvim_create_autocmd('FileType', {
        pattern = ensure_installed,
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },
})

-- c/c++ native vim indent
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp' },
  callback = function()
    vim.opt_local.cindent = true
  end,
})

-- c compilation
local function compile_c()
  local file = vim.fn.expand('%')
  local output = vim.fn.expand('%:r')
  local cmd = string.format('gcc -o %s %s', output, file)

  vim.fn.system(cmd)
  local exit_code = vim.v.shell_error

  if exit_code == 0 then
    vim.notify('Compiled successfully: ' .. output, vim.log.levels.INFO)
    return true
  else
    vim.notify('Compilation failed!', vim.log.levels.ERROR)
    return false
  end
end

local function run_c()
  local output = vim.fn.expand('%:r')
  vim.cmd('split')
  vim.cmd('terminal ./' .. output)
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'c',
  callback = function()
    map('n', '<leader>c', compile_c, { noremap = true, silent = true, buffer = true, desc = 'Compile C program' })
    map('n', '<leader>r', run_c, { noremap = true, silent = true, buffer = true, desc = 'Run C program' })
  end,
})
