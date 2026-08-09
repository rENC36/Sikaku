local V3 = vmath.vector3

return {
	btn_start = {
		default   = { scale = V3(1, 1, 1) },
		hover     = { scale = V3(1.06, 1.06, 1), duration = 0.02, easing = gui.EASING_OUTQUAD, cancel = true },
		hover_off = { scale = V3(1, 1, 1),       duration = 0.12, easing = gui.EASING_OUTQUAD, cancel = true },
		pressed   = { scale = V3(0.92, 0.92, 1), duration = 0.005, easing = gui.EASING_OUTQUAD, cancel = true },
		released  = { scale = V3(1, 1, 1),       duration = 0.02,  easing = gui.EASING_OUTBACK, cancel = true },
	},

	btn_leaderboard = {
		default   = { scale = V3(1, 1, 1) },
		hover     = { scale = V3(1.06, 1.06, 1), duration = 0.12, easing = gui.EASING_OUTQUAD, cancel = true },
		hover_off = { scale = V3(1, 1, 1),       duration = 0.12, easing = gui.EASING_OUTQUAD, cancel = true },
		pressed   = { scale = V3(0.92, 0.92, 1), duration = 0.05, easing = gui.EASING_OUTQUAD, cancel = true },
		released  = { scale = V3(1, 1, 1),       duration = 0.2,  easing = gui.EASING_OUTBACK, cancel = true },
	},

	btn_menu = {
		default   = { scale = V3(1, 1, 1) },
		hover     = { scale = V3(1.06, 1.06, 1), duration = 0.12, easing = gui.EASING_OUTQUAD, cancel = true },
		hover_off = { scale = V3(1, 1, 1),       duration = 0.12, easing = gui.EASING_OUTQUAD, cancel = true },
		pressed   = { scale = V3(0.92, 0.92, 1), duration = 0.05, easing = gui.EASING_OUTQUAD, cancel = true },
		released  = { scale = V3(1, 1, 1),       duration = 0.2,  easing = gui.EASING_OUTBACK, cancel = true },
	},

	btn_mode = {
		default   = { scale = V3(1, 1, 1) },
		hover     = { scale = V3(1.1, 1.1, 1), duration = 0.12, easing = gui.EASING_OUTQUAD, cancel = true },
		hover_off = { scale = V3(1, 1, 1),       duration = 0.12, easing = gui.EASING_OUTQUAD, cancel = true },
		pressed   = { scale = V3(.8, .8, 1), duration = 0.05, easing = gui.EASING_OUTQUAD, cancel = true },
		released  = { scale = V3(.95, .95, 1),       duration = 0.2,  easing = gui.EASING_OUTBACK, cancel = true },
	},
}