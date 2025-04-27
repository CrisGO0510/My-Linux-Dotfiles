return {
	"saghen/blink.cmp",
	version = "*",
	build = "cargo build --release",
	opts = {},
	dependencies = {
		"rafamadriz/friendly-snippets",
		{
			"saghen/blink.compat",
			optional = true,
			opts = {},
			version = "*",
		},
	},
	event = "InsertEnter",
}

