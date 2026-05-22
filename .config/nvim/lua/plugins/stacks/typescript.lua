-- Stack TypeScript: ts_ls puro (sin Vue plugin).
-- Activación manual: descomentar en config/lazy.lua.
-- Instalación: :MasonInstall typescript-language-server
--
-- NO activar junto con stacks/vue.lua: el stack Vue ya incluye ts_ls
-- atendiendo filetype "vue" con el plugin @vue/typescript-plugin.

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local no_inlay_hints = {
	includeInlayParameterNameHints = "none",
	includeInlayParameterNameHintsWhenArgumentMatchesName = false,
	includeInlayFunctionParameterTypeHints = false,
	includeInlayVariableTypeHints = false,
	includeInlayPropertyDeclarationTypeHints = false,
	includeInlayFunctionLikeReturnTypeHints = false,
	includeInlayEnumMemberValueHints = false,
}

vim.lsp.config.ts_ls = {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = {
		"javascript", "javascriptreact", "javascript.jsx",
		"typescript", "typescriptreact", "typescript.tsx",
	},
	root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	settings = {
		typescript = { inlayHints = no_inlay_hints },
		javascript = { inlayHints = no_inlay_hints },
	},
}

vim.lsp.enable("ts_ls")

return {}
