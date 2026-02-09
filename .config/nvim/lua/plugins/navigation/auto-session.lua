return {
	"rmagatti/auto-session",
	config = function()
		require("auto-session").setup({
			-- Configuración moderna y confiable
			auto_save_enabled = true, -- Guarda automático siempre
			auto_restore_enabled = true, -- Restaura automático siempre
			auto_create_enabled = true, -- Crear sesiones automáticamente

			-- CLAVE: Habilitar auto-restore para `nvim .`
			auto_session_enable_last_session = true,

			-- Configuración estándar
			auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
			auto_session_suppress_dirs = {}, -- NO suprimir ningún directorio
			auto_session_use_git_branch = true, -- Sesiones por rama git
			log_level = "error", -- Sin logs molestos

			-- Session lens moderna
			session_lens = {
				load_on_setup = true,
				theme_conf = { border = true },
				previewer = false,
			},

			-- Hooks mínimos - auto-session maneja todo
			pre_save_cmds = {},
			post_restore_cmds = {},
		})
	end,
}