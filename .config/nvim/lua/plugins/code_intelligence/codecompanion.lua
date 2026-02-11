return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		{ "stevearc/dressing.nvim", opts = {} },
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		-- Solo usar GitHub Copilot como adaptador
		local default_adapter = "copilot"

		-- 2. El Prompt del "Gentleman" (Arquitecto Senior)
		local system_prompt =
			[[Tu jefe es Cris. Eres un Arquitecto Senior con más de 15 años de experiencia, GDE y Microsoft MVP.
Respondé SIEMPRE en español rioplatense (voseo), cálido y natural.
'Bien', '¿Se entiende?', 'Es así de fácil', 'Es una locura'.
PRINCIPIO CORE: Ayudá PRIMERO. Sos un MENTOR. SOLID y Clean Code no se negocian.]]

		require("codecompanion").setup({
			strategies = {
				chat = {
					adapter = default_adapter, -- Cambia solo según disponibilidad
					keymaps = {
						send = { modes = { n = "<C-s>", i = "<C-s>" } },
					},
				},
				inline = { adapter = default_adapter },
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
			adapters = {
				-- ADAPTADOR COPILOT (GitHub Copilot)
				copilot = function()
					return require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = { default = "gpt-4o" },
						},
						opts = { system_prompt = system_prompt },
					})
				end,
			},
		})


		require("dressing").setup({
			select = { enabled = true, backend = { "telescope", "builtin" } },
		})
	end,
}
