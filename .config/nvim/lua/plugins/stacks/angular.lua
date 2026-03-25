-- Angular LSP: usa vim.lsp.start() para inyectar node_modules del proyecto dinámicamente
local mason_pkg = vim.fn.stdpath("data") .. "/mason/packages/angular-language-server"
local mason_ng = mason_pkg .. "/node_modules"
local ngserver = vim.fn.stdpath("data") .. "/mason/bin/ngserver"

-- Asegurar que @angular/language-service esté instalado en Mason
-- (Mason no lo incluye y lo borra al actualizar)
local lang_svc = mason_ng .. "/@angular/language-service"
if vim.fn.isdirectory(lang_svc) == 0 and vim.fn.isdirectory(mason_pkg) == 1 then
	vim.fn.jobstart({ "npm", "install", "--prefix", mason_pkg, "@angular/language-service" }, {
		on_exit = function(_, code)
			if code == 0 then
				vim.schedule(function()
					vim.notify("@angular/language-service instalado en Mason", vim.log.levels.INFO)
				end)
			end
		end,
	})
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "typescript", "html", "htmlangular" },
	callback = function(args)
		local root = vim.fs.root(args.buf, { "angular.json", "nx.json", "project.json" })
		if not root then
			return
		end

		local project_ng = root .. "/node_modules"
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		vim.lsp.start({
			name = "angularls",
			cmd = {
				ngserver,
				"--stdio",
				"--tsProbeLocations",
				project_ng .. "," .. mason_ng,
				"--ngProbeLocations",
				project_ng .. "," .. mason_ng,
			},
			root_dir = root,
			capabilities = capabilities,
			settings = {
				angular = {
					enable = true,
					suggest = { autoImports = true },
					template = { strictTemplates = true, typeChecking = true },
					component = { strictMode = true },
				},
			},
			on_attach = function(client, bufnr)
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false

				local opts = { buffer = bufnr, silent = true }
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
			end,
		})
	end,
})

-- Retornar tabla vacía para que Lazy no se queje
return {}
