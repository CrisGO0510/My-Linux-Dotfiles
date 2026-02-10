return {
	-- TypeScript LSP configuration using new vim.lsp.config API
	-- Note: LSP server installation is handled in mason.lua
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason.nvim" }, -- Ensure Mason loads first
		ft = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Common on_attach function for TypeScript
			local on_attach = function(client, bufnr)
				-- Enable completion triggered by <c-x><c-o>
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

				-- TypeScript specific configurations
				if client.name == "ts_ls" then
					-- Disable formatting if you prefer to use prettier via conform.nvim
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false
				end
			end

			-- Configure TypeScript Language Server with Vue project exclusion
			vim.lsp.config.ts_ls = {
				cmd = { "typescript-language-server", "--stdio" },
				filetypes = {
					"javascript",
					"javascriptreact", 
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
				},
				-- Conditional autostart: avoid conflict with Vue projects using Take Over Mode
				autostart = function(bufnr)
					-- Check if this is a Vue project
					local vue_markers = {
						'vue.config.js', 'vue.config.ts',
						'vite.config.js', 'vite.config.ts',
						'nuxt.config.js', 'nuxt.config.ts',
					}
					local vue_root = vim.fs.root(bufnr, vue_markers)
					
					-- If Vue project detected, let Volar handle TypeScript (Take Over Mode)
					if vue_root then
						return false
					end
					
					-- Start in non-Vue projects
					return true
				end,
				root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					on_attach(client, bufnr)
					
					-- Notify when TypeScript LSP starts in non-Vue projects
					if client.name == "ts_ls" then
						vim.defer_fn(function()
							vim.notify(
								"📘 TypeScript LSP activo (proyecto no-Vue) ✅", 
								vim.log.levels.INFO
							)
						end, 500)
					end
				end,
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
					javascript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
				},
			}
		end,
	},
}
