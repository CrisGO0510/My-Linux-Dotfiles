-- Python LSP: pyright
-- Activación manual: descomentar la línea en config/lazy.lua
-- Instalación del binario: :MasonInstall pyright (una sola vez)
-- Treesitter (python) y formatter (black) ya viven en plugins/languages/

local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config.pyright = {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "pyrightconfig.json", ".git" },
	capabilities = capabilities,
	on_attach = function(_, bufnr)
		vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
		-- pyright no implementa textDocument/implementation; definition es lo que salta al código
		vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { buffer = bufnr, silent = true })
	end,
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "openFilesOnly",
			},
		},
	},
}

vim.lsp.enable("pyright")

return {}
