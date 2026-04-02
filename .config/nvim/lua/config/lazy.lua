local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ import = "plugins.core" },
		{ import = "plugins.ui" },
		{ import = "plugins.editing" },
		{ import = "plugins.languages" },
		{ import = "plugins.code_intelligence" },
		{ import = "plugins.navigation" },
		{ import = "plugins.colorschemes" },

		-- ══════════════════════════════════════════════════════
		-- Stacks de desarrollo: comentar/descomentar según la necesidad
		-- ══════════════════════════════════════════════════════
		-- { import = "plugins.stacks.angular" },
		{ import = "plugins.stacks.vue" },
		-- { import = "plugins.stacks.typescript" },
		-- { import = "plugins.stacks.csharp" },
	},
	defaults = { lazy = false },
	install = { colorscheme = { "catppuccin" } },
	checker = { enabled = true },
})
