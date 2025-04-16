return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")

			lspconfig.rust_analyzer.setup({
				on_attach = function(client, bufnr)
					if client.server_capabilities.inlayHintProvider then
						vim.lsp.inlay_hint.enable(bufnr, true)
					end
				end,
				settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
						},
						checkOnSave = {
							command = "clippy",
						},
						inlayHints = {
							lifetimeElisionHints = {
								enable = true,
								useParameterNames = true,
							},
							bindingModeHints = {
								enable = true,
							},
							chainingHints = true,
							closingBraceHints = {
								enable = true,
							},
							closureReturnTypeHints = {
								enable = "always",
							},
							parameterHints = true,
							typeHints = true,
						},
					},
				},
			})
		end,
	},
}
