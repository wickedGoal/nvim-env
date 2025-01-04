return {
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		build = ":MasonUpdate",
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function() end,
	},
	{
		"neovim/nvim-lspconfig",
	},
}
