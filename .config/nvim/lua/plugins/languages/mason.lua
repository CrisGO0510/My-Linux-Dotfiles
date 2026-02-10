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
			ensure_installed = {
				"lua_ls",
				"ts_ls", -- TypeScript Language Server
				"vue_ls", -- Volar (Vue Language Server oficial) 
				"html", -- HTML Language Server (para templates separados)
				"angularls", -- Angular Language Server
				"eslint", -- ESLint LSP
				"jsonls", -- JSON Language Server
			},
			automatic_installation = true,
		})

		-- Basic LSP capabilities (for completion support)
		local capabilities = require('cmp_nvim_lsp').default_capabilities()

		-- Common on_attach function for all LSP servers
		local on_attach = function(client, bufnr)
			-- Enable completion triggered by <c-x><c-o>
			vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
		end

		-- Configure Lua LSP with enhanced settings using new API
		vim.lsp.config.lua_ls = {
			cmd = { 'lua-language-server' },
			filetypes = { 'lua' },
			root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					runtime = {
						version = 'LuaJIT',
					},
					diagnostics = {
						globals = { 'vim' },
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false,
					},
					telemetry = {
						enable = false,
					},
				},
			},
		}
	end,
}
