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
local function find_root(bufnr)
	-- Si el cwd del proceso desaparece (worktree borrado, cambio de rama),
	-- vim.uv.cwd() devuelve nil y vim.fs.root aborta con un assert al
	-- normalizar rutas relativas.
	local ok, root = pcall(function()
		return vim.fs.root(bufnr, VCS_MARKERS) or vim.fs.root(bufnr, PROJECT_MARKERS)
	end)

	return ok and root or nil
end

-- Un cwd borrado no solo rompe a project-root: vim.fn.getcwd() pasa a devolver
-- "" y con eso neo-tree arma rutas sin separador (assert en split_path), y hasta
-- la detección de filetype de nvim aborta. Repararlo cura la sesión entera.
function M.ensure_cwd()
	if vim.uv.cwd() then
		return
	end

	local buf = vim.api.nvim_buf_get_name(0)
	local target = nearest_existing_dir(buf ~= "" and vim.fs.dirname(buf) or nil)
		or nearest_existing_dir(vim.fn.getcwd())
		or vim.env.HOME

	pcall(vim.cmd.cd, vim.fn.fnameescape(target))
	vim.notify("cwd inválido, se reapuntó a " .. target, vim.log.levels.WARN, { title = "project-root" })
end

function M.get(bufnr)
	bufnr = bufnr or 0
	M.ensure_cwd()

	local cwd = vim.uv.cwd() or vim.fn.getcwd()
	local root

	if vim.bo[bufnr].buftype ~= "" or vim.api.nvim_buf_get_name(bufnr) == "" then
		root = cwd
	else
		root = find_root(bufnr) or cwd
	end

	return nearest_existing_dir(root) or vim.uv.cwd() or vim.env.HOME
end

return M
