return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
	},
	build = ":MasonUpdate",
	config = function()
		require("mason").setup()

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

		-- Volar 2+/3 Hybrid Mode: ts_ls atiende .vue cargando @vue/typescript-plugin
		local vue_ts_plugin = vim.fn.stdpath("data")
			.. "/mason/packages/vue-language-server/node_modules/@vue/typescript-plugin"

		-- Forzar capabilities estáticas para que ts_ls atienda .vue: si dejamos
		-- dynamicRegistration en true, el server registra selectors que excluyen
		-- "vue" y supports_method() devuelve false aunque definitionProvider sea true.
		local ts_capabilities = vim.tbl_deep_extend("force", capabilities, {
			textDocument = {
				definition = { dynamicRegistration = false },
				references = { dynamicRegistration = false },
				hover = { dynamicRegistration = false },
				implementation = { dynamicRegistration = false },
				typeDefinition = { dynamicRegistration = false },
				declaration = { dynamicRegistration = false },
				completion = { dynamicRegistration = false },
				rename = { dynamicRegistration = false },
				signatureHelp = { dynamicRegistration = false },
			},
		})

		vim.lsp.config.ts_ls = {
			cmd = { "typescript-language-server", "--stdio" },
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
				"vue",
			},
			root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
			capabilities = ts_capabilities,
			init_options = {
				plugins = {
					{
						name = "@vue/typescript-plugin",
						location = vue_ts_plugin,
						languages = { "vue" },
					},
				},
			},
			on_attach = function(client, bufnr)
				on_attach(client, bufnr)
				if client.name == "ts_ls" then
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false
				end
			end,
			settings = {
				typescript = {
					inlayHints = {
						includeInlayParameterNameHints = "none",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = false,
						includeInlayVariableTypeHints = false,
						includeInlayPropertyDeclarationTypeHints = false,
						includeInlayFunctionLikeReturnTypeHints = false,
						includeInlayEnumMemberValueHints = false,
					},
				},
				javascript = {
					inlayHints = {
						includeInlayParameterNameHints = "none",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = false,
						includeInlayVariableTypeHints = false,
						includeInlayPropertyDeclarationTypeHints = false,
						includeInlayFunctionLikeReturnTypeHints = false,
						includeInlayEnumMemberValueHints = false,
					},
				},
			},
		}

		-- Setup mason-lspconfig DESPUÉS de definir vim.lsp.config.* para que el
		-- auto-enable use nuestros configs en vez de los defaults de nvim-lspconfig.
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
	end,
}
