local M = {}

M.GAME_UI_BUTTONS = {
	{ node = "btn_menu", message = "back_to_menu" },
}

M.BOARD_VIEW = {
	cell_size = 64,
	spacing   = 4,
}

M.FACTORIES = {
	cell       = "/Factories#cellfactory",
	preview_bg = "/Factories#selection_bg_factory",
	overlay    = "/Factories#selection_bg_factory",
	badge      = "/Factories#badge_factory",
	board_bg   = "/Factories#grid_bg_factory",
}

return M