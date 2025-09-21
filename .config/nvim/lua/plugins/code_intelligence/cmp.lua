return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = { -- (corrijo "dependences" -> "dependencies")
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-git",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"windwp/nvim-autopairs",
		},
		opts = function(_, opts)
			local cmp = require("cmp")
			local ls = require("luasnip")

			-- Autocompletado automático ACTIVADO al inicio
			cmp.setup({
				completion = { autocomplete = { cmp.TriggerEvent.TextChanged } },
			})

			-- (sin mappings aquí)
			opts.mapping = nil

			-- Fuentes
			opts.sources = cmp.config.sources({
				{ name = "nvim_lsp", priority = 750 },
				{ name = "buffer", priority = 500 },
				{ name = "path", priority = 250 },
				{ name = "luasnip", priority = 300 },
				{ name = "emmet_nvim" },
			})

			-- Snippets
			opts.snippet = {
				expand = function(args)
					ls.lsp_expand(args.body)
				end,
			}

			-- Formato con íconos
			opts.formatting = {
				format = function(entry, vim_item)
					local icons = {
						nvim_lsp = "",
						buffer = "﬘",
						path = "",
						luasnip = "",
						emmet_nvim = "",
					}
					vim_item.kind = string.format("%s %s", icons[entry.source.name] or "", vim_item.kind)
					return vim_item
				end,
			}

			-- Ventanas
			opts.window = {
				completion = {
					border = {
						{ "󱐋", "WarningMsg" },
						{ "─", "Comment" },
						{ "╮", "Comment" },
						{ "│", "Comment" },
						{ "╯", "Comment" },
						{ "─", "Comment" },
						{ "╰", "Comment" },
						{ "│", "Comment" },
					},
					scrollbar = false,
					winblend = 0,
				},
				documentation = {
					border = {
						{ "󰙎", "DiagnosticHint" },
						{ "─", "Comment" },
						{ "╮", "Comment" },
						{ "│", "Comment" },
						{ "╯", "Comment" },
						{ "─", "Comment" },
						{ "╰", "Comment" },
						{ "│", "Comment" },
					},
					scrollbar = false,
					winblend = 0,
				},
			}
		end,
	},
}
