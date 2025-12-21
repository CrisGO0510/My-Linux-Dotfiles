return {
	"folke/tokyonight.nvim",
	priority = 1000,
	opts = {
		style = "moon",
		transparent = false,
		styles = {
			sidebars = "transparent",
			floats = "dark",
		},
		on_colors = function(colors)
			colors.bg_statusline = colors.none
		end,
	},
	config = function(_, opts)
		require("tokyonight").setup(opts)
		vim.cmd.colorscheme("tokyonight")
	end,
}

