local M = {}

M.GRID = {
	COLS      = 5,
	ROWS      = 2,
	GAP       = 64,
	CELL_SIZE = 150,
}

M.ATLAS = {
	NAME  = "game",
	FRAME = "btn_lvl_3",
}

M.STATUS = {
	COMPLETED = {
		BG_COLOR   = vmath.vector4(0.8, 1.00, 0.8, 1),
		TEXT_COLOR = vmath.vector4(0.20, 0.20, 0.40, 1),
		ICON       = "lvl_done_3",
		ICON_COLOR = vmath.vector4(1, 1, 1, 1),
	},
	UNLOCKED = {
		BG_COLOR   = vmath.vector4(1.00, 1.00, 1.00, 1),
		TEXT_COLOR = vmath.vector4(0.20, 0.20, 0.40, 1),
		ICON       = nil,
		ICON_COLOR = vmath.vector4(1, 1, 1, 1),
	},
	LOCKED = {
		BG_COLOR   = vmath.vector4(0.7, 0.7, 0.7, 1),
		TEXT_COLOR = vmath.vector4(0.50, 0.50, 0.50, 1),
		ICON       = "lvl_closed_3",
		ICON_COLOR = vmath.vector4(1, 1, 1, 0.6),
	},
}

M.CATEGORY_COLORS = {
	easy   = { 
		active   = vmath.vector4(0.85, 0.98, 0.85, 1), 
		inactive = vmath.vector4(0.7, 0.7, 0.7, 0.4) 
	},
	medium = { 
		active   = vmath.vector4(0.98, 0.98, 0.80, 1), 
		inactive = vmath.vector4(0.7, 0.7, 0.7, 0.4) 
	},
	hard   = { 
		active   = vmath.vector4(0.98, 0.85, 0.85, 1), 
		inactive = vmath.vector4(0.7, 0.7, 0.7, 0.4) 
	},
}

M.ANIM = {
	PRESSED = {
		scale    = vmath.vector3(0.9, 0.9, 1),
		duration = 0.05,
		easing   = gui.EASING_OUTQUAD,
		cancel   = true,
	},
	RELEASED = {
		scale    = vmath.vector3(1, 1, 1),
		duration = 0.2,
		easing   = gui.EASING_OUTBACK,
		cancel   = true,
	},
}

return M