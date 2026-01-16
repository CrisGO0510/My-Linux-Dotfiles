return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"ravitemer/mcphub.nvim",
		{ "stevearc/dressing.nvim", opts = {} },
	},
	config = function()
		require("codecompanion").setup({
			strategies = {
				chat = {
					adapter = "copilot",
				},
				inline = {
					adapter = "copilot",
				},
			},

			display = {
				chat = {
					window = {
						layout = "vertical",
						position = "right",
						width = 0.40,
					},
				},
			},

			extensions = {
				mcphub = {
					callback = "mcphub.extensions.codecompanion",
					opts = {
						show_result_in_chat = true,
						make_vars = true,
						make_slash_commands = true,
					},
				},
			},

			adapters = {
				copilot = function()
					return require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = { default = "gpt-4o" },
						},
						opts = {
							system_prompt = [[Eres un programador de élite. Tu jefe es Cris. 
Responde siempre en español. Aplica SOLID y Clean Code.
IMPORTANTE: Tienes acceso a herramientas externas mediante MCP. 
Si Cris te pide algo, usa las herramientas disponibles.]],
						},
					})
				end,
			},
		})
	end,
}
