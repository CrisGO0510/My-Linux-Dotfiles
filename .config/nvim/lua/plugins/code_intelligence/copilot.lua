return {
	{
		"zbirenbaum/copilot.lua",
		event = "VimEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
					keymap = {
						accept = false,      -- Deshabilitar - manejado en keymaps.lua
						accept_word = false, -- Deshabilitar - manejado en keymaps.lua  
						accept_line = false, -- Deshabilitar - manejado en keymaps.lua
						next = false,        -- Deshabilitar - manejado en keymaps.lua
						prev = false,        -- Deshabilitar - manejado en keymaps.lua
						dismiss = false,     -- Deshabilitar - manejado en keymaps.lua
					},
				},
				panel = {
					enabled = true,
					auto_refresh = true,
				},
			})
		end,
	},
}
