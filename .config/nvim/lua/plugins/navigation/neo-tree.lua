return {
	"nvim-neo-tree/neo-tree.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	cmd = "Neotree",
	opts = {
		window = {
			position = "left", -- Cambia "right" por "left"
			mappings = {
				["Y"] = "none",
				["t"] = function(state)
					local node = state.tree:get_node()
					local path = node:get_parent_id() or node.path
					vim.cmd("cd " .. path)
					vim.cmd("vsplit | terminal")
				end,
			},
		},
		filesystem = {
			-- Por defecto neo-tree hace `tcd` a su raíz cada vez que cambia
			-- (bind_to_cwd + cwd_target), y eso deja a telescope buscando solo
			-- dentro de esa carpeta. La raíz se pasa explícita al abrir el árbol.
			bind_to_cwd = false,
			filtered_items = {
				hide_dotfiles = false,
				hide_by_name = {
					".git",
					".DS_Store",
				},
				always_show = {
					".env",
					"*.png",
					".*",
					".gitignore",
					"dist",
					"venv",
				},
			},
		},
		default_component_configs = {
			git_status = {
				symbols = {
					added = "✚",
					deleted = "✖",
					modified = "",
					renamed = "",
					untracked = "",
					ignored = "",
					unstaged = "",
					staged = "",
					conflict = "",
				},
				align = "left",
			},
		},
	},
}

