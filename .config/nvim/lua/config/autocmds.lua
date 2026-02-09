-- AUTOCOMMANDS MINIMALISTAS PARA AUTO-SESSION + ALPHA
-- Prioridad absoluta: Auto-session > Alpha fallback
-- Sin lógica compleja, sin race conditions

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