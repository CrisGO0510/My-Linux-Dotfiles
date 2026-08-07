return {
	"rmagatti/auto-session",
	lazy = false, -- restaura la sesión en el arranque
	config = function()
		-- Configurar sessionoptions óptimo para auto-session
		vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
		
		require("auto-session").setup({
			-- Operación completamente automática
			enabled = true,
			auto_save = true,
			auto_restore = true,
			auto_create = true,
			
			-- APIs modernas (elimina warnings deprecation)
			legacy_cmds = false,
			
			-- Sesiones por directorio únicamente
			auto_session_use_git_branch = false,
			
			-- Guardar sesiones en todos los directorios
			suppressed_dirs = {},
			
			-- Limpieza automática
			auto_delete_empty_sessions = true,
			close_unsupported_windows = true,
			
			-- Notificación simple como solicitaste
			show_auto_restore_notif = true,
			log_level = "info", -- Permite ver mensajes de session
			
			-- Desactivar session lens (picker manual)
			session_lens = {
				load_on_setup = false,
			},
			
			-- Evitar guardar buffers problemáticos
			bypass_save_filetypes = { 
				"alpha", 
				"dashboard", 
				"help",
				"qf"
			},
		})
	end,
}