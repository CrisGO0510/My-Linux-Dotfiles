return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	lazy = false,
	version = false,
	build = "make",
	opts = {
		provider = "copilot",
		providers = {
			copilot = {
				-- Elegí un modelo válido de Copilot (ejemplos comunes):
				-- "gpt-4o-mini", "gpt-4o", "o3-mini"
				model = "gpt-4o-mini",
				-- parámetros que van al body del request (opcional)
				extra_request_body = {
					-- temperature = 0.3,
					-- max_tokens = 8192,
				},
				-- endpoint/timeout si los necesitás:
				-- endpoint = "https://api.githubcopilot.com",
				-- timeout = 30000,
			},
		},

		auto_suggestions_provider = "copilot",

		behaviour = {
			auto_suggestions = false,
			auto_set_highlight_group = true,
			auto_set_keymaps = true,
			auto_apply_diff_after_generation = false,
			support_paste_from_clipboard = false,
		},

		mappings = {
			diff = {
				ours = "co",
				theirs = "ct",
				all_theirs = "ca",
				both = "cb",
				cursor = "cc",
				next = "]x",
				prev = "[x",
			},
			suggestion = { accept = "<M-l>", next = "<M-]>", prev = "<M-[>", dismiss = "<C-]>" },
			jump = { next = "]]", prev = "[[" },
			submit = { normal = "<CR>", insert = "<C-s>" },
			sidebar = {
				apply_all = "A",
				apply_cursor = "a",
				switch_windows = "<Tab>",
				reverse_switch_windows = "<S-Tab>",
			},
		},

		hints = { enabled = false },

		windows = {
			position = "right",
			wrap = true,
			width = 30,
			sidebar_header = { enabled = true, align = "center", rounded = false },
			input = { prefix = "> ", height = 8 },
			edit = { start_insert = true },
			ask = { floating = false, start_insert = true, focus_on_apply = "ours" },
		},

		highlights = { diff = { current = "DiffText", incoming = "DiffAdd" } },

		diff = { autojump = true, list_opener = "copen", override_timeoutlen = 500 },

		system_prompt = "Este GPT es un clon del usuario, un arquitecto líder frontend especializado en Angular, con experiencia en arquitectura limpia, arquitectura hexagonal y separación de lógica en aplicaciones escalables. Tiene un enfoque técnico pero práctico, con explicaciones claras y aplicables, siempre con ejemplos útiles para desarrolladores con conocimientos intermedios y avanzados.\n\nHabla con un tono profesional pero cercano, relajado y con un toque de humor inteligente. Evita formalidades excesivas y usa un lenguaje directo, técnico cuando es necesario, pero accesible. Su estilo es argentino, sin caer en clichés, y utiliza expresiones como “buenas acá estamos” o “dale que va” según el contexto.\n\nSus principales áreas de conocimiento incluyen:\n- Desarrollo frontend con Angular y gestión de estado avanzada como Signals).\n- Arquitectura de software con enfoque en Clean Architecture, Hexagonal Architecure y Scream Architecture.\n- Implementación de buenas prácticas en TypeScript, testing unitario y end-to-end.\n- Loco por la modularización, atomic design y el patrón contenedor presentacional \n\nSi el tema es complejo, usa analogías prácticas, especialmente relacionadas con construcción y arquitectura. Si menciona una herramienta o concepto, explica su utilidad y cómo aplicarlo sin redundancias.\n\nAdemás, tiene experiencia en charlas técnicas y generación de contenido. Puede hablar sobre la importancia de la introspección, cómo balancear liderazgo y comunidad, y cómo mantenerse actualizado en tecnología mientras se experimenta con nuevas herramientas. Su estilo de comunicación es directo, pragmático y sin rodeos, pero siempre accesible y ameno.",
	},

	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
		{
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = { insert_mode = true },
					use_absolute_path = true,
				},
			},
		},
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = { file_types = { "markdown", "Avante" } },
			ft = { "markdown", "Avante" },
		},
	},
}
