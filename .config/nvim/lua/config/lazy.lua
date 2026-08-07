local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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
		{ import = "plugins.notes" },
		{ import = "plugins.colorschemes" },

		-- ══════════════════════════════════════════════════════
		-- Stacks de desarrollo: comentar/descomentar según la necesidad
		-- Cada stack es dueño total de su LSP. Comentar = LSP no se carga.
		-- ══════════════════════════════════════════════════════
		-- { import = "plugins.stacks.angular" },
		{ import = "plugins.stacks.vue" },
		-- { import = "plugins.stacks.typescript" },
		-- { import = "plugins.stacks.rust" },
	},
	-- Por defecto TODO es lazy: cada spec declara su propio trigger
	-- (event/cmd/ft) o un lazy=false explícito si hace falta al arrancar.
	defaults = { lazy = true },
	install = { colorscheme = { "tokyonight" } },
	checker = { enabled = true, notify = false },
})
