return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-project.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		{
			"nvim-telescope/telescope-frecency.nvim",
			dependencies = { "kkharji/sqlite.lua" },
		},
	},
	config = function()
		local telescope = require("telescope")
		local themes = require("telescope.themes")

		telescope.setup({
			defaults = {
				file_ignore_patterns = { "%.git/" },
			},
			pickers = {
				find_files = {
					find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
				},
				live_grep = {
					additional_args = function()
						return { "--hidden" }
					end,
				},
			},
			extensions = {
				project = {
					base_dirs = {
						"~/Documents/Repo",
						"~/dotfiles",
					},
					hidden_files = true,
					theme = "dropdown",
					order_by = "recent",
				},
				["ui-select"] = {
					themes.get_cursor({
						layout_config = {
							width = 65,
							height = 10,
						},
					}),
				},
				frecency = {
					auto_validate = true, -- Verificar archivos existen
					show_scores = false, -- Interface limpia
					show_unindexed = true, -- Mostrar archivos no indexados
					ignore_patterns = { "*.git/*", "*/tmp/*", "*/node_modules/*" },
					default_workspace = "CWD", -- Por directorio actual
					workspaces = {
						["conf"] = "~/.config",
						["data"] = "~/.local/share",
						["project"] = "~/Documents/Repo",
						["dotfiles"] = "~/dotfiles",
					},
				},
			},
		})
		telescope.load_extension("project")
		telescope.load_extension("ui-select") -- 3. Cargamos la extensión
		telescope.load_extension("frecency") -- Cargamos frecency
	end,
}
