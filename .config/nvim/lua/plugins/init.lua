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

-- Load plugins

require("lazy").setup({
	-- Core
	require("plugins.core.plenary"),
	require("plugins.core.nui"),
	require("plugins.core.snacks"),

	-- Languages
	require("plugins.languages.conform"),
	require("plugins.languages.mason"),
	require("plugins.languages.treesitter"),
	require("plugins.languages.rust"),

	-- code_intelligence
	require("plugins.code_intelligence.auto-safe"),
	require("plugins.code_intelligence.avante"),
	require("plugins.code_intelligence.cmp"),
	require("plugins.code_intelligence.friendly-snippets"),
	require("plugins.code_intelligence.copilot"),
	require("plugins.code_intelligence.nvim-ts-autotag"),

	-- colorschemes
	require("plugins.colorschemes.catppuccin"),
	require("plugins.colorschemes.space-vim-dark"),
	require("plugins.colorschemes.tokyonight"),

	-- Editing
	require("plugins.editing.comments"),
	require("plugins.editing.flash"),
	require("plugins.editing.gitsigns"),
	require("plugins.editing.mini-ai"),
	require("plugins.editing.mini-icons"),
	require("plugins.editing.mini-pairs"),

	-- Navigation
	require("plugins.navigation.neo-tree"),
	require("plugins.navigation.telescope"),

	-- UI
	require("plugins.ui.fidget"),
	require("plugins.ui.lualine"),
	require("plugins.ui.noice"),
	require("plugins.ui.nvim-web-devicons"),
	require("plugins.ui.trouble"),
	require("plugins.ui.which-key"),
	require("plugins.ui.markdown-preview"),
	require("plugins.ui.code-shot"),
})
