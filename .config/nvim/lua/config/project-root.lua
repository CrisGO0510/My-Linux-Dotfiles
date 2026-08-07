-- Raíz del proyecto: la base que deben usar telescope y neo-tree.
-- Sin esto cada picker usa el cwd, que se mueve solo (neo-tree lo reapunta al
-- abrirse), y terminas buscando solo dentro de la carpeta del buffer actual.

local M = {}

local VCS_MARKERS = { ".git", ".hg", ".svn" }

local PROJECT_MARKERS = {
	"package.json",
	"angular.json",
	"nx.json",
	"deno.json",
	"Cargo.toml",
	"go.mod",
	"pyproject.toml",
	"Makefile",
}

-- El VCS manda sobre los markers de proyecto: en un monorepo el package.json
-- de un paquete daría una raíz demasiado estrecha.
function M.get(bufnr)
	bufnr = bufnr or 0
	local cwd = vim.fn.getcwd()

	if vim.bo[bufnr].buftype ~= "" or vim.api.nvim_buf_get_name(bufnr) == "" then
		return cwd
	end

	return vim.fs.root(bufnr, VCS_MARKERS) or vim.fs.root(bufnr, PROJECT_MARKERS) or cwd
end

return M
