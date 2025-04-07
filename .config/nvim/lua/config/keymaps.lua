-- Definir una configuración común
local opts = { noremap = true, silent = true }
local map = vim.keymap.set
local wk = require("which-key")

-- Evita que <Space> haga algo
map("n", "<Space>", "<NOP>", opts)
vim.g.mapleader = " " -- Define <Space> como tecla líder

map("t", "<C-Esc>", "<C-\\><C-n>", opts)
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Quitar resaltado de búsqueda" })

-- cmp.lua
wk.add({
	{ "<C-Space>", [[cmp#complete()]], desc = "Abrir autocompletado manualmente" },
	{ "<C-n>", [[cmp#select_next_item()]], desc = "Seleccionar el siguiente ítem en el autocompletado" },
	{ "<C-p>", [[cmp#select_prev_item()]], desc = "Seleccionar el ítem anterior" },
	{ "<Tab>", [[cmp#confirm({select = true})]], desc = "Confirmar selección de ítem" },
}, { mode = "i" })

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
-- copilot.lua

wk.add({
	{
		"<Tab>",
		function()
			return require("copilot.suggestion").accept()
		end,
		desc = "Aceptar sugerencia",
		mode = "i",
		expr = true,
		silent = true,
	},
	{
		"<C-n>",
		function()
			require("copilot.suggestion").next()
		end,
		desc = "Siguiente sugerencia",
		mode = "i",
	},
	{
		"<C-p>",
		function()
			require("copilot.suggestion").prev()
		end,
		desc = "Sugerencia anterior",
		mode = "i",
	},
	{
		"<C-x>",
		function()
			require("copilot.suggestion").dismiss()
		end,
		desc = "Cerrar sugerencia",
		mode = "i",
	},
})

wk.add({
	{ "<leader>a", group = "AI" },

	-- Chat general
	{
		"<leader>aa",
		"<cmd>AvanteAsk<CR>",
		desc = "Abrir Chat de Avante",
		mode = { "n", "v" },
	},

	-- Refactorizar
	{
		"<leader>ar",
		"<cmd>AvanteAsk refactoriza<CR>",
		desc = "Refactorizar código",
		mode = { "n", "v" },
	},

	-- Anotaciones de tipo
	{
		"<leader>ad",
		"<cmd>AvanteAsk agrega tipos<CR>",
		desc = "Agregar anotaciones de tipo",
		mode = { "n", "v" },
	},

	-- Sugerir nombre
	{
		"<leader>an",
		"<cmd>AvanteAsk nombra esta función<CR>",
		desc = "Sugerir nombre para función",
		mode = { "n", "v" },
	},

	-- Explicar
	{
		"<leader>ae",
		"<cmd>AvanteAsk explica<CR>",
		desc = "Explicar código",
		mode = { "n", "v" },
	},

	-- Traducir
	{
		"<leader>at",
		"<cmd>AvanteAsk traduce al español<CR>",
		desc = "Traducir al español",
		mode = { "n", "v" },
	},

	-- Documentar
	{
		"<leader>ac",
		"<cmd>AvanteAsk documenta<CR>",
		desc = "Documentar código",
		mode = { "n", "v" },
	},
})
wk.add({
	{
		"<C-s>",
		function()
			vim.cmd("w") -- Guarda el archivo
			require("conform").format({ async = true }) -- Formatea el archivo
		end,
		desc = "Guardar y formatear",
	},
}, { mode = { "n", "i" } })
-- snacks.lua

wk.add({
	{
		"<leader>,",
		function()
			require("snacks").picker.buffers()
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

-- goto

wk.add({
	{
		"gd",
		function()
			require("snacks").picker.lsp_definitions()
		end,
		desc = "Goto Definition",
	},
	{
		"gD",
		function()
			require("snacks").picker.lsp_declarations()
		end,
		desc = "Goto Declaration",
	},
	{
		"gr",
		function()
			require("telescope.builtin").lsp_references({})
		end,
		desc = "References Telescope",
	},
	{
		"gI",
		function()
			require("snacks").picker.lsp_implementations()
		end,
		desc = "Goto Implementation",
	},
	{
		"gy",
		function()
			require("snacks").picker.lsp_type_definitions()
		end,
		desc = "Goto Type Definition",
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
			vim.api.nvim_buf_delete(0, { force = true })
		end,
		desc = "Cerrar buffer actual",
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
})
