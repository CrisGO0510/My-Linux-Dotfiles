-- prettierd es prettier corriendo como demonio: evita pagar el arranque de
-- Node en cada guardado (~100ms -> ~40ms). Si no está instalado en la máquina,
-- stop_after_first hace que caiga solo a prettier.
local prettier = { "prettierd", "prettier", stop_after_first = true }

return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
				rust = { "rustfmt" },
				javascript = prettier,
				typescript = prettier,
				html = prettier,
				htmlangular = prettier,
				css = prettier,
				json = prettier,
				scss = prettier,
				vue = prettier,
			},
		},
	},
}
