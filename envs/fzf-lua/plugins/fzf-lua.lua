return {
	{
		"ibhagwan/fzf-lua",
		keys = {
			{ "<leader>ff", "<cmd>lua require('fzf-lua').files()<CR>", desc = "Files" },
			{ "<leader>fg", "<cmd>lua require('fzf-lua').live_grep()<CR>", desc = "Live Grep" },
			{ "<leader>fh", "<cmd>lua require('fzf-lua').helptags()<CR>", desc = "Help Tags" },
			{ "<leader>fm", "<cmd>lua require('fzf-lua').manpages()<CR>", desc = "Man Pages" },
		},
		-- optional for icon support
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- calling `setup` is optional for customization
			require("fzf-lua").setup({})
		end,
	},
}
