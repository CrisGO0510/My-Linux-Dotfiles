return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	lazy = false,
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
	},
	config = function()
		local ts = require("nvim-treesitter")

		ts.setup({})

		local parsers = {
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
			"tsx",
			"json",
			"jsdoc",
			"regex",
			-- Otros lenguajes
			"lua",
			"python",
			"rust",
			"markdown",
			"markdown_inline",
		}

		ts.install(parsers)

		-- Filetypes que reciben highlighting + indent por treesitter
		local filetypes = {
			"angular",
			"htmlangular",
			"html",
			"css",
			"scss",
			"vue",
			"typescript",
			"typescriptreact",
			"javascript",
			"javascriptreact",
			"json",
			"jsonc",
			"lua",
			"python",
			"rust",
			"markdown",
		}

		vim.api.nvim_create_autocmd("FileType", {
			pattern = filetypes,
			callback = function(args)
				local bufnr = args.buf
				pcall(vim.treesitter.start, bufnr)
				vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})

		-- ============ TEXTOBJECTS ============
		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
			},
			move = {
				set_jumps = true,
			},
		})

		local select = require("nvim-treesitter-textobjects.select")
		local move = require("nvim-treesitter-textobjects.move")

		local select_map = {
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
		}

		for key, query in pairs(select_map) do
			vim.keymap.set({ "x", "o" }, key, function()
				select.select_textobject(query, "textobjects")
			end)
		end

		local next_start = {
			["]m"] = "@function.outer",
			["]c"] = "@class.outer",
			["]p"] = "@parameter.outer",
		}
		local prev_start = {
			["[m"] = "@function.outer",
			["[c"] = "@class.outer",
			["[p"] = "@parameter.outer",
		}

		for key, query in pairs(next_start) do
			vim.keymap.set({ "n", "x", "o" }, key, function()
				move.goto_next_start(query, "textobjects")
			end)
		end
		for key, query in pairs(prev_start) do
			vim.keymap.set({ "n", "x", "o" }, key, function()
				move.goto_previous_start(query, "textobjects")
			end)
		end
	end,
}
