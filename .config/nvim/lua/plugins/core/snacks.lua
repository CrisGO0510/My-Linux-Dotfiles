return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {

		bigfile = { enabled = true },
		quickfile = { enabled = true },

		indent = {
			enabled = true,
			char = "│",
			only_scope = false,
			only_current = false,
		},
		scope = {
			enabled = true,
			char = "▎",
			underline = false,
		},
		scroll = {
			enabled = true,
			animate = {
				duration = { step = 15, total = 250 },
				easing = "linear",
			},
		},

		notifier = {
			enabled = true,
			timeout = 3000,
			style = "compact",
		},
		input = {
			enabled = true,
		},

		words = {
			enabled = true,
		},
		statuscolumn = {
			enabled = true,
		},

		explorer = { enabled = false },
		picker = { enabled = false },
		dashboard = { enabled = false },
	},
}
