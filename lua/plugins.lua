vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'
  		use {
			'VonHeikemen/lsp-zero.nvim',
			branch = 'v3.x',
			requires = {
				-- Mason and mason-lspconfig
				{'williamboman/mason.nvim'},
				{'williamboman/mason-lspconfig.nvim'},

				-- LSP Support
				{'neovim/nvim-lspconfig'},
		}
	}
end)
