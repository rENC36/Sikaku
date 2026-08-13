local M = {}

M.GRID = {
	COLS      = 5,
	ROWS      = 2,
	GAP       = 64,
	CELL_SIZE = 150,
}

M.ATLAS = {
	NAME  = "game",
	FRAME = "btn_lvl_3", -- Это дефолтный фон кнопки
}

-- НАСТРОЙКИ СОСТОЯНИЙ КНОПОК
M.STATUS = {
	COMPLETED = {
		BG_COLOR   = vmath.vector4(0.8, 1.00, 0.8, 1), -- Бледно-зеленый
		TEXT_COLOR = vmath.vector4(0.20, 0.20, 0.40, 1),
		ICON       = "lvl_done_3",
		ICON_COLOR = vmath.vector4(1, 1, 1, 1),    -- Зеленая галочка
	},
	UNLOCKED = {
		BG_COLOR   = vmath.vector4(1.00, 1.00, 1.00, 1), -- Белый
		TEXT_COLOR = vmath.vector4(0.20, 0.20, 0.40, 1),
		ICON       = nil,
		ICON_COLOR = vmath.vector4(1, 1, 1, 1),
	},
	LOCKED = {
		BG_COLOR   = vmath.vector4(0.7, 0.7, 0.7, 1), -- Светло-серый
		TEXT_COLOR = vmath.vector4(0.50, 0.50, 0.50, 1),
		ICON       = "lvl_closed_3",
		ICON_COLOR = vmath.vector4(1, 1, 1, 0.6), 
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

M.CATEGORY_COLORS = {
	-- Легкая: ярко-зеленый -> бледно-зеленый
	easy   = { 
		active   = vmath.vector4(0.85, 0.98, 0.85, 1), 
		inactive = vmath.vector4(0.7, 0.7, 0.7, 0.4) 
	},
	-- Средняя: ярко-желтый -> бледно-желтый
	medium = { 
		active   = vmath.vector4(0.98, 0.98, 0.80, 1), 
		inactive = vmath.vector4(0.7, 0.7, 0.7, 0.4) 
	},
	-- Тяжелая: ярко-красный -> бледно-красный
	hard   = { 
		active   = vmath.vector4(0.98, 0.85, 0.85, 1), 
		inactive = vmath.vector4(0.7, 0.7, 0.7, 0.4) 
	},
}

return M