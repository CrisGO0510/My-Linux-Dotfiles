return {
	{
		"simrat39/rust-tools.nvim",
		dependencies = { "neovim/nvim-lspconfig" }, -- Asegúrate de tener nvim-lspconfig
		config = function()
			require("rust-tools").setup({
				tools = {
					-- Aquí puedes habilitar los inlay hints
					inlay_hints = {
						show_parameter_hints = true,
						show_variable_hints = true,
						other_hints_prefix = "=> ",
					},
				},
				server = {
					-- Aquí configuras el servidor LSP de Rust (rust-analyzer)
					on_attach = function(_, bufnr)
						-- Habilitar los inlay hints automáticamente cuando se adjunta el LSP
						vim.lsp.buf.request(bufnr, "textDocument/inlayHint", {}, function(err, result)
							if err then
								print("Error requesting inlay hints: " .. err.message)
							else
								vim.lsp.inlay_hint(bufnr, true)
							end
						end)
					end,
					settings = {
						["rust-analyzer"] = {
							inlayHints = {
								typeHints = true, -- Hints de tipo
								parameterHints = true, -- Hints de parámetros
							},
						},
					},
				},
			})
		end,
	},
}
