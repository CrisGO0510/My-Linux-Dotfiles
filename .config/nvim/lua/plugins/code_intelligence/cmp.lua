return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true,
			})
			-- Integración con cmp: al confirmar un completion de función,
			-- inserta paréntesis automáticamente.
			local ok, cmp = pcall(require, "cmp")
			if ok then
				local cmp_autopairs = require("nvim-autopairs.completion.cmp")
				cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
			end
		end,
	},

	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		opts = function(_, opts)
			local cmp = require("cmp")
			local ls = require("luasnip")

			opts.completion = { autocomplete = { cmp.TriggerEvent.TextChanged } }

			-- Mappings se definen en config/keymaps.lua
			opts.mapping = nil

			opts.sources = cmp.config.sources({
				{ name = "nvim_lsp", priority = 750 },
				{ name = "luasnip", priority = 500 },
				{ name = "buffer", priority = 250 },
				{ name = "path", priority = 250 },
			})

			opts.snippet = {
				expand = function(args)
					ls.lsp_expand(args.body)
				end,
			}

			opts.formatting = {
				format = function(entry, vim_item)
					local icons = {
						nvim_lsp = "",
						buffer = "﬘",
						path = "",
						luasnip = "",
					}
					vim_item.kind = string.format("%s %s", icons[entry.source.name] or "", vim_item.kind)
					return vim_item
				end,
			}

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
