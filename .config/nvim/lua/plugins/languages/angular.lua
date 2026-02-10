return {
	-- =====================================================================
	-- Angular Language Server Configuration
	-- Integrates with the Universal Component Navigation System
	-- =====================================================================
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason.nvim" },
		ft = { "typescript", "html" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- =====================================================================
			-- ANGULAR PROJECT DETECTION
			-- =====================================================================

			-- Function to detect Angular projects
			local function is_angular_project(bufnr)
				local angular_markers = {
					'angular.json',
					'nx.json',
					'project.json'
				}
				local root = vim.fs.root(bufnr, angular_markers)
				return root ~= nil
			end

			-- Check if file is an Angular component file
			local function is_angular_component_file(filepath)
				if not filepath then return false end
				
				-- Angular component file patterns
				return filepath:match("%.component%.ts$") or 
					   filepath:match("%.component%.html$") or
					   filepath:match("%.component%.scss$") or
					   filepath:match("%.component%.css$") or
					   filepath:match("%.component%.spec%.ts$")
			end

			-- =====================================================================
			-- ANGULAR LSP CONFIGURATION
			-- =====================================================================

			-- Angular-aware on_attach
			local angular_on_attach = function(client, bufnr)
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

				if client.name == "angularls" then
					-- Disable formatting (use Prettier via conform.nvim)
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false
					
					-- Enhanced capabilities for Angular components
					client.server_capabilities.definitionProvider = true
					client.server_capabilities.referencesProvider = true
					client.server_capabilities.hoverProvider = true
					client.server_capabilities.completionProvider = {
						triggerCharacters = { ".", ":", "<", '"', "'", "/", "@", "*", "(", ")", "[", "]" },
						resolveProvider = true,
					}

					-- Standard LSP keybindings
					local opts = { buffer = bufnr, silent = true }
					vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
					vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
					vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
					vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
					
					-- Angular specific LSP commands
					vim.keymap.set('n', '<leader>ar', function()
						vim.lsp.buf.references()
					end, { buffer = bufnr, desc = "Find Angular Component References" })
				end
			end

			-- Configure Angular Language Server
			vim.lsp.config.angularls = {
				cmd = { vim.fn.stdpath("data") .. "/mason/bin/ngserver", "--stdio", "--tsProbeLocations", vim.fn.stdpath("data") .. "/mason/packages/angular-language-server/node_modules", "--ngProbeLocations", vim.fn.stdpath("data") .. "/mason/packages/angular-language-server/node_modules" },
				
				filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
				
				-- Only autostart in Angular projects
				autostart = is_angular_project,
				
				root_markers = { "angular.json", "nx.json", "project.json", "package.json" },
				
				capabilities = capabilities,
				on_attach = angular_on_attach,
				
				-- Angular-specific settings
				settings = {
					angular = {
						-- Enable advanced Angular features
						enable = true,
						suggest = {
							autoImports = true,
						},
						-- Template intelligence
						template = {
							strictTemplates = true,
							typeChecking = true,
						},
						-- Component analysis
						component = {
							strictMode = true,
						}
					}
				},
				
				on_init = function(client, initialize_result)
					vim.defer_fn(function()
						if client and client.server_capabilities then
							vim.notify(
								"⚡ Angular LSP activado - TypeScript + Templates ✅", 
								vim.log.levels.INFO
							)
						end
					end, 1000)
				end,
			}

			-- =====================================================================
			-- ANGULAR HTML TEMPLATE SUPPORT
			-- =====================================================================

			-- HTML LSP for Angular templates
			local angular_html_on_attach = function(client, bufnr)
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

				local filepath = vim.api.nvim_buf_get_name(bufnr)

				-- Only enhance if this is an Angular component template
				if is_angular_component_file(filepath) and client.name == "html" then
					client.server_capabilities.definitionProvider = true
					client.server_capabilities.referencesProvider = true
					client.server_capabilities.hoverProvider = true
					client.server_capabilities.completionProvider = {
						triggerCharacters = { ".", ":", "<", '"', "'", "/", "@", "*", "{", "}", "(", ")", "[", "]" },
						resolveProvider = true,
					}
				end
			end

			-- Configure HTML LSP for Angular templates (when Angular LSP isn't available)
			vim.lsp.config.html_angular = {
				cmd = { vim.fn.stdpath("data") .. "/mason/bin/vscode-html-language-server", "--stdio" },
				filetypes = { "html" },
				
				-- Only for Angular component HTML files when Angular LSP isn't running
				autostart = function(bufnr)
					local filepath = vim.api.nvim_buf_get_name(bufnr)
					return is_angular_project(bufnr) and 
						   filepath:match("%.component%.html$") and
						   #vim.lsp.get_clients({ bufnr = bufnr, name = "angularls" }) == 0
				end,
				
				root_markers = { "angular.json", "nx.json", "package.json" },
				
				capabilities = capabilities,
				on_attach = angular_html_on_attach,
				
				-- Angular-enhanced HTML settings
				settings = {
					html = {
						format = {
							enable = true,
							wrapLineLength = 120,
							indentInnerHtml = true,
							wrapAttributes = "auto"
						},
						suggest = {
							html5 = true,
						},
						-- Angular template directives
						customData = {
							{
								version = 1.1,
								tags = {},
								attributes = {
									-- Angular directives
									{ name = "@if" },
									{ name = "@for" },
									{ name = "@switch" },
									{ name = "(click)" },
									{ name = "(input)" },
									{ name = "(change)" },
									{ name = "(submit)" },
									{ name = "[ngClass]" },
									{ name = "[ngStyle]" },
									{ name = "[src]" },
									{ name = "[href]" },
									{ name = "[(ngModel)]" },
									{ name = "#templateVar" },
								}
							}
						},
						completion = {
							attributeDefaultValue = "doublequotes",
						},
						validate = {
							scripts = true,
							styles = true,
						},
					}
				},

				on_init = function(client, initialize_result)
					vim.defer_fn(function()
						if client and client.server_capabilities then
							local bufnr = vim.api.nvim_get_current_buf()
							local filepath = vim.api.nvim_buf_get_name(bufnr)
							if filepath:match("%.component%.html$") then
								vim.notify(
									"🎨 HTML LSP activado para template Angular ✅", 
									vim.log.levels.INFO
								)
							end
						end
					end, 1000)
				end,
			}
		end,
	},
}
