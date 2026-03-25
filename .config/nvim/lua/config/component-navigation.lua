-- component-navigation.lua
-- Sistema centralizado de navegación para componentes de frameworks
-- Soporta: Vue.js, Angular (extensible para más frameworks)

local M = {}

-- =====================================================================
-- FRAMEWORK DETECTION
-- =====================================================================

-- Markers para detectar diferentes tipos de proyectos
local project_markers = {
	vue = {
		'vue.config.js', 'vue.config.ts',
		'vite.config.js', 'vite.config.ts',
		'nuxt.config.js', 'nuxt.config.ts',
	},
	angular = {
		'angular.json',
		'nx.json', 
		'project.json',
	}
}

-- Cache para evitar detecciones repetidas
local project_type_cache = {}

-- Detectar tipo de proyecto basado en archivos de configuración
local function detect_project_type(bufnr)
	local cwd = vim.fn.getcwd()
	
	-- Check cache first
	if project_type_cache[cwd] then
		return project_type_cache[cwd]
	end
	
	-- Check for Vue project first
	local vue_root = vim.fs.root(bufnr, project_markers.vue)
	if vue_root then
		project_type_cache[cwd] = 'vue'
		return 'vue'
	end
	
	-- Check for Angular project
	local angular_root = vim.fs.root(bufnr, project_markers.angular)
	if angular_root then
		project_type_cache[cwd] = 'angular'
		return 'angular'
	end
	
	-- No framework detected
	project_type_cache[cwd] = 'none'
	return 'none'
end

-- =====================================================================
-- COMPONENT FILE PATTERNS
-- =====================================================================

-- Patrones de archivos para diferentes frameworks
local component_patterns = {
	vue = {
		-- Vue Separated Components (tu estructura preferida)
		separated = {
			template = '.html',
			component = '.vue', 
			script = '.ts',
			style = '.scss',
			style_alt = '.css',
		},
		-- Vue Single File Component (estándar)
		sfc = {
			component = '.vue',
		}
	},
	angular = {
		component = '.component.ts',
		template = '.component.html',
		style = '.component.scss',
		style_alt = '.component.css',
		spec = '.component.spec.ts',
		module = '.module.ts',
	}
}

-- =====================================================================
-- FILE DETECTION & RESOLUTION
-- =====================================================================

-- Obtener base path del archivo (sin extensiones) - Angular específico
local function get_angular_base_path(filepath)
	-- Para Angular, necesitamos ser más específicos
	local base = filepath
	
	-- Remover extensiones Angular específicas
	base = base:gsub('%.component%.ts$', '')
	base = base:gsub('%.component%.html$', '')
	base = base:gsub('%.component%.scss$', '')
	base = base:gsub('%.component%.css$', '')
	base = base:gsub('%.component%.spec%.ts$', '')
	base = base:gsub('%.module%.ts$', '')
	
	return base
end

-- Obtener base path del archivo (sin extensiones) - Vue específico
local function get_vue_base_path(filepath)
	local base = filepath
	
	-- Vue patterns
	base = base:gsub('%.vue$', '')
	base = base:gsub('%.html$', '')
	base = base:gsub('%.ts$', '')
	base = base:gsub('%.scss$', '')
	base = base:gsub('%.css$', '')
	
	return base
end

-- Encontrar archivos relacionados basado en el tipo de proyecto
function M.get_related_files(filepath, project_type)
	if not filepath then
		return {}
	end
	
	local related_files = {}
	
	if project_type == 'vue' then
		local base_path = get_vue_base_path(filepath)
		local patterns = component_patterns.vue
		
		-- Check for separated components first
		local separated_files = {
			template = base_path .. patterns.separated.template,
			component = base_path .. patterns.separated.component,
			script = base_path .. patterns.separated.script,
			style = base_path .. patterns.separated.style,
			style_alt = base_path .. patterns.separated.style_alt,
		}
		
		-- If we have separated files, use that structure
		if vim.fn.filereadable(separated_files.template) == 1 or 
		   vim.fn.filereadable(separated_files.script) == 1 then
			related_files = separated_files
		else
			-- Fallback to SFC
			related_files.component = base_path .. patterns.sfc.component
		end
		
	elseif project_type == 'angular' then
		local base_path = get_angular_base_path(filepath)
		local patterns = component_patterns.angular
		
		related_files = {
			component = base_path .. patterns.component,
			template = base_path .. patterns.template,
			style = base_path .. patterns.style,
			style_alt = base_path .. patterns.style_alt,
			spec = base_path .. patterns.spec,
			module = base_path .. patterns.module,
		}
	end
	
	return related_files
end

-- =====================================================================
-- NAVIGATION FUNCTIONS
-- =====================================================================

-- Navegar a un tipo específico de archivo
function M.navigate_to_file_type(file_type, priority_order)
	local bufnr = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(bufnr)
	local project_type = detect_project_type(bufnr)
	
	if project_type == 'none' then
		vim.notify("No se detectó un proyecto Vue o Angular compatible", vim.log.levels.WARN)
		return
	end
	
	local related_files = M.get_related_files(filepath, project_type)
	local files_to_try = {}
	
	-- Build priority order for file types
	if priority_order then
		for _, file_key in ipairs(priority_order) do
			if related_files[file_key] then
				table.insert(files_to_try, related_files[file_key])
			end
		end
	else
		-- Single file type
		if related_files[file_type] then
			table.insert(files_to_try, related_files[file_type])
		end
	end
	
	-- Try to open the first existing file
	for _, file_path in ipairs(files_to_try) do
		if vim.fn.filereadable(file_path) == 1 then
			vim.cmd("edit " .. file_path)
			-- Special navigation for component files
			if file_type == 'script' or file_type == 'component' then
				vim.defer_fn(function()
					-- Try to find main export/class definition
					local patterns = { "export default", "export class", "@Component" }
					for _, pattern in ipairs(patterns) do
						if vim.fn.search(pattern, "w") > 0 then
							break
						end
					end
				end, 100)
			end
			return
		end
	end
	
	vim.notify("No se encontró archivo " .. file_type .. " para " .. project_type, vim.log.levels.WARN)
end

-- Mostrar lista de archivos relacionados
function M.show_related_files()
	local bufnr = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(bufnr)
	local project_type = detect_project_type(bufnr)
	
	if project_type == 'none' then
		vim.notify("No se detectó un proyecto Vue o Angular compatible", vim.log.levels.WARN)
		return
	end
	
	local related_files = M.get_related_files(filepath, project_type)
	local existing_files = {}
	
	-- Filter to only existing files
	for file_type, file_path in pairs(related_files) do
		if vim.fn.filereadable(file_path) == 1 then
			table.insert(existing_files, {
				type = file_type,
				path = file_path,
				display = file_type .. ": " .. vim.fn.fnamemodify(file_path, ":t")
			})
		end
	end
	
	if #existing_files == 0 then
		vim.notify("No se encontraron archivos relacionados", vim.log.levels.INFO)
		return
	end
	
	-- Show selection dialog
	local choices = {}
	for i, file_info in ipairs(existing_files) do
		table.insert(choices, i .. ". " .. file_info.display)
	end
	
	vim.ui.select(choices, {
		prompt = "Archivos del componente " .. string.upper(project_type) .. ":",
	}, function(choice)
		if choice then
			local idx = tonumber(choice:match("^(%d+)"))
			if idx and existing_files[idx] then
				vim.cmd("edit " .. existing_files[idx].path)
			end
		end
	end)
end

-- =====================================================================
-- SMART GOTO DEFINITION
-- =====================================================================

-- Buscar componente por nombre en el proyecto (para tags como <Header>, <MyComponent>)
local function find_component_by_tag(tag_name, root)
	if not tag_name or not root then
		return nil
	end

	-- PascalCase a kebab-case: "MyHeader" -> "my-header"
	local kebab = tag_name:gsub("(%u)", function(c) return "-" .. c:lower() end):gsub("^-", "")
	-- PascalCase a lowercase: "Header" -> "header"
	local lower = tag_name:lower()

	-- Patrones de búsqueda: nombre exacto, kebab-case, lowercase
	local names = { tag_name, kebab, lower }
	local extensions = { ".vue", ".component.ts", ".ts" }

	for _, name in ipairs(names) do
		for _, ext in ipairs(extensions) do
			-- Buscar en src/components/<name>/<name><ext>
			local path = root .. "/src/components/" .. name .. "/" .. name .. ext
			if vim.fn.filereadable(path) == 1 then
				return path
			end
			-- Buscar en src/components/<name><ext>
			path = root .. "/src/components/" .. name .. ext
			if vim.fn.filereadable(path) == 1 then
				return path
			end
		end
	end
	return nil
end

-- Obtener el nombre del tag HTML bajo el cursor
local function get_tag_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1

	-- Buscar <TagName en la línea alrededor del cursor
	local tag = line:match("<([A-Z][%w%-]*)")
	if tag then
		-- Verificar que el cursor está sobre o cerca del tag
		local start_pos = line:find("<" .. tag)
		if start_pos and col >= start_pos and col <= start_pos + #tag + 1 then
			return tag
		end
	end

	-- Fallback: palabra bajo el cursor si es PascalCase
	local word = vim.fn.expand("<cword>")
	if word:match("^%u") then
		return word
	end
	return nil
end

-- "Go to definition" inteligente basado en tipo de archivo y proyecto
function M.smart_goto_definition()
	local bufnr = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(bufnr)
	local project_type = detect_project_type(bufnr)

	-- En templates HTML (Vue/Angular), intentar buscar componente por tag primero
	if filepath:match("%.html$") and project_type ~= "none" then
		local tag = get_tag_under_cursor()
		if tag then
			local root = vim.fs.root(bufnr, project_markers[project_type] or {})
			if root then
				local component_file = find_component_by_tag(tag, root)
				if component_file then
					vim.cmd("edit " .. component_file)
					return
				end
			end
		end
	end

	-- Intentar LSP go-to-definition
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	for _, client in ipairs(clients) do
		if client.server_capabilities.definitionProvider then
			vim.lsp.buf.definition()
			return
		end
	end

	-- Fallback: navegación por archivos de componente
	if project_type == 'vue' then
		if filepath:match('%.html$') then
			M.navigate_to_file_type('script', { 'script', 'component' })
		end
	elseif project_type == 'angular' then
		if filepath:match('%.component%.html$') then
			M.navigate_to_file_type('component')
		end
	end
end

-- =====================================================================
-- PUBLIC API
-- =====================================================================

-- Export main functions
M.detect_project_type = detect_project_type
M.navigate_to_component = function() M.navigate_to_file_type('component') end
M.navigate_to_template = function() M.navigate_to_file_type('template') end
M.navigate_to_script = function() M.navigate_to_file_type('script', { 'script', 'component' }) end
M.navigate_to_style = function() M.navigate_to_file_type('style', { 'style', 'style_alt' }) end
M.navigate_to_test = function() 
	M.navigate_to_file_type('spec')
	if vim.v.errmsg ~= "" then  -- Si spec falló, probar con test
		M.navigate_to_file_type('test', { 'test', 'test_alt' })
	end
end

return M