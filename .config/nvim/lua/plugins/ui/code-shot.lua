return {
	"SergioRibera/codeshot.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("codeshot").setup({
			output = "home/Cris/Pictures/codeshot/CodeShot_${date}-${month}-${year}_${time}.png",
			author = "CrisGO",
		})
	end,
}
