return {
	-- Roslyn LSP: el LSP oficial de Microsoft para C# (reemplaza OmniSharp)
	{
		"seblyng/roslyn.nvim",
		ft = "cs",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			exe = "Microsoft.CodeAnalysis.LanguageServer",
			filewatching = true,
			settings = {
				["csharp|inlay_hints"] = {
					csharp_enable_inlay_hints_for_implicit_object_creation = true,
					csharp_enable_inlay_hints_for_implicit_variable_types = true,
					csharp_enable_inlay_hints_for_lambda_parameter_types = true,
					csharp_enable_inlay_hints_for_types = true,
				},
				["csharp|code_lens"] = {
					dotnet_enable_references_code_lens = true,
				},
				["csharp|completion"] = {
					dotnet_show_completion_items_from_unimported_namespaces = true,
					dotnet_show_name_completion_suggestions = true,
				},
			},
		},
	},
}
