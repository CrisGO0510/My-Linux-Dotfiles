return {
	"ravitemer/mcphub.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	build = "npm i -g mcp-hub",
	opts = {
		port = 3000,
		config_file = vim.fn.stdpath("config") .. "/mcp_servers.json",
		shutdown_delay = 5000,
		global_env = {
			ALLOWED_DIRECTORY = vim.fn.expand("~"),
		},
	},
}
