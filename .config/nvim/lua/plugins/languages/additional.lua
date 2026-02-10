return {
	-- Additional LSP configurations using new vim.lsp.config API
	-- Note: LSP server installation is handled in mason.lua
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require('cmp_nvim_lsp').default_capabilities()

			-- Common on_attach function
			local on_attach = function(client, bufnr)
				vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
			end

			-- Angular Language Server con detección de proyecto Angular específica
			vim.lsp.config.angularls = {
				cmd = { 'ngserver', '--stdio', '--tsProbeLocations', 'node_modules/@angular/language-server', '--ngProbeLocations', 'node_modules/@angular/language-service' },
				filetypes = { 'typescript', 'html', 'typescriptreact', 'typescript.tsx' },
				-- Solo activar en proyectos Angular detectados por angular.json
				root_markers = { 'angular.json' },
				-- Función de autostart condicional: solo en proyectos Angular
				autostart = function(bufnr)
					local angular_root = vim.fs.root(bufnr, { 'angular.json' })
					return angular_root ~= nil
				end,
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					on_attach(client, bufnr)
					-- Notificación cuando Angular LSP se activa
					if client.name == "angularls" then
						vim.defer_fn(function()
							vim.notify(
								"Angular LSP activado en proyecto Angular ✅", 
								vim.log.levels.INFO
							)
						end, 500)
					end
				end,
			}

			-- ESLint Language Server
			vim.lsp.config.eslint = {
				cmd = { 'vscode-eslint-language-server', '--stdio' },
				filetypes = {
					'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx',
					'vue', 'svelte', 'astro', 'html'
				},
				root_markers = { '.eslintrc', '.eslintrc.json', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.yaml', '.eslintrc.yml', 'package.json', '.git' },
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					on_attach(client, bufnr)
					
					-- Auto-fix on save
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							vim.cmd("EslintFixAll")
						end,
					})
				end,
				settings = {
					codeAction = {
						disableRuleComment = {
							enable = true,
							location = "separateLine"
						},
						showDocumentation = {
							enable = true
						}
					},
					codeActionOnSave = {
						enable = false, -- Handled by autocmd above
						mode = "all"
					},
					experimental = {
						useFlatConfig = false
					},
					format = false, -- Use prettier for formatting
					nodePath = "",
					onIgnoredFiles = "off",
					problems = {
						shortenToSingleLine = false
					},
					quiet = false,
					rulesCustomizations = {},
					run = "onType",
					useESLintClass = false,
					validate = "on",
					workingDirectory = {
						mode = "location"
					}
				},
			}

			-- JSON Language Server
			vim.lsp.config.jsonls = {
				cmd = { 'vscode-json-language-server', '--stdio' },
				filetypes = { 'json', 'jsonc' },
				root_markers = { '.git', 'package.json' },
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					json = {
						schemas = require('schemastore').json.schemas(),
						validate = { enable = true },
					},
				},
			}
		end,
	},
	
	-- Schema store for JSON validation
	{
		"b0o/schemastore.nvim",
		lazy = true,
	},
}