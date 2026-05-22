-- Stack Vue: Volar (vue_ls) + ts_ls con @vue/typescript-plugin (hybrid mode).
-- Activación manual: descomentar en config/lazy.lua.
-- Instalación de binarios: :MasonInstall vue-language-server typescript-language-server
--
-- Soporta tanto SFC (.vue) como componentes separados (.vue + .html + .ts + .scss).

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local vue_ts_plugin = vim.fn.stdpath("data")
	.. "/mason/packages/vue-language-server/node_modules/@vue/typescript-plugin"

-- Forzar dynamicRegistration = false en ts_ls: si lo dejamos en true, el
-- server registra selectors que excluyen "vue" y supports_method() devuelve
-- false aunque definitionProvider sea true.
local ts_capabilities = vim.tbl_deep_extend("force", capabilities, {
	textDocument = {
		definition = { dynamicRegistration = false },
		references = { dynamicRegistration = false },
		hover = { dynamicRegistration = false },
		implementation = { dynamicRegistration = false },
		typeDefinition = { dynamicRegistration = false },
		declaration = { dynamicRegistration = false },
		completion = { dynamicRegistration = false },
		rename = { dynamicRegistration = false },
		signatureHelp = { dynamicRegistration = false },
	},
})

local no_inlay_hints = {
	includeInlayParameterNameHints = "none",
	includeInlayParameterNameHintsWhenArgumentMatchesName = false,
	includeInlayFunctionParameterTypeHints = false,
	includeInlayVariableTypeHints = false,
	includeInlayPropertyDeclarationTypeHints = false,
	includeInlayFunctionLikeReturnTypeHints = false,
	includeInlayEnumMemberValueHints = false,
}

-- ts_ls atendiendo .vue cargando @vue/typescript-plugin
vim.lsp.config.ts_ls = {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = {
		"javascript", "javascriptreact", "javascript.jsx",
		"typescript", "typescriptreact", "typescript.tsx",
		"vue",
	},
	root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
	capabilities = ts_capabilities,
	init_options = {
		plugins = {
			{
				name = "@vue/typescript-plugin",
				location = vue_ts_plugin,
				languages = { "vue" },
			},
		},
	},
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

-- Volar: atiende .vue y .html de componentes separados (template files).
local vue_markers = {
	"vue.config.js", "vue.config.ts",
	"vite.config.js", "vite.config.ts",
	"nuxt.config.js", "nuxt.config.ts",
	"quasar.config.js", "quasar.config.ts",
}

local function is_vue_component_html(filepath)
	if not filepath or not filepath:match("%.html$") then
		return false
	end
	local base = filepath:gsub("%.html$", "")
	return vim.fn.filereadable(base .. ".vue") == 1 or vim.fn.filereadable(base .. ".ts") == 1
end

vim.lsp.config.vue_ls = {
	cmd = { vim.fn.stdpath("data") .. "/mason/bin/vue-language-server", "--stdio" },
	filetypes = { "vue", "html" },
	root_markers = vue_markers,
	capabilities = capabilities,
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
			inlayHints = no_inlay_hints,
			suggest = {
				autoImports = true,
				completeFunctionCalls = true,
			},
		},
	},
}

vim.lsp.enable("ts_ls")
vim.lsp.enable("vue_ls")

-- Filter para que Volar solo se active en HTMLs que son componentes Vue separados.
-- (No queremos Volar en HTML genérico.)
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client or client.name ~= "vue_ls" then
			return
		end
		local filepath = vim.api.nvim_buf_get_name(args.buf)
		if filepath:match("%.html$") and not is_vue_component_html(filepath) then
			vim.lsp.buf_detach_client(args.buf, args.data.client_id)
		end
	end,
})

return {}
