-- hide LSP progress messages (e.g. jdtls "Validate documents") in the bottom right corner
return {
	"folke/noice.nvim",
	opts = {
		lsp = {
			progress = {
				enabled = false,
			},
		},
	},
}
