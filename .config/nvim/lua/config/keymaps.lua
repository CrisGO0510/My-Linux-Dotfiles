local opts = { noremap = true, silent = true }
local map = vim.keymap.set
local wk = require("which-key")
local project_root = require("config.project-root")

-- Navegar por líneas visuales (útil cuando wrap está activo)
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Evita que <Space> haga algo (leader ya definido en init.lua)
map("n", "<Space>", "<NOP>", opts)

map("t", "<C-Esc>", "<C-\\><C-n>", opts)
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Quitar resaltado de búsqueda" })
map("n", "zl", "10zl", { desc = "Desplazar vista → 5 cols" })
map("n", "zh", "10zh", { desc = "Desplazar vista ← 5 cols" })
map("n", "<leader>q", "<cmd>confirm qall<CR>", { desc = "Cerrar nvim" })

wk.add({
	{ "<leader>c", group = "Code" },
	{
		"<leader>ca",
		function()
			vim.lsp.buf.code_action()
		end,
		desc = "Acciones de código (Code Action)",
		mode = { "n", "v" }, -- puede ser normal y visual mode
	},
	{
		"<leader>cr",
		function()
			vim.lsp.buf.rename()
		end,
		desc = "Renombrar variable (LSP Rename)",
		mode = { "n", "v" },
	},

	{
		"<leader>ce",
		function()
			vim.diagnostic.open_float()
		end,
		desc = "Mostrar error en línea",
		mode = "n",
	},
	{
		"<leader>cw",
		function()
			vim.wo.wrap = not vim.wo.wrap
			local status = vim.wo.wrap and "Activado" or "Desactivado"
			vim.notify("Word Wrap " .. status, vim.log.levels.INFO, { title = "Interfaz" })
		end,
		desc = "Toggle wrap",
		mode = "n",
	},
	{
		"<leader>ci",
		function()
			vim.lsp.buf.hover()
		end,
		desc = "Mostrar información de la variable",
		mode = "n",
	},
	{
		"<leader>cy",
		function()
			local filename = vim.fn.expand("%:t")
			vim.fn.setreg("+", filename)
			vim.notify("Copiado: " .. filename, vim.log.levels.INFO, { title = "Clipboard" })
		end,
		desc = "Copiar nombre del archivo al portapapeles",
		mode = "n",
	},
	{
		"<leader>cm",
		function()
			vim.cmd("MarkdownPreviewToggle")
		end,
		desc = "Alternar vista previa de Markdown",
		mode = "n",
	},
	{
		"<leader>cs",
		":SSSelected<CR>",
		desc = "Capturar selección (CodeShot)",
		mode = "v",
	},
	{
		"<leader>cx",
		":SSFocused<CR>",
		desc = "Capturar vista con selección resaltada",
		mode = "v",
	},
})

-- cmp keymaps
-- OJO: nada de require("cmp") en el nivel superior. Este archivo se carga al
-- arrancar, así que eso forzaría a cmp a cargar siempre y anularía su
-- lazy-load por InsertEnter. Todos los require van dentro de los callbacks.

-- Alimenta una tecla SIN remapear, para no reentrar en este mismo mapeo.
local function feed_native(keys)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), "n", false)
end

-- Estos mapeos son globales de insert mode, así que pisan teclas nativas de
-- Vim. Si el menú de cmp no está visible hay que devolver la tecla original,
-- o se pierden i_CTRL-N, i_CTRL-Y, i_CTRL-F, etc.
local function cmp_or_native(key, action)
	return function()
		local cmp = require("cmp")
		if cmp.visible() then
			action(cmp)
		else
			feed_native(key)
		end
	end
end

wk.add({
	{
		"<C-Space>",
		function()
			local cmp = require("cmp")
			if cmp.visible() then
				cmp.close()
			else
				cmp.complete()
			end
		end,
		desc = "Abrir/cerrar autocompletado",
		mode = "i",
	},
	-- Navegación por ítems
	{
		"<C-n>",
		cmp_or_native("<C-n>", function(cmp)
			cmp.select_next_item()
		end),
		desc = "Siguiente ítem / completado nativo",
		mode = "i",
	},
	{
		"<C-p>",
		cmp_or_native("<C-p>", function(cmp)
			cmp.select_prev_item()
		end),
		desc = "Ítem anterior / completado nativo",
		mode = "i",
	},
	{
		"<C-y>",
		cmp_or_native("<C-y>", function(cmp)
			cmp.confirm({ select = true })
		end),
		desc = "Aceptar sugerencia / copiar char de arriba",
		mode = "i",
	},

	-- Scroll docs
	{
		"<C-b>",
		cmp_or_native("<C-b>", function(cmp)
			cmp.scroll_docs(-4)
		end),
		desc = "Docs atrás",
		mode = "i",
	},
	{
		"<C-f>",
		cmp_or_native("<C-f>", function(cmp)
			cmp.scroll_docs(4)
		end),
		desc = "Docs adelante / reindentar línea",
		mode = "i",
	},

	{
		"<CR>",
		function()
			local cmp = require("cmp")
			if cmp.visible() then
				cmp.confirm({ select = true })
			else
				-- Delegar en autopairs: expande llaves/paréntesis al saltar línea.
				-- autopairs_cr() ya devuelve las teclas escapadas: no re-escapar.
				vim.api.nvim_feedkeys(require("nvim-autopairs").autopairs_cr(), "n", false)
			end
		end,
		desc = "Confirmar si visible / nueva línea (autopairs)",
		mode = "i",
	},
})

-- copilot.lua

wk.add({
	{
		"<Tab>",
		function()
			local cmp = require("cmp")
			if cmp.visible() then
				cmp.confirm({ select = true })
			elseif require("copilot.suggestion").is_visible() then
				require("copilot.suggestion").accept()
			else
				-- Si no hay nada, enviamos un Tab real
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
			end
		end,
		desc = "Confirmar CMP o aceptar Copilot",
		mode = "i",
	},
	{
		"<M-l>",
		function()
			if require("copilot.suggestion").is_visible() then
				require("copilot.suggestion").accept_word()
			end
		end,
		desc = "Aceptar palabra de Copilot",
		mode = "i",
	},
	{
		"<M-j>", -- Te agrego esta, es muy útil para aceptar una línea entera
		function()
			if require("copilot.suggestion").is_visible() then
				require("copilot.suggestion").accept_line()
			end
		end,
		desc = "Aceptar línea de Copilot",
		mode = "i",
	},
	{
		"<M-n>",
		function()
			require("copilot.suggestion").next()
		end,
		desc = "Siguiente sugerencia",
		mode = "i",
	},
	{
		"<M-p>",
		function()
			require("copilot.suggestion").prev()
		end,
		desc = "Sugerencia anterior",
		mode = "i",
	},
	{
		"<M-x>",
		function()
			require("copilot.suggestion").dismiss()
		end,
		desc = "Cerrar sugerencia",
		mode = "i",
	},
})

-- window
wk.add({
	-- Agrupar atajos de ventana bajo <leader>w
	{ "<leader>w", group = "Window" },

	-- Crear un split vertical
	{
		"<leader>ws",
		function()
			vim.cmd("vsplit")
		end,
		desc = "Split vertical",
	},

	-- Crear un split horizontal
	{
		"<leader>wh",
		function()
			vim.cmd("split")
		end,
		desc = "Split horizontal",
	},

	-- Cerrar la ventana actual (no cierra nvim si es la última)
	{
		"<leader>wd",
		function()
			vim.cmd("close")
		end,
		desc = "Cerrar la ventana actual",
	},

	-- Moverse entre ventanas (con atajos estándar de Neovim)
	{ "<C-h>", "<C-w>h", desc = "Mover a la ventana izquierda" },
	{ "<C-j>", "<C-w>j", desc = "Mover a la ventana inferior" },
	{ "<C-k>", "<C-w>k", desc = "Mover a la ventana superior" },
	{ "<C-l>", "<C-w>l", desc = "Mover a la ventana derecha" },

	-- Redimensionar splits verticalmente con Ctrl-Shift
	{ "<C-S-h>", ":vertical resize -5<CR>", desc = "Reducir split verticalmente" },
	{ "<C-S-l>", ":vertical resize +5<CR>", desc = "Expandir split verticalmente" },

	-- Redimensionar splits horizontalmente con Ctrl-Shift
	{ "<C-S-j>", ":resize -5<CR>", desc = "Reducir split horizontalmente" },
	{ "<C-S-k>", ":resize +5<CR>", desc = "Expandir split horizontalmente" },

	-- Mover ventanas a diferentes posiciones
	{
		"<leader>wH",
		function()
			vim.cmd("wincmd H")
		end,
		desc = "Mover ventana a la izquierda",
	},
	{
		"<leader>wL",
		function()
			vim.cmd("wincmd L")
		end,
		desc = "Mover ventana a la derecha",
	},
	{
		"<leader>wK",
		function()
			vim.cmd("wincmd K")
		end,
		desc = "Mover ventana arriba",
	},
	{
		"<leader>wJ",
		function()
			vim.cmd("wincmd J")
		end,
		desc = "Mover ventana abajo",
	},
})

wk.add({
	{ "<leader>a", group = "AI (CodeCompanion)" },

	-- Chat General
	{
		"<leader>ac",
		"<cmd>CodeCompanionChat Toggle<CR>",
		desc = "Toggle IA Chat",
		mode = { "n", "v" },
	},

	-- Acciones sobre el código (Refactor, Tipos, etc.)
	-- CodeCompanion usa una paleta de acciones muy potente
	{
		"<leader>ap",
		"<cmd>CodeCompanionActions<CR>",
		desc = "Paleta de Acciones (Selector)",
		mode = { "n", "v" },
	},

	{
		"<leader>aa",
		function()
			local mode = vim.api.nvim_get_mode().mode
			if mode == "v" or mode == "V" or mode == "" then
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(":CodeCompanion ", true, false, true), "n", false)
			else
				vim.api.nvim_feedkeys(
					vim.api.nvim_replace_termcodes(":CodeCompanion #{buffer} ", true, false, true),
					"n",
					false
				)
			end
		end,
		desc = "IA Prompt Rápido (Contextual)",
		mode = { "n", "v" },
	},

	-- Documentar y Tipos
	{
		"<leader>ad",
		"<cmd>CodeCompanion Añade tipos y documentación<CR>",
		desc = "Agregar tipos y Docs",
		mode = { "v" }, -- Importante: Selecciona el código en modo visual y presiona el atajo
	},
})

wk.add({
	{
		"<C-s>",
		function()
			require("conform").format({ async = true }, function(err, did_edit)
				-- Callback ejecutado después de que el formatting termine
				if not err then
					vim.cmd("w")  -- Guardar solo si no hubo error
				end
			end)
		end,
		desc = "Formatear y guardar",
	},
}, { mode = { "n", "i" } })
-- snacks.lua

wk.add({
	{
		"<leader>,",
		function()
			require("telescope.builtin").buffers({
				initial_mode = "normal",
				ignore_current_buffer = true,
				sort_mru = true,
			})
		end,
		desc = "Buffers",
	},
	{
		"<leader>/",
		function()
			require("telescope.builtin").live_grep({ cwd = project_root.get() })
		end,
		desc = "Grep",
	},
	{ "<leader>:", "<cmd>Telescope command_history<CR>", desc = "Command History" },
})

wk.add({
	{ "<leader>f", group = "find" },

	{ "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
	{
		"<leader>fc",
		function()
			require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
		end,
		desc = "Find Config File",
	},
	{
		"<leader>ff",
		function()
			require("telescope.builtin").find_files({ cwd = project_root.get() })
		end,
		desc = "Find Files",
	},
	{ "<leader>fg", "<cmd>Telescope git_files<CR>", desc = "Find Git Files" },
	{
		"<leader>fp",
		function()
			require("telescope").extensions.project.project({})
		end,
		desc = "Projects",
	},
	{
		"<leader>fr",
		function()
			require("telescope").extensions.frecency.frecency()
		end,
		desc = "Archivos Frecuentes (Manual)",
	},
	{
		"<leader>ft",
		function()
			require("snacks").terminal()
		end,
		desc = "Toggle Terminal",
	},
})

-- git
wk.add({
	{ "<leader>g", group = "git" },

	{ "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Git Status" },
	{
		"<leader>gB",
		function()
			require("snacks").gitbrowse()
		end,
		desc = "Git Browse",
	},
	{
		"<leader>gg",
		function()
			require("snacks").lazygit()
		end,
		desc = "Lazygit",
	},
	{ "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "Git Branches" },
	{ "<leader>gl", "<cmd>Telescope git_commits<CR>", desc = "Git Log" },
	{ "<leader>gL", "<cmd>Telescope git_bcommits<CR>", desc = "Git Log (buffer)" },
	{ "<leader>gS", "<cmd>Telescope git_stash<CR>", desc = "Git Stash" },
	{
		"<leader>gf",
		function()
			require("telescope.builtin").git_bcommits({ current_file = vim.fn.expand("%") })
		end,
		desc = "Git Log File",
	},
})

-- lsp

wk.add({
	{ "<leader>s", group = "search" },

	{ "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Buffer Lines" },
	{
		"<leader>sB",
		function()
			require("telescope.builtin").live_grep({ grep_open_files = true })
		end,
		desc = "Grep Open Buffers",
	},
	{
		"<leader>sg",
		function()
			require("telescope.builtin").live_grep({ cwd = project_root.get() })
		end,
		desc = "Grep",
	},
	{
		"<leader>sw",
		function()
			require("telescope.builtin").grep_string({ cwd = project_root.get() })
		end,
		desc = "Visual selection or word",
	},
	{ '<leader>s"', "<cmd>Telescope registers<CR>", desc = "Registers" },
	{ "<leader>s/", "<cmd>Telescope search_history<CR>", desc = "Search History" },
	{ "<leader>sa", "<cmd>Telescope autocommands<CR>", desc = "Autocmds" },
	{ "<leader>sc", "<cmd>Telescope command_history<CR>", desc = "Command History" },
	{ "<leader>sC", "<cmd>Telescope commands<CR>", desc = "Commands" },
	{ "<leader>sd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
	{
		"<leader>sD",
		function()
			require("telescope.builtin").diagnostics({ bufnr = 0 })
		end,
		desc = "Buffer Diagnostics",
	},
	{ "<leader>sh", "<cmd>Telescope help_tags<CR>", desc = "Help Pages" },
	{ "<leader>sH", "<cmd>Telescope highlights<CR>", desc = "Highlights" },
	{ "<leader>sj", "<cmd>Telescope jumplist<CR>", desc = "Jumps" },
	{ "<leader>sk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps" },
	{ "<leader>sl", "<cmd>Telescope loclist<CR>", desc = "Location List" },
	{ "<leader>sm", "<cmd>Telescope marks<CR>", desc = "Marks" },
	{ "<leader>sM", "<cmd>Telescope man_pages<CR>", desc = "Man Pages" },
	{ "<leader>sp", "<cmd>Lazy<CR>", desc = "Plugin Spec (Lazy UI)" },
	{ "<leader>sq", "<cmd>Telescope quickfix<CR>", desc = "Quickfix List" },
	{ "<leader>sR", "<cmd>Telescope resume<CR>", desc = "Resume" },
	{ "<leader>ss", "<cmd>Telescope lsp_document_symbols<CR>", desc = "LSP Symbols" },
	{ "<leader>sS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", desc = "LSP Workspace Symbols" },
})

-- UI

wk.add({
	{ "<leader>u", group = "ui" },

	{ "<leader>uC", "<cmd>Telescope colorscheme<CR>", desc = "Colorschemes" },
	{ "<leader>un", "<cmd>NoiceDismiss<CR>", desc = "Dismiss All Notifications" },
})

wk.add({
	{
		"<leader>z",
		function()
			require("snacks").zen()
		end,
		desc = "Toggle Zen Mode",
	},
	{
		"<leader>Z",
		function()
			require("snacks").zen.zoom()
		end,
		desc = "Toggle Zoom",
	},
	{
		"<leader>.",
		function()
			require("snacks").scratch()
		end,
		desc = "Toggle Scratch Buffer",
	},
	{ "<leader>n", "<cmd>NoiceHistory<CR>", desc = "Notification History" },
})


wk.add({
	{
		"gI",
		function()
			require("telescope.builtin").lsp_references({})
		end,
		desc = "References Telescope",
	},
})

-- buffer

wk.add({
	{ "<leader>b", group = "buffers" },
	{
		"<leader>bb",
		function()
			require("telescope.builtin").buffers()
		end,
		desc = "List Buffers",
	},
	{
		"<leader>bd",
		function()
			local curr_buf = vim.api.nvim_get_current_buf()
			vim.cmd("bprevious") -- Ir al buffer anterior
			vim.api.nvim_buf_delete(curr_buf, { force = true })
		end,
		desc = "Cerrar buffer actual sin cerrar ventana",
	},
	{
		"<leader>bn",
		"<cmd>bnext<CR>",
		desc = "Buffer siguiente",
	},
	{
		"<leader>bp",
		"<cmd>bprevious<CR>",
		desc = "Buffer anterior",
	},
	{
		"<leader>bo",
		function()
			local current_buf = vim.api.nvim_get_current_buf()
			local buffers = vim.api.nvim_list_bufs()
			for _, buf in ipairs(buffers) do
				if buf ~= current_buf then
					vim.api.nvim_buf_delete(buf, { force = true })
				end
			end
		end,
		desc = "Delete All Other Buffers",
	},
})

-- obsidian.nvim
-- Los comandos van como string: :Obsidian dispara el lazy-load del plugin.
-- <CR> (acción inteligente) y [o / ]o los registra el propio plugin como
-- mapeos buffer-local al entrar en una nota del vault.
wk.add({
	{ "<leader>o", group = "Obsidian" },

	{ "<leader>oo", "<cmd>Obsidian quick_switch<CR>", desc = "Abrir nota" },
	{ "<leader>on", "<cmd>Obsidian new<CR>", desc = "Nueva nota" },
	{ "<leader>os", "<cmd>Obsidian search<CR>", desc = "Buscar en el vault (grep)" },
	{ "<leader>ot", "<cmd>Obsidian tags<CR>", desc = "Buscar por tag" },
	{ "<leader>ob", "<cmd>Obsidian backlinks<CR>", desc = "Backlinks de la nota" },
	{ "<leader>ol", "<cmd>Obsidian links<CR>", desc = "Links de la nota" },
	{ "<leader>oT", "<cmd>Obsidian toc<CR>", desc = "Tabla de contenidos" },
	{ "<leader>oc", "<cmd>Obsidian toggle_checkbox<CR>", desc = "Alternar checkbox" },
	{ "<leader>oi", "<cmd>Obsidian paste_img<CR>", desc = "Pegar imagen del portapapeles" },
	{ "<leader>or", "<cmd>Obsidian rename<CR>", desc = "Renombrar nota (actualiza backlinks)" },
	{ "<leader>op", "<cmd>Obsidian open<CR>", desc = "Abrir en la app de Obsidian" },

	{ "<leader>oe", ":Obsidian extract_note<CR>", desc = "Extraer selección a nota nueva", mode = "v" },
	{ "<leader>ok", ":Obsidian link<CR>", desc = "Enlazar selección a una nota", mode = "v" },
})

wk.add({
	{
		"<leader> ",
		function()
			require("telescope.builtin").find_files({ cwd = project_root.get() })
		end,
		desc = "Find Files",
	},
	{
		"<leader>e",
		function()
			-- La raíz se resuelve al pulsar la tecla, no al cargar este archivo:
			-- si no, queda congelada al buffer inicial (vacío). reveal deja el
			-- cursor en el archivo actual sin recortar el árbol a su carpeta.
			local dir = project_root.get()
			vim.cmd("Neotree toggle reveal=true position=left dir=" .. vim.fn.fnameescape(dir))
		end,
		desc = "Toggle NeoTree en la raíz del proyecto",
	},
	{
		"<leader>A",
		function()
			require("alpha").start()
		end,
		desc = "Mostrar Dashboard Alpha (Lain)",
	},
})

local component_nav = require("config.component-navigation")

wk.add({
	{ "<leader>v", group = "Component Navigation" },
	{
		"<leader>vv",
		function()
			component_nav.navigate_to_component()
		end,
		desc = "→ Component file (.vue/.component.ts)",
		mode = "n",
	},
	{
		"<leader>vh", 
		function()
			component_nav.navigate_to_template()
		end,
		desc = "→ Template file (.html)",
		mode = "n",
	},
	{
		"<leader>vt",
		function()
			component_nav.navigate_to_script()
		end,
		desc = "→ Script/Logic file (.ts/.js)",
		mode = "n",
	},
	{
		"<leader>vs",
		function()
			component_nav.navigate_to_style()
		end,
		desc = "→ Style file (.scss/.css)",
		mode = "n",
	},
	{
		"<leader>ve",
		function()
			component_nav.navigate_to_test()
		end,
		desc = "→ Test/Spec file (.spec.ts)",
		mode = "n",
	},
	{
		"<leader>vf",
		function()
			component_nav.show_related_files()
		end,
		desc = "📋 List all component files",
		mode = "n",
	},
})

-- flash.nvim (setup() no crea ningún mapeo por su cuenta)
wk.add({
	{
		"s",
		function()
			require("flash").jump()
		end,
		desc = "Flash",
		mode = { "n", "x", "o" },
	},
	{
		"S",
		function()
			require("flash").treesitter()
		end,
		desc = "Flash Treesitter",
		mode = { "n", "x", "o" },
	},
	{
		"r",
		function()
			require("flash").remote()
		end,
		desc = "Remote Flash",
		mode = "o",
	},
	{
		"R",
		function()
			require("flash").treesitter_search()
		end,
		desc = "Treesitter Search",
		mode = { "o", "x" },
	},
})

-- ===== ENHANCED GOTO DEFINITION =====
-- Override 'gd' with smart component-aware navigation

wk.add({
	{
		"gd",
		function()
			component_nav.smart_goto_definition()
		end,
		desc = "Smart Go to Definition (Component-aware)",
		mode = "n",
	},
})
