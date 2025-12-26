return {
	"ravitemer/mcphub.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		port = 3000,
		config_file = vim.fn.stdpath("config") .. "/mcp_servers.json",
	},
}
