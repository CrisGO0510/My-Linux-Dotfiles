-- Stack Angular: angularls con inyección dinámica de node_modules del proyecto.
-- Activación manual: descomentar en config/lazy.lua.
-- Instalación: :MasonInstall angular-language-server
--
-- Mason no incluye @angular/language-service y lo borra al actualizar.
-- Lo instalamos en el package de Mason la primera vez.

local mason_pkg = vim.fn.stdpath("data") .. "/mason/packages/angular-language-server"
local mason_ng = mason_pkg .. "/node_modules"
local ngserver = vim.fn.stdpath("data") .. "/mason/bin/ngserver"

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

local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config.angularls = {
	cmd = function(dispatchers)
		local bufnr = vim.api.nvim_get_current_buf()
		local root = vim.fs.root(bufnr, { "angular.json", "nx.json", "project.json" })
		local project_ng = (root or vim.fn.getcwd()) .. "/node_modules"
		return vim.lsp.rpc.start({
			ngserver, "--stdio",
			"--tsProbeLocations", project_ng .. "," .. mason_ng,
			"--ngProbeLocations", project_ng .. "," .. mason_ng,
		}, dispatchers)
	end,
	filetypes = { "typescript", "html", "htmlangular" },
	root_markers = { "angular.json", "nx.json", "project.json" },
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
}

vim.lsp.enable("angularls")

return {}
