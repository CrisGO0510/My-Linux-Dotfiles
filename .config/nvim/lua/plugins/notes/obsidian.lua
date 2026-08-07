local VAULT_PATH = "~/Documents/obsidian"
local VAULT_NAME = "personal"
local ATTACHMENTS_FOLDER = "attachments"
local OBSIDIAN_CONFIG_GLOB = ".obsidian/**"

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	-- Fuera del vault el plugin hace no-op (comprueba el workspace y sale), así
	-- que cargarlo en cualquier markdown sale gratis. `cmd` lo trae desde
	-- cualquier otro buffer para :Obsidian search / quick_switch / new.
	ft = "markdown",
	cmd = "Obsidian",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	-- opts como función: el `require` de abajo necesita el plugin ya en el rtp,
	-- y una tabla literal se evaluaría al leer este spec (antes de instalarlo).
	opts = function()
		local builtin = require("obsidian.builtin")

		return {
			legacy_commands = false,

			workspaces = {
				{ name = VAULT_NAME, path = VAULT_PATH },
			},

			picker = { name = "telescope.nvim" },

			-- Por defecto genera IDs zettel aleatorios (1a2b3c4d-nota). Con
			-- title_id el nombre de archivo es legible, que importa porque el
			-- vault también se abre en la app de Obsidian.
			note_id_func = builtin.title_id,

			-- El render lo hace render-markdown.nvim: dejar los dos activos
			-- duplica los conceal de links y checkboxes.
			ui = { enable = false },

			-- footer es independiente de ui: barra con backlinks/palabras.
			footer = { enabled = true },

			attachments = { folder = ATTACHMENTS_FOLDER },

			daily_notes = { enabled = false },

			file = { ignore_filters = { OBSIDIAN_CONFIG_GLOB } },
		}
	end,
}
