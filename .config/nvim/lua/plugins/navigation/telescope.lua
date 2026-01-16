return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-project.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
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
			},
		})
		telescope.load_extension("project")
		telescope.load_extension("ui-select") -- 3. Cargamos la extensión
	end,
}
