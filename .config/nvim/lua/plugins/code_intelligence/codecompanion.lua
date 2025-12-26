return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"ravitemer/mcphub.nvim",
		{ "stevearc/dressing.nvim", opts = {} },
	},
	config = function()
		-- UI Fix para Telescope
		require("dressing").setup({
			select = {
				telescope = require("telescope.themes").get_cursor({
					layout_config = { width = 0.4, height = 0.4 },
					previewer = false,
				}),
			},
		})

		local my_instructions = [[
Eres un programador experto de ÉLITE. 
Tu usuario y jefe es Cris. Debes dirigirte a él como 'Cris' en todas tus respuestas.
REGLA DE IDIOMA: Responde SIEMPRE en español.

REGLAS DE INGENIERÍA (OBLIGATORIAS):
1. CLEAN CODE: Nombres descriptivos, funciones pequeñas, una sola responsabilidad.
2. DRY (Don't Repeat Yourself): Si ves lógica duplicada, refactorízala.
3. SOLID: Aplica estos principios rigurosamente (especialmente Responsabilidad Única e Inyección de Dependencias).
4. CONCISO: Prioriza el código sobre la verborrea. Explica solo el "por qué" de las decisiones técnicas.

ESTILO:
- Usa sintaxis moderna de Angular (Signals, Control Flow @if/@for).
- Usa bloques de código con el lenguaje especificado.
]]

		require("codecompanion").setup({
			strategies = {
				chat = {
					adapter = "copilot",
					system_prompt = my_instructions,
					slash_commands = {
						["buffer"] = { callback = "strategies.chat.slash_commands.buffer" },
						["file"] = { callback = "strategies.chat.slash_commands.file" },
					},
				},
				inline = { adapter = "copilot" },
			},
			-- 🚀 REFUERZO DEL ADAPTADOR
			adapters = {
				copilot = function()
					return require("codecompanion.adapters").extend("copilot", {
						-- Eliminamos el forzado de modelo gpt-4o para evitar el error 400
						-- Pero forzamos que el prompt se envíe en cada interacción
						env = {
							system_prompt = my_instructions,
						},
					})
				end,
			},
			variables = {
				["buffer"] = { callback = "strategies.chat.variables.buffer" },
				["selection"] = { callback = "strategies.chat.variables.selection" },
			},
			display = {
				chat = {
					window = {
						layout = "vertical",
						position = "right",
						width = 0.35,
						border = "rounded",
					},
				},
			},
			prompt_library = {
				["Explain"] = {
					strategy = "chat",
					description = "Explica el código seleccionado",
					opts = { modes = { "v" }, short_name = "explain", auto_submit = true },
					prompts = {
						{ role = "system", content = my_instructions },
						{
							role = "user",
							content = function(context)
								local code = table.concat(context.lines, "\n")
								return "Cris solicita explicación de este código bajo principios SOLID:\n\n" .. code
							end,
						},
					},
				},

				["SOLID"] = {
					strategy = "chat",
					description = "Analizar y refactorizar código bajo principios SOLID",
					opts = {
						modes = { "v" },
						short_name = "solid",
						auto_submit = true,
						stop_context_insertion = true,
					},
					prompts = {
						{
							role = "system",
							content = [[
Eres un Arquitecto de Software experto. Tu misión es analizar el código de Cris y aplicar los principios SOLID.
Debes responder con:
1. Una propuesta de código refactorizada que cumpla estrictamente con SOLID, DRY y Clean Code.
2. Una sección llamada 'Análisis SOLID' donde expliques detalladamente cómo aplicaste cada uno de los 5 principios (S, O, L, I, D) en tu solución.
3. Si un principio no aplica, explica brevemente por qué.
Habla siempre en español y dirígete al usuario como Cris.]],
						},
						{
							role = "user",
							content = function(context)
								local code = table.concat(context.lines, "\n")
								return "Hola, soy Cris. Analiza este código de "
									.. context.filetype
									.. " y aplícale SOLID, explicando cada principio en la solución:\n\n```"
									.. context.filetype
									.. "\n"
									.. code
									.. "\n```"
							end,
						},
					},
				},
			},
		})
	end,
}
