return {
	-- =====================================================================
	-- Vue.js 3 Complete LSP Configuration
	-- - Volar (Vue Language Server) for .vue files
	-- - HTML Language Server for separated component templates
	-- - Support for separated component structure (.vue + .html + .ts + .scss)
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

			-- Find all related files for a Vue component
			local function get_vue_component_files(base_filepath)
				local base_path = base_filepath:gsub("%.vue$", ""):gsub("%.html$", ""):gsub("%.ts$", ""):gsub("%.scss$", "")
				local dir = vim.fn.fnamemodify(base_path, ":h")
				local name = vim.fn.fnamemodify(base_path, ":t")

				return {
					html = dir .. "/" .. name .. ".html",
					vue = dir .. "/" .. name .. ".vue",
					ts = dir .. "/" .. name .. ".ts",
					scss = dir .. "/" .. name .. ".scss",
					css = dir .. "/" .. name .. ".css",
				}
			end

			-- =====================================================================
			-- VOLAR (Vue Language Server) CONFIGURATION
			-- =====================================================================

			-- Enhanced on_attach for Vue files with component navigation
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
					
					-- Vue-specific keybindings para componentes
					local opts = { buffer = bufnr, silent = true }
					
					-- Component navigation specific bindings
					vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
					vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
					vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
					vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
					
					-- Vue component specific commands
					vim.keymap.set('n', '<leader>vr', function()
						vim.lsp.buf.references()
					end, { buffer = bufnr, desc = "Find Vue Component References" })
					
					-- Navigation to related files for separated components
					local current_file = vim.api.nvim_buf_get_name(bufnr)
					if current_file:match("%.vue$") then
						local component_files = get_vue_component_files(current_file)
						
						-- Navigate to HTML template
						vim.keymap.set('n', '<leader>vh', function()
							if vim.fn.filereadable(component_files.html) == 1 then
								vim.cmd("edit " .. component_files.html)
							else
								vim.notify("No se encontró template HTML", vim.log.levels.WARN)
							end
						end, { buffer = bufnr, desc = "Go to HTML Template" })
						
						-- Navigate to TypeScript logic
						vim.keymap.set('n', '<leader>vt', function()
							if vim.fn.filereadable(component_files.ts) == 1 then
								vim.cmd("edit " .. component_files.ts)
							else
								vim.notify("No se encontró archivo TypeScript", vim.log.levels.WARN)
							end
						end, { buffer = bufnr, desc = "Go to TypeScript Logic" })
						
						-- Navigate to styles
						vim.keymap.set('n', '<leader>vs', function()
							if vim.fn.filereadable(component_files.scss) == 1 then
								vim.cmd("edit " .. component_files.scss)
							elseif vim.fn.filereadable(component_files.css) == 1 then
								vim.cmd("edit " .. component_files.css)
							else
								vim.notify("No se encontraron archivos de estilos", vim.log.levels.WARN)
							end
						end, { buffer = bufnr, desc = "Go to Styles" })
					end
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

			-- Enhanced on_attach for HTML files in Vue projects
			local html_on_attach = function(client, bufnr)
				-- Enable completion
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

				-- Get current file path
				local filepath = vim.api.nvim_buf_get_name(bufnr)

				-- Only apply Vue enhancements if this is a Vue component HTML
				if is_vue_component_html(filepath) then
					local component_files = get_vue_component_files(filepath)

					-- Vue HTML specific configurations
					if client.name == "html" then
						-- Enhanced capabilities for Vue templates
						client.server_capabilities.definitionProvider = true
						client.server_capabilities.referencesProvider = true
						client.server_capabilities.hoverProvider = true
						client.server_capabilities.completionProvider = {
							triggerCharacters = { ".", ":", "<", '"', "'", "/", "@", "*", "{", "}", "(", ")" },
							resolveProvider = true,
						}

						-- Vue component specific keybindings
						local opts = { buffer = bufnr, silent = true }

						-- Override gd for Vue component navigation
						vim.keymap.set('n', 'gd', function()
							-- Try to navigate to the TypeScript component file
							if vim.fn.filereadable(component_files.ts) == 1 then
								vim.cmd("edit " .. component_files.ts)
								-- Try to find the component definition
								vim.defer_fn(function()
									vim.fn.search("export default", "w")
								end, 100)
							elseif vim.fn.filereadable(component_files.vue) == 1 then
								vim.cmd("edit " .. component_files.vue)
							else
								-- Fallback to LSP definition
								vim.lsp.buf.definition()
							end
						end, vim.tbl_extend("force", opts, { desc = "Go to Vue Component Definition" }))

						-- Navigate to Vue file
						vim.keymap.set('n', '<leader>vv', function()
							if vim.fn.filereadable(component_files.vue) == 1 then
								vim.cmd("edit " .. component_files.vue)
							else
								vim.notify("No se encontró archivo .vue correspondiente", vim.log.levels.WARN)
							end
						end, vim.tbl_extend("force", opts, { desc = "Go to Vue File" }))

						-- Navigate to TypeScript file
						vim.keymap.set('n', '<leader>vt', function()
							if vim.fn.filereadable(component_files.ts) == 1 then
								vim.cmd("edit " .. component_files.ts)
							else
								vim.notify("No se encontró archivo .ts correspondiente", vim.log.levels.WARN)
							end
						end, vim.tbl_extend("force", opts, { desc = "Go to TypeScript File" }))

						-- Navigate to styles
						vim.keymap.set('n', '<leader>vs', function()
							if vim.fn.filereadable(component_files.scss) == 1 then
								vim.cmd("edit " .. component_files.scss)
							elseif vim.fn.filereadable(component_files.css) == 1 then
								vim.cmd("edit " .. component_files.css)
							else
								vim.notify("No se encontraron archivos de estilos correspondientes", vim.log.levels.WARN)
							end
						end, vim.tbl_extend("force", opts, { desc = "Go to Styles File" }))

						-- Show all related files
						vim.keymap.set('n', '<leader>vf', function()
							local files = {}
							for key, file in pairs(component_files) do
								if vim.fn.filereadable(file) == 1 then
									table.insert(files, key .. ": " .. file)
								end
							end

							if #files > 0 then
								local choices = {}
								for i, file in ipairs(files) do
									table.insert(choices, i .. ". " .. file)
								end

								vim.ui.select(choices, {
									prompt = "Archivos del componente Vue:",
								}, function(choice)
									if choice then
										local idx = tonumber(choice:match("^(%d+)"))
										if idx then
											local file_info = files[idx]
											local file_path = file_info:match(": (.+)$")
											if file_path then
												vim.cmd("edit " .. file_path)
											end
										end
									end
								end)
							else
								vim.notify("No se encontraron archivos relacionados", vim.log.levels.INFO)
							end
						end, vim.tbl_extend("force", opts, { desc = "List Vue Component Files" }))
					end
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