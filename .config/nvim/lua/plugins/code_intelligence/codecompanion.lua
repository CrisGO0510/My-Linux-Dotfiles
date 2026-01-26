return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		{ "stevearc/dressing.nvim", opts = {} },
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		-- 1. Lógica de detección de Ollama (Puerto 5000)
		local function check_ollama()
			local handle = io.popen("curl -s -m 1 -o /dev/null -w '%{http_code}' http://localhost:5000")
			local result = handle:read("*a")
			handle:close()
			return result == "200"
		end

		local ollama_active = check_ollama()
		local default_adapter = ollama_active and "ollama" or "copilot"

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
				-- ADAPTADOR OLLAMA (Cerebro Local)
				ollama = function()
					return require("codecompanion.adapters").extend("ollama", {
						schema = {
							model = { default = "qwen2.5-coder:14b" },
							num_ctx = { default = 16384 },
						},
						env = { url = "http://localhost:5000" },
						opts = { system_prompt = system_prompt },
					})
				end,
				-- ADAPTADOR COPILOT (Cerebro en la Nube - Fallback)
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

		-- Notificación para saber qué modelo estamos usando al arrancar
		if ollama_active then
			print("🚀 IA: Mentor Qwen (Local) activo en puerto 5000")
		else
			print("☁️ IA: Ollama apagado. Usando Copilot (Cloud)")
		end

		require("dressing").setup({
			select = { enabled = true, backend = { "telescope", "builtin" } },
		})
	end,
}
