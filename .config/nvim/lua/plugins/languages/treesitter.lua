return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				-- Angular + web
				"angular",
				"html",
				"css",
				"scss",
				-- Vue
				"vue",
				-- TS/JS base
				"typescript",
				"javascript",
				"json",
				"jsdoc",
				"regex",
			},
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },

			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
						["aa"] = "@parameter.outer",
						["ia"] = "@parameter.inner",
						["ab"] = "@block.outer",
						["ib"] = "@block.inner",
						["al"] = "@loop.outer",
						["il"] = "@loop.inner",
						["ai"] = "@conditional.outer",
						["ii"] = "@conditional.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]m"] = "@function.outer",
						["]c"] = "@class.outer",
						["]p"] = "@parameter.outer",
					},
					goto_previous_start = {
						["[m"] = "@function.outer",
						["[c"] = "@class.outer",
						["[p"] = "@parameter.outer",
					},
				},
			},
		})
	end,
}
