return {
	-- =====================================================================
	-- Vue.js 3 Complete LSP Configuration
	-- - Volar (Vue Language Server) for .vue files
	-- - HTML Language Server for separated component templates
	-- - Support for separated component structure (.vue + .html + .ts + .scss)
	-- 
	-- Note: Component navigation keymaps are now handled by the centralized
	-- Component Navigation System in config/keymaps.lua
	-- =====================================================================

	-- Volar (Vue Official Language Server) optimizado para Vue 3 + TypeScript moderno
	-- Con navegación de componentes y Take Over Mode completo
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason.nvim" },
		ft = { "vue", "html" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- =====================================================================
			-- UTILITY FUNCTIONS - Shared by both Volar and HTML LSP
			-- =====================================================================

			-- Function to detect Vue projects by configuration files
			local function is_vue_project(bufnr)
				local vue_markers = {
					'vue.config.js', 'vue.config.ts',
					'vite.config.js', 'vite.config.ts',
					'nuxt.config.js', 'nuxt.config.ts',
				}
				local root = vim.fs.root(bufnr, vue_markers)
				return root ~= nil
			end

			-- Check if HTML file is part of a Vue component (has corresponding .vue/.ts)
			local function is_vue_component_html(filepath)
				if not filepath or not filepath:match("%.html$") then
					return false
				end

				-- Extract base name (remove .html extension)
				local base_path = filepath:gsub("%.html$", "")
				local dir = vim.fn.fnamemodify(base_path, ":h")
				local name = vim.fn.fnamemodify(base_path, ":t")

				-- Check for corresponding .vue and .ts files
				local vue_file = dir .. "/" .. name .. ".vue"
				local ts_file = dir .. "/" .. name .. ".ts"

				local vue_exists = vim.fn.filereadable(vue_file) == 1
				local ts_exists = vim.fn.filereadable(ts_file) == 1

				return vue_exists or ts_exists
			end

			-- =====================================================================
			-- VOLAR (Vue Language Server) CONFIGURATION
			-- =====================================================================

			-- Streamlined on_attach for Vue files - keymaps handled centrally
			local vue_on_attach = function(client, bufnr)
				-- Enable completion triggered by <c-x><c-o>
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

				-- Vue/Volar specific configurations
				if client.name == "vue_ls" then
					-- Disable formatting if using prettier via conform.nvim
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false
					
					-- Enable enhanced capabilities para navegación de componentes
					client.server_capabilities.definitionProvider = true
					client.server_capabilities.referencesProvider = true
					client.server_capabilities.hoverProvider = true
					client.server_capabilities.completionProvider = {
						triggerCharacters = { ".", ":", "<", '"', "'", "/", "@", "*" },
						resolveProvider = true,
					}
					
					-- Standard LSP keybindings (non-component specific)
					local opts = { buffer = bufnr, silent = true }
					
					-- Standard LSP navigation bindings
					vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
					vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts) 
					vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
					vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
					
					-- Vue component specific LSP commands
					vim.keymap.set('n', '<leader>vr', function()
						vim.lsp.buf.references()
					end, { buffer = bufnr, desc = "Find Vue Component References" })
				end
			end

			-- Configurar Volar con Take Over Mode completo para Vue 3 + TypeScript
			vim.lsp.config.vue_ls = {
				-- Usar el binary correcto de Mason
				cmd = { vim.fn.stdpath("data") .. "/mason/bin/vue-language-server", "--stdio" },
				
				-- Archivos Vue (Take Over Mode: Volar maneja TypeScript internally)
				filetypes = { "vue" },
				
				-- Detección de proyecto Vue específica
				autostart = is_vue_project,
				root_markers = {
					'vue.config.js', 'vue.config.ts',
					'vite.config.js', 'vite.config.ts', 
					'nuxt.config.js', 'nuxt.config.ts',
					'package.json'
				},
				
				capabilities = capabilities,
				on_attach = vue_on_attach,
				
				-- Configuración optimizada para Vue 3 + TypeScript + Component Navigation
				settings = {
					vue = {
						-- Enable component auto-imports y navegación
						server = {
							vitePress = { supportMdFile = true },
							maxFileSize = 20971520, -- 20MB max
							
							-- Configuración específica para navegación de componentes
							completion = {
								autoImportComponentIndex = true,
								autoImportVueComponent = true,
							},
						},
						
						-- Habilitar análisis completo de componentes
						analysis = {
							templateBodyOnlyForInlayHints = false,
						},
						
						-- Component resolution optimizada para paths relativos
						resolve = {
							-- Support para ./components/, ../components/, etc.
							alias = {
								["@"] = "src",  -- Si usas @/ como alias
							},
						},
					},
					
					-- TypeScript integration completa (Take Over Mode)
					typescript = {
						-- Configuración específica para Vue + TypeScript
						preferences = {
							-- Optimizado para auto-imports de componentes
							includePackageJsonAutoImports = "auto",
							useAliasesForRenames = false,
							quotePreference = "double",
						},
						
						-- Enable all inlay hints para mejor desarrollo
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
						
						-- Optimización para navegación de componentes
						suggest = {
							autoImports = true,
							completeFunctionCalls = true,
							names = true,
							paths = true,
							includeAutomaticOptionalChainCompletions = true,
						},
					},
					
					-- Volar-specific features para componentes Vue
					volar = {
						-- Enable component intelligence
						completion = {
							includeCompletionsForModuleExports = true,
							includeAutomaticOptionalChainCompletions = true,
						},
						
						-- Template analysis para <Component/> navigation
						template = {
							-- Enable component tag navigation
							compilerOptions = {
								experimentalCompatMode = 2,
							},
						},
					},
				},
				
				-- Inicialización específica sin warning de TypeScript LSP
				on_init = function(client, initialize_result)
					vim.defer_fn(function()
						if client and client.server_capabilities then
							vim.notify(
								"🚀 Volar activado - Vue 3 + TypeScript + Component Navigation ✅", 
								vim.log.levels.INFO
							)
						end
					end, 1000)
				end,
			}

			-- =====================================================================
			-- HTML LANGUAGE SERVER CONFIGURATION
			-- Enhanced support for separated Vue component templates (.html files)
			-- =====================================================================

			-- Streamlined HTML on_attach - keymaps handled by central system
			local html_on_attach = function(client, bufnr)
				-- Enable completion
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

				-- Get current file path
				local filepath = vim.api.nvim_buf_get_name(bufnr)

				-- Only apply Vue enhancements if this is a Vue component HTML
				if is_vue_component_html(filepath) and client.name == "html" then
					-- Enhanced capabilities for Vue templates
					client.server_capabilities.definitionProvider = true
					client.server_capabilities.referencesProvider = true
					client.server_capabilities.hoverProvider = true
					client.server_capabilities.completionProvider = {
						triggerCharacters = { ".", ":", "<", '"', "'", "/", "@", "*", "{", "}", "(", ")" },
						resolveProvider = true,
					}
				end
			end

			-- Configure HTML language server with Vue intelligence
			vim.lsp.config.html = {
				cmd = { vim.fn.stdpath("data") .. "/mason/bin/vscode-html-language-server", "--stdio" },
				filetypes = { "html" },
				
				-- Only autostart for Vue component HTML files
				autostart = function(bufnr)
					local filepath = vim.api.nvim_buf_get_name(bufnr)
					return is_vue_project(bufnr) and is_vue_component_html(filepath)
				end,
				
				root_markers = {
					'vue.config.js', 'vue.config.ts',
					'vite.config.js', 'vite.config.ts', 
					'package.json'
				},
				
				capabilities = capabilities,
				on_attach = html_on_attach,
				
				-- Enhanced HTML settings with Vue template support
				settings = {
					html = {
						-- Enable Vue-specific features
						format = {
							enable = true,
							wrapLineLength = 120,
							unformatted = "",
							contentUnformatted = "pre,code,textarea",
							indentInnerHtml = true,
							preserveNewLines = true,
							indentHandlebars = false,
							endWithNewline = false,
							extraLiners = "head, body, /html",
							wrapAttributes = "auto"
						},
						suggest = {
							html5 = true,
						},
						-- Vue template specific settings
						customData = {
							-- Enable Vue directives and component recognition
							{
								version = 1.1,
								tags = {},
								attributes = {
									-- Vue directives
									{ name = "v-if" },
									{ name = "v-else" },
									{ name = "v-else-if" },
									{ name = "v-for" },
									{ name = "v-show" },
									{ name = "v-model" },
									{ name = "v-on" },
									{ name = "@click" },
									{ name = "@input" },
									{ name = "@change" },
									{ name = ":class" },
									{ name = ":style" },
									{ name = ":src" },
									{ name = ":href" },
									{ name = "ref" },
									{ name = "key" },
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

				-- Initialize with Vue component context
				on_init = function(client, initialize_result)
					vim.defer_fn(function()
						if client and client.server_capabilities then
							local bufnr = vim.api.nvim_get_current_buf()
							local filepath = vim.api.nvim_buf_get_name(bufnr)
							if is_vue_component_html(filepath) then
								vim.notify(
									"🎨 HTML LSP activado para componente Vue ✅", 
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