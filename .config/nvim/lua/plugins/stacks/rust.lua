-- Rust LSP: rust-analyzer
-- Activación manual: descomentar la línea en config/lazy.lua
-- Instalación del binario: :MasonInstall rust-analyzer (una sola vez)
-- Treesitter (rust) y formatter (rustfmt) ya viven en plugins/languages/

local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config.rust_analyzer = {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", "rust-project.json", ".git" },
	capabilities = capabilities,
	on_attach = function(_, bufnr)
		vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
	end,
	settings = {
		["rust-analyzer"] = {
			cargo = {
				allFeatures = true,
				runBuildScripts = true,
			},
			checkOnSave = {
				command = "clippy",
				extraArgs = { "--no-deps" },
			},
			procMacro = {
				enable = true,
			},
			inlayHints = {
				chainingHints = { enable = true },
				parameterHints = { enable = true },
				typeHints = { enable = true },
				closingBraceHints = { enable = true, minLines = 25 },
			},
		},
	},
}

vim.lsp.enable("rust_analyzer")

return {}
