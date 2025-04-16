return {
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			-- Asegúrate de que el plugin se haya cargado antes de ejecutar la función de instalación
			vim.fn["mkdp#util#install"]()
		end,
	},
}
