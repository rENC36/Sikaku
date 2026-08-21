local M = {}

M.TIME = {
	START      = 60,  
	BONUS      = 15,   
	CAP        = 60,  
}

M.SCORE = {
	BONUS      = 25,
}

M.GRID = {
	START_SIZE = 5,  
	MAX_SIZE   = 10, 
	GROW_EVERY = 125,
}

M.COLORS = {
	TIMER_NORMAL  = vmath.vector4(1, 1, 1, 1),
	TIMER_WARNING = vmath.vector4(1, 0.3, 0.3, 1), 
	TIMER_DANGER  = vmath.vector4(1, 0, 0, 1),
}

M.WARNING = {
	LOW_TIME  = 10, 
	CRITICAL  = 5,  
}

return M