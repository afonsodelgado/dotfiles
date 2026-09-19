-- On Omarchy this file is a symlink that follows the system theme.
-- Here it is a plain file: change the colorscheme to taste.
return {
	{
		"folke/tokyonight.nvim",
		priority = 1000,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "tokyonight-night",
		},
	},
}
