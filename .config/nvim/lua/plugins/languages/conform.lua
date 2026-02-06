return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
				rust = { "rustfmt" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				html = { "prettier" },
				htmlangular = { "prettier" },
				css = { "prettier" },
				json = { "prettier" },
				scss = { "prettier" },
				vue = { "prettier" },
			},
		},
	},
}
