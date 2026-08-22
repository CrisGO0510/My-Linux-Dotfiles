-- Ruido de build/dependencias: nunca es un resultado útil de búsqueda, y muchos
-- proyectos ni siquiera lo tienen en .gitignore (o se busca fuera de un repo).
local IGNORED_DIRS = {
	".git",
	".cache",
	".venv",
	"__pycache__",
	"node_modules",
	"vendor",
	"dist",
	"build",
	"target",
	"coverage",
	".angular",
	".nuxt",
	".next",
	".output",
}

local TMP_GLOB = "*/tmp/*"

local function fd_excludes(base)
	local args = vim.deepcopy(base)
	for _, dir in ipairs(IGNORED_DIRS) do
		table.insert(args, "--exclude")
		table.insert(args, dir)
	end
	return args
end

local function rg_excludes(base)
	local args = vim.deepcopy(base)
	for _, dir in ipairs(IGNORED_DIRS) do
		table.insert(args, "--glob")
		table.insert(args, "!" .. dir .. "/")
	end
	return args
end

-- file_ignore_patterns son patrones de Lua contra la ruta de cada entrada, y
-- cubren los pickers que no lanzan fd/rg (buffers, oldfiles, quickfix).
local function lua_dir_patterns()
	local patterns = {}
	for _, dir in ipairs(IGNORED_DIRS) do
		local escaped = vim.pesc(dir)
		table.insert(patterns, "^" .. escaped .. "/")
		table.insert(patterns, "/" .. escaped .. "/")
	end
	return patterns
end

local function glob_dir_patterns()
	local patterns = { TMP_GLOB }
	for _, dir in ipairs(IGNORED_DIRS) do
		table.insert(patterns, "*/" .. dir .. "/*")
	end
	return patterns
end

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
		local actions = require("telescope.actions")

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
				file_ignore_patterns = lua_dir_patterns(),
				-- Scroll horizontal: cuando la ruta o la línea del grep se sale
				-- del ancho del panel, telescope la corta en seco y no hay forma
				-- de ver el resto. Los defaults (<M-f>/<M-k> para resultados,
				-- <C-f>/<C-k> para la vista previa) son incómodos; zh/zl en modo
				-- normal replican el movimiento nativo de vim, y en modo inserción
				-- van por Alt porque zh ahí se escribiría literal.
				mappings = {
					n = {
						["zh"] = actions.results_scrolling_left,
						["zl"] = actions.results_scrolling_right,
						["zH"] = actions.preview_scrolling_left,
						["zL"] = actions.preview_scrolling_right,
					},
					i = {
						["<M-h>"] = actions.results_scrolling_left,
						["<M-l>"] = actions.results_scrolling_right,
						["<M-H>"] = actions.preview_scrolling_left,
						["<M-L>"] = actions.preview_scrolling_right,
					},
				},
			},
			pickers = {
				-- --hidden sí, pero sin --no-ignore-vcs: los dotfiles de config
				-- (.env, .gitignore, todo ~/dotfiles) se ven, y lo que el repo
				-- ya marca como generado en .gitignore no.
				find_files = {
					find_command = fd_excludes({ "fd", "--type", "f", "--hidden" }),
				},
				live_grep = {
					additional_args = function()
						return rg_excludes({ "--hidden" })
					end,
				},
				grep_string = {
					additional_args = function()
						return rg_excludes({ "--hidden" })
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
					ignore_patterns = glob_dir_patterns(),
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
