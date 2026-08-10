local M = {}

M.COLOR_DEFAULT = vmath.vector4(1, 1, 1, 1)

M.GENERATOR = {
	first_s              = 0.30,
	first_v              = 0.95,
	loop_s_min           = 0.25,
	loop_s_max           = 0.50,
	loop_v_min           = 0.88,
	loop_v_max           = 0.98,
	fallback_s           = 0.30,
	fallback_v           = 0.92,
	similarity_threshold = 0.35,
	max_attempts         = 30,
}

return M