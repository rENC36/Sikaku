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
	easy = {
		-- Пастельный зелёный
		active = vmath.vector4(0.78, 0.92, 0.83, 1.0),

		-- Серо-голубой для неактивной кнопки
		inactive = vmath.vector4(0.78, 0.81, 0.87, 0.4),
	},

	medium = {
		-- Пастельный жёлтый
		active = vmath.vector4(0.98, 0.91, 0.70, 1.0),

		-- Серо-голубой для неактивной кнопки
		inactive = vmath.vector4(0.78, 0.81, 0.87, 0.4),
	},

	hard = {
		-- Пастельный розово-коралловый
		active = vmath.vector4(0.96, 0.78, 0.80, 1.0),

		-- Серо-голубой для неактивной кнопки
		inactive = vmath.vector4(0.78, 0.81, 0.87, 0.4),
	},
}

M.CATEGORY_LINE_COLORS = {
	easy = vmath.vector4(0.62, 0.87, 0.70, 0.80),
	medium = vmath.vector4(0.98, 0.88, 0.55, 0.80),
	hard = vmath.vector4(0.95, 0.72, 0.75, 0.80),
}

M.CATEGORY_LINE_HEIGHT = 6
M.CATEGORY_LINE_GAP = 13
M.CATEGORY_LINE_ANIMATION_TIME = 0.25

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