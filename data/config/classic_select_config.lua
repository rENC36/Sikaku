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

M.COLORS = {
	COMPLETED_BG      = vmath.vector4(0.20, 0.85, 0.30, 1),
	COMPLETED_TEXT    = vmath.vector4(1.00, 1.00, 1.00, 1),
	UNLOCKED_BG       = vmath.vector4(1.00, 1.00, 1.00, 1),
	UNLOCKED_TEXT     = vmath.vector4(0.00, 0.00, 0.00, 1),
	LOCKED_BG         = vmath.vector4(0.25, 0.25, 0.25, 1),
	LOCKED_TEXT       = vmath.vector4(0.50, 0.50, 0.50, 1),
	CATEGORY_ACTIVE   = vmath.vector4(1.00, 1.00, 1.00, 1),
	CATEGORY_INACTIVE = vmath.vector4(0.50, 0.50, 0.50, 1),
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