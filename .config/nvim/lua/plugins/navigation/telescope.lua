return {
	"nvim-telescope/telescope.nvim",
	-- VeryLazy y no cmd: la extensión ui-select reemplaza vim.ui.select, y eso
	-- tiene que estar registrado antes del primer vim.ui.select del día.
	event = "VeryLazy",
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

		-- Los directorios varían por máquina (branch laptop vs default).
		-- Pasar uno inexistente hace que project/frecency tiren error al arrancar.
		local function existing_dirs(dirs)
			local found = {}
			for _, dir in ipairs(dirs) do
				if vim.fn.isdirectory(vim.fn.expand(dir)) == 1 then
					table.insert(found, dir)
				end
			end
			return found
		end

		local function existing_workspaces(map)
			local found = {}
			for name, dir in pairs(map) do
				if vim.fn.isdirectory(vim.fn.expand(dir)) == 1 then
					found[name] = dir
				end
			end
			return found
		end

		local repo_dirs = existing_dirs({ "~/Documents/Repo", "~/dotfiles" })

		telescope.setup({
			defaults = {
				file_ignore_patterns = { "%.git/" },
			},
			pickers = {
				find_files = {
					find_command = { "fd", "--type", "f", "--hidden", "--no-ignore-vcs", "--exclude", ".git", "--exclude", "node_modules" },
				},
				live_grep = {
					additional_args = function()
						return { "--hidden" }
					end,
				},
			},
			extensions = {
				project = {
					base_dirs = repo_dirs,
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
					workspaces = existing_workspaces({
						["conf"] = "~/.config",
						["data"] = "~/.local/share",
						["project"] = "~/Documents/Repo",
						["dotfiles"] = "~/dotfiles",
					}),
				},
			},
		})
		telescope.load_extension("project")
		telescope.load_extension("ui-select") -- 3. Cargamos la extensión
		telescope.load_extension("frecency") -- Cargamos frecency
	end,
}
