local M = {}

M.GAME_UI_BUTTONS = {
	{ node = "btn_menu", message = "back_to_menu" },
}

M.BOARD_VIEW = {
	cell_size      = 84,
	spacing        = 6,
	base_cell_size = 64,
	label_offset_y = -6,
}

M.FACTORIES = {
	cell       = "/Factories#cellfactory",
	preview_bg = "/Factories#selection_bg_factory",
	overlay    = "/Factories#selection_bg_factory",
	badge      = "/Factories#badge_factory",
	board_bg   = "/Factories#grid_bg_factory",
}

return M