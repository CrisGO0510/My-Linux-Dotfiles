return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		{ "stevearc/dressing.nvim", opts = {} },
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("codecompanion").setup({
			strategies = {
				chat = { adapter = "ollama" },
				inline = { adapter = "ollama" },
			},
			-- Ventana a la derecha
			display = {
				chat = {
					window = { layout = "vertical", position = "right", width = 0.40 },
				},
			},
			adapters = {
				ollama = function()
					return require("codecompanion.adapters").extend("ollama", {
						schema = {
							model = { default = "qwen2.5-coder:14b" },
							num_ctx = { default = 16384 }, -- 16k de contexto para leer archivos largos
						},
						opts = {
							system_prompt = [[Eres un programador de élite. Tu jefe es Cris. 
Responde SIEMPRE en español. 
Aplica SOLID, Clean Code y patrones de diseño.
Tu objetivo es escribir código robusto y mantenible.]],
						},
					})
				end,
			},
		})

		-- Setup de Dressing para que los menús de CodeCompanion se vean bien
		require("dressing").setup({
			select = { enabled = true, backend = { "telescope", "builtin" } },
		})
	end,
}
