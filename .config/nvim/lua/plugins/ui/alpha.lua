return {
	"goolord/alpha-nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- ASCII Art de Lain con elementos cyberpunk
		dashboard.section.header.val = {
			"      ⣿⣿⣿⣿⣿⣿⣿⣻⠿⣝⡿⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⢫⡿⣽⢣⡒⡄⠲⡐⢄⠢⠀⠀⢀⠠⣽",
			"      ⣿⣿⣿⣿⣿⣿⣿⣻⣿⠙⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢫⢿⡽⣣⠕⡨⢁⠉⢂⠁⠠⠐⣤⣿⣿",
			"      ⣿⣿⣿⣿⣿⣻⣿⣟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠫⣗⢇⢢⠐⠌⡰⠀⣌⣶⣿⡟⠓⢉",
			"      ⣟⠬⡛⠽⠻⠿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣾⠡⢎⠢⣱⣿⡿⣟⠚⣌⢡⢆",
			"      ⣿⢻⡶⣍⡀⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢫⠘⢂⣴⣿⠏⠉⠄⠉⠀⡁⠈",
			"      ⡛⢷⣶⣍⡛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⡿⢋⡰⢌⡑⢀⠂⠡⣄⢣",
			"      ⣭⠒⣌⡉⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⢦⣑⠣⠐⢂⠌⡳⢬⣷",
			"      ⢇⠏⡴⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠄⡀⠄⠀⢂⠨⣴⣻⣿",
			"      ⣜⡸⡠⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡠⢀⡜⠠⢄⣧⣿⣿⣿",
			"      ⣎⢵⣛⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣗⣨⣴⠾⠛⣩⣵⡾⠿",
			"      ⣿⣾⣽⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⠀⢽⣆⠀⠀⠀⠀⠀⣦⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣻⣭⡴⠶⢛⠫⠑⠂⠁",
			"      ⡝⣜⠳⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⡏⠀⢺⣿⠀⠀⠀⠀⠀⣿⣇⡀⠆⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠄⠀⠀⠀⠀⠀⠀⠀",
			"      ⡼⢶⣟⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠃⡆⣿⣿⣿⣿⠁⣀⢸⣿⠀⠀⠀⠀⢰⣿⣿⠡⠘⠄⣠⡀⠀⠀⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠘⣎⠳⠌⠂⠄⠀⠀⠄",
			"      ⣿⡭⢪⠅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⢸⣷⠸⣿⣿⣿⣷⢹⡌⣿⣸⢠⣴⣶⣿⣿⣿⣼⡦⠟⠛⠛⠃⠐⠥⠠⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣳⣮⣳⡌⣤⢤⣰⣤⣶",
			"      ⢧⡈⠳⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣶⡄⠿⠘⠛⠂⠙⠛⠻⣿⣏⢿⣼⣿⣿⣿⣿⣿⣿⢋⣠⣤⠶⠶⢶⣶⣷⣶⣶⣶⣴⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡷⣷⣷⣾⣤⣿⣿⣿⠭",
			"      ⣶⡜⢤⠀⠀⠀⠀⠀⠀⠀⠀⠀⢘⣩⣤⣶⣶⣶⣿⣿⣯⣭⡝⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢁⠟⠍⠁⠀⡀⠈⡉⢻⣿⣿⠂⠀⠀⠀⠀⢀⣠⠀⠀⠀⠀⠀⣤⡾⠛⢉⣀⣤⣴",
			"      ⣿⣿⣳⡂⠀⠀⠀⠀⠀⠀⠀⠀⢈⣿⣿⣿⠟⠉⠉⠀⠠⠀⠉⢺⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣼⡀⠀⠀⠀⠀⣿⠀⢿⣿⡄⠓⠦⢄⢀⠞⠁⠀⠀⢲⣷⠿⠛⠓⠛⠉⠍⠉⠀",
			"      ⣿⡷⣯⢿⡄⠔⡀⠀⠀⠀⠀⣧⡘⣾⣿⠄⢰⣇⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣮⡻⠶⠤⠴⠞⢋⣼⣿⣿⠀⠀⠀⣠⠟⢤⡀⠀⠀⠈⠍⠂⠀⠀⠈⠁⠈⠀⠀",
			"      ⣿⣿⡿⣯⢿⡼⢷⠀⡀⠀⠀⠠⢹⣿⣿⣶⣀⠙⠷⠶⠶⣛⣥⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⢠⠞⠉⠀⠀⠁⠀⠀⠀⡀⢀⠀⠀⢀⣀⣤⠴⠞",
			"      ⣟⣯⢿⡝⠉⠀⡘⣄⠐⠀⠐⢤⡀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⣧⣯⣽⢾⣛⣫⡽⠶⠛⢋",
			"      ⠿⣚⣳⠌⡐⠠⠑⠨⠁⠠⠀⠀⠙⠒⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⣽⠷⣚⢫⢛⠲⣜⠢⡁⢆",
			"      ⣿⣿⣿⣟⣷⣶⣷⣶⣶⣶⠗⠀⠀⠀⠐⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⢠⣄⡡⠀⠢⠌⡱⡌⡄⢑⠪",
			"      ⣿⣿⡿⣿⢿⣿⣿⠿⠋⠁⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⢨⡟⣧⢃⠂⠤⢡⣙⠘⡄⠂",
			"      ⣿⡷⣿⢿⢿⡛⣡⢶⡒⠆⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠲⠜⡁⠊⠐⠈⠂⠙⠮⠐⡀",
			"      ⣿⣽⠋⠁⢠⠘⣵⢫⡝⣤⠀⠀⠀⠀⠀⠀⠀⠀⠈⠿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣭⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⢠⣶⠐⡆⠂⡄⠀⠀⠀⠀⠀⠀⠀⠀",
			"      ⠉⠠⣌⠰⢀⠱⣌⠷⢣⠅⠀⣀⡀⠢⢀⠔⡠⠂⠀⠀⣄⠙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣫⣤⠀⣀⠠⡖⡁⠀⠀⠀⠀⠸⣁⠣⢘⠐⠠⠀⠀⠀⠀⠀⠀⠀⠀",
			"      ⣴⡿⡎⠔⠠⡁⢆⡋⢇⠊⢰⠽⡁⢀⠂⠆⠠⠁⠀⢠⡟⢸⣿⠆⣽⣻⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠈⠜⡠⢀⠁⠀⠀⠀⠀⡳⣔⡢⢄⠊⡄⢠⠀⡀⠀⡀⢀⠀⣀",
			"      ⣿⡝⣡⠋⡐⡐⠢⠙⡌⢢⢉⠒⠀⠂⠌⠠⢁⠂⢠⡿⢠⣿⡿⢀⣿⣿⣿⣾⣟⣛⣿⣿⣿⣛⣯⣿⣿⣿⣿⣿⣿⣿⡇⢨⣷⣒⠀⠀⠀⠀⢀⡳⣜⢿⢯⡷⣼⣥⣙⠶⣽⣜⣣⢻⡴",
			"      ⠣⠈⡄⢣⠐⠁⢡⠚⠬⡁⢂⡱⢈⡐⢈⠐⡠⠂⣼⠇⣾⣿⢃⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⢻⡆⠀⠀⠀⠀⡼⢑⢮⡏⡟⠽⢣⠙⢋⠎⠱⠋⠖⢣⠙",
			"      ⠀⠐⡈⢄⠰⠈⠠⣉⠦⣑⢦⡕⣣⠐⡂⠐⠀⣼⣻⡼⠟⣡⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠁⠀⠀⠀⢸⣝⡞⢦⡙⢬⢃⠂⠁⠀⠀⠀⠀⠈⠀⠀",
			"      ⠀⢆⡸⢌⢆⠡⣧⢷⡺⣝⡾⣽⢧⣛⠴⠉⠞⣋⣥⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⣏⢾⡹⣧⠞⣄⠂⠌⠀⠀⠀⠀⡀⠀⠀⠀",
			"      ⡜⣢⢝⡲⣎⡷⠽⠳⢛⣙⣉⣉⣡⣤⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⠀⣤⣈⠒⠽⣳⡟⣬⢋⠄⠀⠀⠀⠀⠀⠀⠐⠀",
			"      ⠸⡁⢎⣡⣷⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⢸⣿⣿⣿⣶⣤⣌⣀⠉⠂⠀⠀⠀⠀⠀⠀⠀⠀",
			"                                                         ",
			"                  ╔═══ Present day, present time  ═══╗   ",
			"                  ║     Serial Experiments Lain      ║   ",
			"                  ╚══════════════════════════════════╝   ",
		}

		-- Botones simplificados para evitar conflictos
		dashboard.section.buttons.val = {
			dashboard.button("n", "📄  Nuevo Archivo", ":ene <BAR> startinsert<CR>"),
			dashboard.button("f", "🔍  Buscar Archivos", "<leader>ff"),
			dashboard.button("p", "🗂️  Proyectos", "<leader>fp"),
			dashboard.button("q", "🚪  Salir", ":qa<CR>"),
		}

		-- Footer con mensaje filosófico
		local function footer()
			local total_plugins = #vim.tbl_keys(require("lazy").plugins())
			local datetime = os.date(" %d-%m-%Y   %H:%M:%S")
			local plugins_text = "⚡ " .. total_plugins .. " plugins loaded"
			local v = vim.version()
			local nvim_version_info = "   v" .. v.major .. "." .. v.minor .. "." .. v.patch

			return {
				"",
				"┌─────────────────────────────────────────────────────┐",
				"│       No matter where you go, we're connected       │",
				"│              The wired is everywhere                │",
				"└─────────────────────────────────────────────────────┘",
				"",
				plugins_text .. nvim_version_info .. datetime,
			}
		end

		dashboard.section.footer.val = footer()

		-- Configuración del layout
		dashboard.config.layout = {
			{ type = "padding", val = 2 },
			dashboard.section.header,
			{ type = "padding", val = 2 },
			dashboard.section.buttons,
			{ type = "padding", val = 1 },
			dashboard.section.footer,
		}

		-- Colores personalizados usando catppuccin
		dashboard.section.header.opts.hl = "AlphaHeader"
		dashboard.section.buttons.opts.hl = "AlphaButtons"
		dashboard.section.footer.opts.hl = "AlphaFooter"

		-- Configurar highlights
		vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#cba6f7" }) -- Purple catppuccin
		vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#89b4fa" }) -- Blue catppuccin
		vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#6c7086" }) -- Surface2 catppuccin

		-- Solo mostrar alpha cuando no hay argumentos y no se restaura sesión
		dashboard.config.opts.noautocmd = true

		alpha.setup(dashboard.config)

		-- Deshabilitar folding en alpha
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "alpha",
			callback = function()
				vim.opt_local.foldenable = false
			end,
		})
	end,
}

