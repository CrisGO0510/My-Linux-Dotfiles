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

-- Un cambio de rama puede borrar el directorio al que apunta el cwd o el buffer,
-- y neo-tree/telescope abortan con ENOENT si les pasas una ruta que no existe.
local function nearest_existing_dir(path)
	while path and path ~= "" do
		local stat = vim.uv.fs_stat(path)
		if stat and stat.type == "directory" then
			return path
		end

		local parent = vim.fs.dirname(path)
		if parent == path then
			return nil
		end

		path = parent
	end
end

-- El VCS manda sobre los markers de proyecto: en un monorepo el package.json
-- de un paquete daría una raíz demasiado estrecha.
function M.get(bufnr)
	bufnr = bufnr or 0
	local cwd = vim.fn.getcwd()
	local root

	if vim.bo[bufnr].buftype ~= "" or vim.api.nvim_buf_get_name(bufnr) == "" then
		root = cwd
	else
		root = vim.fs.root(bufnr, VCS_MARKERS) or vim.fs.root(bufnr, PROJECT_MARKERS) or cwd
	end

	return nearest_existing_dir(root) or vim.uv.cwd() or vim.env.HOME
end

return M
