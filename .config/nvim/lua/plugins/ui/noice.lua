return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	opts = {
		lsp = {

			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
		},

		routes = {
			{
				filter = {
					event = "msg_show",
					any = {
						{ find = "written" },
						{ find = "deprecated" },
					},
				},
				opts = { skip = true },
			},
		},

		presets = {
			bottom_search = true,
			command_palette = true,
			long_message_to_split = true,
			inc_rename = false,
			lsp_doc_border = true,
		},
	},
	config = function(_, opts)
		require("notify").setup({
			background_colour = "#000000",
			timeout = 3000,
			render = "compact",
		})

		require("noice").setup(opts)
	end,
}

