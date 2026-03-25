-- Vue LSP: Volar + HTML para componentes separados (.vue + .html + .ts + .scss)

local vue_markers = {
	"vue.config.js", "vue.config.ts",
	"vite.config.js", "vite.config.ts",
	"nuxt.config.js", "nuxt.config.ts",
}

local function is_vue_component_html(filepath)
	if not filepath or not filepath:match("%.html$") then
		return false
	end
	local base = filepath:gsub("%.html$", "")
	return vim.fn.filereadable(base .. ".vue") == 1 or vim.fn.filereadable(base .. ".ts") == 1
end

local capabilities = nil
local function get_capabilities()
	if not capabilities then
		capabilities = require("cmp_nvim_lsp").default_capabilities()
	end
	return capabilities
end

-- Volar para archivos .vue y .html de componentes separados
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "vue", "html" },
	callback = function(args)
		local root = vim.fs.root(args.buf, vue_markers)
		if not root then
			return
		end

		-- Para HTML, solo activar si es un componente Vue separado
		local filepath = vim.api.nvim_buf_get_name(args.buf)
		if filepath:match("%.html$") and not is_vue_component_html(filepath) then
			return
		end

		vim.lsp.start({
			name = "vue_ls",
			cmd = { vim.fn.stdpath("data") .. "/mason/bin/vue-language-server", "--stdio" },
			root_dir = root,
			capabilities = get_capabilities(),
			-- Volar necesita saber que maneja .html también
			filetypes = { "vue", "html" },
			on_attach = function(client, bufnr)
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false

				local opts = { buffer = bufnr, silent = true }
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
			end,
			settings = {
				vue = {
					server = {
						vitePress = { supportMdFile = true },
						maxFileSize = 20971520,
					},
				},
				typescript = {
					preferences = {
						includePackageJsonAutoImports = "auto",
						quotePreference = "double",
					},
					inlayHints = {
						includeInlayParameterNameHints = "none",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = false,
						includeInlayVariableTypeHints = false,
						includeInlayPropertyDeclarationTypeHints = false,
						includeInlayFunctionLikeReturnTypeHints = false,
						includeInlayEnumMemberValueHints = false,
					},
					suggest = {
						autoImports = true,
						completeFunctionCalls = true,
					},
				},
			},
		})
	end,
})

return {}
