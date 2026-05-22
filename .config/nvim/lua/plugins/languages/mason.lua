-- Mason + lua_ls (LSP siempre activo para editar este config).
-- El resto de LSPs viven en plugins/stacks/<lang>.lua y se activan
-- descomentando su línea en config/lazy.lua.
--
-- automatic_enable = false: mason-lspconfig NO arranca servers solo;
-- cada stack llama explícitamente a vim.lsp.enable("<name>").

return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
	},
	build = ":MasonUpdate",
	config = function()
		require("mason").setup()

		require("mason-lspconfig").setup({
			ensure_installed = { "lua_ls" },
			automatic_enable = false,
		})

		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		vim.lsp.config.lua_ls = {
			cmd = { "lua-language-server" },
			filetypes = { "lua" },
			root_markers = {
				".luarc.json", ".luarc.jsonc", ".luacheckrc",
				".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git",
			},
			capabilities = capabilities,
			on_attach = function(_, bufnr)
				vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
			end,
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					diagnostics = { globals = { "vim" } },
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false,
					},
					telemetry = { enable = false },
				},
			},
		}

		vim.lsp.enable("lua_ls")
	end,
}
