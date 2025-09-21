return {
	{
		"zbirenbaum/copilot.lua",
		event = "VimEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
				},
				panel = {
					enabled = true,
					auto_refresh = true,
				},
			})
		end,
	},
}
