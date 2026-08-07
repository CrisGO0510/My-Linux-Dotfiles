return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	lazy = true, -- solo se carga si lo elegís desde <leader>uC
	opts = {
		flavour = "mocha",
		background = { light = "latte", dark = "mocha" },
		transparent_background = false,
		show_end_of_buffer = false,
		integration_default = false,
		integrations = {
			cmp = true,
			gitsigns = true,
			nvimtree = true,
			treesitter = true,
			notify = true,
			mini = { enabled = true },
			noice = true,
			snacks = true,
			telescope = { enabled = true, style = "nvchad" },
			lsp_trouble = true,
			which_key = true,
		},
	},
	config = function(_, opts)
		require("catppuccin").setup(opts)
	end,
}

