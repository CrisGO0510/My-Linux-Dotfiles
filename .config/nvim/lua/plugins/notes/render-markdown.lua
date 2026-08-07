return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = "markdown",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"echasnovski/mini.icons",
	},
	opts = {
		-- Muestra el markdown crudo en la línea del cursor: sin esto no se ve
		-- lo que se está editando.
		anti_conceal = { enabled = true },
		heading = {
			width = "block",
			left_pad = 0,
			right_pad = 2,
		},
		code = {
			width = "block",
			right_pad = 2,
		},
		checkbox = {
			unchecked = { icon = "󰄱 " },
			checked = { icon = " " },
		},
	},
}
