local opts = { noremap = true, silent = true }
local map = vim.keymap.set
local wk = require("which-key")

-- Navegar por líneas visuales (útil cuando wrap está activo)
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Evita que <Space> haga algo
map("n", "<Space>", "<NOP>", opts)
vim.g.mapleader = " " -- Define <Space> como tecla líder

map("t", "<C-Esc>", "<C-\\><C-n>", opts)
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Quitar resaltado de búsqueda" })
map("n", "zl", "10zl", { desc = "Desplazar vista → 5 cols" })
map("n", "zh", "10zh", { desc = "Desplazar vista ← 5 cols" })
map("n", "<leader>q", "<cmd>:qall!<CR>", { desc = "Cerrar nvim" })

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
			require("snacks").notifier.notify("Word Wrap " .. status, "info", { title = "Interfaz" })
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
			require("snacks").notifier.notify("Copiado: " .. filename, "info", { title = "Clipboard" })
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

-- lua/keymaps/cmp_keys.lua
local ok_wk, wk = pcall(require, "which-key")
if not ok_wk then
	return
end

local ok_cmp, cmp = pcall(require, "cmp")
if not ok_cmp then
	return
end

local function has_words_before()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	if col == 0 then
		return false
	end
	local prev = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col)
	return not prev:match("%s")
end

local function t(keys)
	return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

local function feed(keys)
	vim.api.nvim_feedkeys(t(keys), "", true)
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
		function()
			cmp.select_next_item()
		end,
		desc = "Siguiente ítem",
		mode = "i",
	},
	{
		"<C-p>",
		function()
			cmp.select_prev_item()
		end,
		desc = "Ítem anterior",
		mode = "i",
	},
	{
		"<C-y>",
		function()
			cmp.confirm({ select = true })
		end,
		desc = "Aceptar sugerencia",
		mode = "i",
	},

	-- Scroll docs
	{
		"<C-b>",
		function()
			cmp.scroll_docs(-4)
		end,
		desc = "Docs atrás",
		mode = "i",
	},
	{
		"<C-f>",
		function()
			cmp.scroll_docs(4)
		end,
		desc = "Docs adelante",
		mode = "i",
	},

	{
		"<CR>",
		function()
			if cmp.visible() then
				cmp.confirm({ select = true })
			else
				feed("\n") -- salto de línea normal (arregla tu problema #2)
			end
		end,
		desc = "Confirmar si visible / nueva línea",
		mode = "i",
	},
})

-- copilot.lua

wk.add({
	{
		"<Tab>",
		function()
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

	-- Cerrar la ventana actual
	{
		"<leader>wd",
		function()
			vim.cmd("q")
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
	{ "<leader>f", group = "find" },
	{
		"<leader>fc",
		function()
			require("snacks").picker.files({ cwd = vim.fn.stdpath("config") })
		end,
		desc = "Find Config File",
	},
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
				-- Opcional: para que el buffer actual no aparezca en la lista
				ignore_current_buffer = true,
				sort_mru = true,
			})
		end,
		desc = "Buffers",
	},
	{ "<leader>/", "<cmd>Telescope live_grep<CR>", desc = "Grep" },
	{
		"<leader>:",
		function()
			require("snacks").picker.command_history()
		end,
		desc = "Command History",
	},
	{
		"<leader>n",
		function()
			require("snacks").picker.notifications()
		end,
		desc = "Notification History",
	},
})

wk.add({
	{ "<leader>f", group = "find" },

	{
		"<leader>fb",
		function()
			require("snacks").picker.buffers()
		end,
		desc = "Buffers",
	},
	{
		"<leader>fc",
		function()
			require("snacks").picker.files({ cwd = vim.fn.stdpath("config") })
		end,
		desc = "Find Config File",
	},
	{
		"<leader>ff",
		function()
			require("snacks").picker.files()
		end,
		desc = "Find Files",
	},
	{
		"<leader>fg",
		function()
			require("snacks").picker.git_files()
		end,
		desc = "Find Git Files",
	},
	{
		"<leader>fp",
		function()
			require("telescope").extensions.project.project({})
		end,
		desc = "Projects",
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

	{
		"<leader>gs",
		function()
			require("snacks").git_status()
		end,
		desc = "Git Status",
	},
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
	{
		"<leader>gb",
		function()
			require("snacks").picker.git_branches()
		end,
		desc = "Git Branches",
	},
	{
		"<leader>gl",
		function()
			require("snacks").picker.git_log()
		end,
		desc = "Git Log",
	},
	{
		"<leader>gL",
		function()
			require("snacks").picker.git_log_line()
		end,
		desc = "Git Log Line",
	},
	{
		"<leader>gS",
		function()
			require("snacks").picker.git_stash()
		end,
		desc = "Git Stash",
	},
	{
		"<leader>gd",
		function()
			require("snacks").picker.git_diff()
		end,
		desc = "Git Diff (Hunks)",
	},
	{
		"<leader>gf",
		function()
			require("snacks").picker.git_log_file()
		end,
		desc = "Git Log File",
	},
})

-- lsp

wk.add({
	{ "<leader>s", group = "search" },

	-- Funciones de búsqueda originales
	{
		"<leader>sb",
		function()
			require("snacks").picker.lines()
		end,
		desc = "Buffer Lines",
	},
	{
		"<leader>sB",
		function()
			require("snacks").picker.grep_buffers()
		end,
		desc = "Grep Open Buffers",
	},
	{
		"<leader>sg",
		function()
			require("snacks").picker.grep()
		end,
		desc = "Grep",
	},
	{
		"<leader>sw",
		function()
			require("snacks").picker.grep_word()
		end,
		desc = "Visual selection or word",
	},
	{
		'<leader>s"',
		function()
			require("snacks").picker.registers()
		end,
		desc = "Registers",
	},
	{
		"<leader>s/",
		function()
			require("snacks").picker.search_history()
		end,
		desc = "Search History",
	},
	{
		"<leader>sa",
		function()
			require("snacks").picker.autocmds()
		end,
		desc = "Autocmds",
	},
	{
		"<leader>sc",
		function()
			require("snacks").picker.command_history()
		end,
		desc = "Command History",
	},
	{
		"<leader>sC",
		function()
			require("snacks").picker.commands()
		end,
		desc = "Commands",
	},
	{
		"<leader>sd",
		function()
			require("snacks").picker.diagnostics()
		end,
		desc = "Diagnostics",
	},
	{
		"<leader>sD",
		function()
			require("snacks").picker.diagnostics_buffer()
		end,
		desc = "Buffer Diagnostics",
	},
	{
		"<leader>sh",
		function()
			require("snacks").picker.help()
		end,
		desc = "Help Pages",
	},
	{
		"<leader>sH",
		function()
			require("snacks").picker.highlights()
		end,
		desc = "Highlights",
	},
	{
		"<leader>si",
		function()
			require("snacks").picker.icons()
		end,
		desc = "Icons",
	},
	{
		"<leader>sj",
		function()
			require("snacks").picker.jumps()
		end,
		desc = "Jumps",
	},
	{
		"<leader>sk",
		function()
			require("snacks").picker.keymaps()
		end,
		desc = "Keymaps",
	},
	{
		"<leader>sl",
		function()
			require("snacks").picker.loclist()
		end,
		desc = "Location List",
	},
	{
		"<leader>sm",
		function()
			require("snacks").picker.marks()
		end,
		desc = "Marks",
	},
	{
		"<leader>sM",
		function()
			require("snacks").picker.man()
		end,
		desc = "Man Pages",
	},
	{
		"<leader>sp",
		function()
			require("snacks").picker.lazy()
		end,
		desc = "Search for Plugin Spec",
	},
	{
		"<leader>sq",
		function()
			require("snacks").picker.qflist()
		end,
		desc = "Quickfix List",
	},
	{
		"<leader>sR",
		function()
			require("snacks").picker.resume()
		end,
		desc = "Resume",
	},
	{
		"<leader>su",
		function()
			require("snacks").picker.undo()
		end,
		desc = "Undo History",
	},
	{
		"<leader>ss",
		function()
			require("snacks").picker.lsp_symbols()
		end,
		desc = "LSP Symbols",
	},
	{
		"<leader>sS",
		function()
			require("snacks").picker.lsp_workspace_symbols()
		end,
		desc = "LSP Workspace Symbols",
	},
})

-- UI

wk.add({
	{ "<leader>u", group = "ui" },

	{
		"<leader>uC",
		function()
			require("snacks").picker.colorschemes()
		end,
		desc = "Colorschemes",
	},
	{
		"<leader>un",
		function()
			require("snacks").notifier.hide()
		end,
		desc = "Dismiss All Notifications",
	},
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
	{
		"<leader>n",
		function()
			require("snacks").notifier.show_history()
		end,
		desc = "Notification History",
	},
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

wk.add({
	{
		"<leader> ",
		function()
			require("telescope.builtin").find_files()
		end,
		desc = "Find Files",
	},
	{
		"<leader>e",
		":Neotree toggle reveal=true position=left dir=" .. vim.fn.expand("%:p:h") .. "<CR>",
		desc = "Toggle NeoTree at CWD",
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
