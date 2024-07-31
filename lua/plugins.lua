vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'
  		use {
			'VonHeikemen/lsp-zero.nvim',
			branch = 'v3.x',
			requires = {
				{'williamboman/mason.nvim'},
				{'williamboman/mason-lspconfig.nvim'},
				{'neovim/nvim-lspconfig'},
		}
	}
end)
