-- Mason + los LSPs siempre activos: lua_ls (para editar este config) y
-- jsonls (definido en plugins/languages/json.lua).
-- El resto de LSPs viven en plugins/stacks/<lang>.lua y se activan
-- descomentando su línea en config/lazy.lua.
--
-- automatic_enable = false: mason-lspconfig NO arranca servers solo;
-- cada stack llama explícitamente a vim.lsp.enable("<name>").

return {
	"williamboman/mason.nvim",
	lazy = false, -- define y habilita los LSP: tiene que correr antes de abrir archivos
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
	},
	build = ":MasonUpdate",
	config = function()
		require("mason").setup()

		require("mason-lspconfig").setup({
			ensure_installed = { "lua_ls", "jsonls" },
			automatic_enable = false,
		})

		-- mason-lspconfig solo instala language servers. Los formatters hay que
		-- pedirlos aparte o no existen en una máquina recién clonada.
		local registry = require("mason-registry")
		registry.refresh(function()
			for _, name in ipairs({ "prettierd" }) do
				local ok, pkg = pcall(registry.get_package, name)
				if ok and not pkg:is_installed() then
					pkg:install()
				end
			end
		end)

		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		vim.lsp.config.lua_ls = {
			cmd = { "lua-language-server" },
			filetypes = { "lua" },
			root_markers = {
				".luarc.json", ".luarc.jsonc", ".luacheckrc",
				".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git",
			},
			capabilities = capabilities,
			on_attach = function(_, bufnr)
				vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
			end,
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					diagnostics = { globals = { "vim" } },
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false,
					},
					telemetry = { enable = false },
				},
			},
		}

		vim.lsp.enable("lua_ls")
	end,
}
