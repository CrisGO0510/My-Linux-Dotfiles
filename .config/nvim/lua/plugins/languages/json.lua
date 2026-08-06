return {
	-- =====================================================================
	-- JSON Language Server with Schema Validation
	-- Enhanced support for JSON files with automatic schema detection
	-- =====================================================================
	{
		"neovim/nvim-lspconfig",
		dependencies = { 
			"williamboman/mason.nvim",
			"b0o/schemastore.nvim",
		},
		ft = { "json", "jsonc" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- JSON LSP Configuration with Schema Store integration
			vim.lsp.config.jsonls = {
				-- Use Mason binary path for consistency
				cmd = { vim.fn.stdpath("data") .. "/mason/bin/vscode-json-language-server", "--stdio" },
				
				filetypes = { "json", "jsonc" },
				
				-- Root directory detection for JSON projects
				root_markers = { ".git", "package.json" },
				
				capabilities = capabilities,
				
				-- Streamlined on_attach function with modern API
				on_attach = function(client, bufnr)
					-- Modern way to set omnifunc (Neovim 0.7+)
					vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
					
					-- Optional: Disable formatting if using other formatters
					-- client.server_capabilities.documentFormattingProvider = false
				end,
				
				-- Enhanced JSON settings with schema store
				settings = {
					json = {
						-- Automatic schema detection using SchemaStore
						schemas = require("schemastore").json.schemas(),
						
						-- Enable validation
						validate = { enable = true },
						
						-- Format settings
						format = {
							enable = true,
						},
						
						-- Additional JSON-specific settings
						keepLines = {
							enable = true,
						},
						
					},
				},
			}

			vim.lsp.enable("jsonls")
		end,
	},
	
	-- Schema store for automatic JSON schema detection
	{
		"b0o/schemastore.nvim",
		lazy = true,
		ft = { "json", "jsonc" },
	},
}