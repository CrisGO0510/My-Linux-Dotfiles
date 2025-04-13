return {
	"williamboman/mason.nvim",
	dependencies = { "williamboman/mason-lspconfig.nvim", "neovim/nvim-lspconfig" },
	build = ":MasonUpdate",
	config = function()
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = { "lua_ls", "ts_ls", "rust_analyzer", "jdtls" },
			automatic_installation = true, -- Instala automáticamente los LSPs requeridos
		})

		require("mason-lspconfig").setup_handlers({
			function(server_name) -- Esta función se ejecuta para cada servidor instalado
				require("lspconfig")[server_name].setup({})
			end,
		})
	end,
}
