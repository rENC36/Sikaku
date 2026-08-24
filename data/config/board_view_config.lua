local M = {}

M.PALETTE = {
	valid      = vmath.vector4(91 / 255, 217 / 255, 139 / 255, 1),
	invalid    = vmath.vector4(245 / 255, 95 / 255, 95 / 255, 1),
	badge_text = vmath.vector4(1, 1, 1, 1),
}

M.PREVIEW_FILL_ALPHA = 0.7
M.PLACED_FILL_ALPHA  = 1.0

M.BADGE = {
	min_size      = 24,
	max_size      = 38,
	size_ratio    = 0.85,
	valid_color   = vmath.vector4(0.08, 0.95, 0.35, 1),
	invalid_color = vmath.vector4(1.0, 0.12, 0.12, 1),
}

M.Z = {
	cell       = 0,
	placed_bg  = 0.06,
	preview_bg = 0.08,
	badge      = 0.3,
	board_bg   = -0.5,
}

M.BOARD_BG = {
	padding_ratio = 0.30,
	base_size     = 1024,
}

return M