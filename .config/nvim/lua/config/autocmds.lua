local augroup = vim.api.nvim_create_augroup("MinimalStartup", { clear = true })

-- Solo mostrar alpha como fallback cuando NO hay argumentos
vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup,
	nested = true,
	callback = function()
		-- Solo mostrar alpha si NO hay argumentos (nvim sin parámetros)
		if vim.fn.argc() == 0 then
			vim.defer_fn(function()
				-- Verificación simple: si no hay buffers reales, mostrar alpha
				local has_real_content = false
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) ~= "" then
						has_real_content = true
						break
					end
				end

				if not has_real_content then
					require("alpha").start(true)
				end
			end, 50) -- Delay mínimo
		end
		-- Si argc() > 0 (como "nvim ."), auto-session maneja TODO automáticamente
	end,
})

-- Limpiar alpha cuando se abre contenido real
vim.api.nvim_create_autocmd("BufRead", {
	group = augroup,
	callback = function()
		if vim.bo.filetype == "alpha" then
			return
		end
		-- Cerrar alpha si está abierto y se abre contenido real
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.bo[buf].filetype == "alpha" then
				vim.api.nvim_buf_delete(buf, { force = true })
				break
			end
		end
	end,
})

-- Autocomando para mantener alpha limpio (sin cambios)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "alpha",
	group = augroup,
	callback = function()
		vim.opt_local.buflisted = false
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.cursorline = false
		vim.opt_local.foldcolumn = "0"
		vim.opt_local.signcolumn = "no"
	end,
})

-- ===== VUE COMPONENT SUPPORT =====
-- Enhanced support for separated Vue component files (.html, .ts, .scss)

local vue_group = vim.api.nvim_create_augroup("VueComponentSupport", { clear = true })

-- Function to check if we're in a Vue project
local function is_vue_project()
	local vue_markers = {
		'vue.config.js', 'vue.config.ts',
		'vite.config.js', 'vite.config.ts',
		'nuxt.config.js', 'nuxt.config.ts',
	}
	local root = vim.fs.root(0, vue_markers)
	return root ~= nil
end

-- Function to check if HTML file is part of a Vue component
local function is_vue_component_html(filepath)
	if not filepath or not filepath:match("%.html$") then
		return false
	end

	local base_path = filepath:gsub("%.html$", "")
	local dir = vim.fn.fnamemodify(base_path, ":h")
	local name = vim.fn.fnamemodify(base_path, ":t")

	local vue_file = dir .. "/" .. name .. ".vue"
	local ts_file = dir .. "/" .. name .. ".ts"

	local vue_exists = vim.fn.filereadable(vue_file) == 1
	local ts_exists = vim.fn.filereadable(ts_file) == 1

	return vue_exists or ts_exists
end

-- Set proper filetype for Vue component HTML files
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
	group = vue_group,
	pattern = "*.html",
	callback = function()
		if is_vue_project() then
			local filepath = vim.api.nvim_buf_get_name(0)
			if is_vue_component_html(filepath) then
				-- Set buffer-specific options for Vue templates
				vim.opt_local.filetype = "html"
				vim.opt_local.syntax = "html"
				
				-- Add Vue-specific buffer variables for LSP detection
				vim.b.vue_component_html = true
				vim.b.vue_component_base = filepath:gsub("%.html$", "")
				
				-- Enhanced syntax highlighting for Vue templates
				vim.cmd([[
					runtime! syntax/html.vim
					syn region vueDirective start=/v-\w/ end=/=/
					syn region vueInterpolation start=/{{/ end=/}}/
					syn region vueBinding start=/:/ end=/=/
					syn region vueEvent start=/@/ end=/=/
					hi def link vueDirective Keyword
					hi def link vueInterpolation Identifier
					hi def link vueBinding Type
					hi def link vueEvent Function
				]])
				
				vim.notify("📄 Archivo HTML de componente Vue detectado", vim.log.levels.INFO)
			end
		end
	end,
})

-- Auto-open related component files
vim.api.nvim_create_autocmd("BufEnter", {
	group = vue_group,
	pattern = "*.vue",
	callback = function()
		if is_vue_project() then
			local filepath = vim.api.nvim_buf_get_name(0)
			local base_path = filepath:gsub("%.vue$", "")
			
			-- Store related file paths for quick access
			vim.b.vue_component_files = {
				html = base_path .. ".html",
				ts = base_path .. ".ts",
				scss = base_path .. ".scss",
				css = base_path .. ".css"
			}
		end
	end,
})

-- Provide quick navigation hints
vim.api.nvim_create_autocmd("FileType", {
	group = vue_group,
	pattern = "html",
	callback = function()
		if vim.b.vue_component_html then
			-- Add buffer-local keymaps for quick navigation
			local opts = { buffer = true, silent = true }
			
			-- Quick hints about available navigation
			vim.defer_fn(function()
				if vim.b.vue_component_base then
					local base = vim.b.vue_component_base
					local hints = {}
					
					if vim.fn.filereadable(base .. ".vue") == 1 then
						table.insert(hints, "gd → Ir a componente")
					end
					if vim.fn.filereadable(base .. ".ts") == 1 then
						table.insert(hints, "<leader>vt → Ir a TypeScript")
					end
					
					if #hints > 0 then
						vim.notify("💡 " .. table.concat(hints, " | "), vim.log.levels.INFO)
					end
				end
			end, 1000)
		end
	end,
})
