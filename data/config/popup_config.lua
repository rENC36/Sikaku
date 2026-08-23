local M = {}

M.types = {
	hint_confirm_endless = {
		title = "popup_hint_title",
		text = "popup_hint_text",
		yes_label = "popup_use",
		no_label = "popup_cancel",
		show_yes = true,
		show_no = true,
		yes_event = "use_hint_endless",
		no_event = nil,
		pause_input = true,
	},

	hint_confirm_blitz = {
		title = "popup_hint_title",
		text = "popup_hint_text",
		yes_label = "popup_use",
		no_label = "popup_cancel",
		show_yes = true,
		show_no = true,
		yes_event = "use_hint_blitz",
		no_event = nil,
		pause_input = true,
	},

	exit_confirm = {
		title = "popup_exit_title",
		text = "popup_exit_text",
		yes_label = "popup_yes",
		no_label = "popup_no",
		show_yes = true,
		show_no = true,
		yes_event = "back_to_menu",
		no_event = nil,
		pause_input = true,
	},

	hint_confirm = {
		title = "popup_hint_title",
		text = "popup_hint_text",
		yes_label = "popup_use",
		no_label = "popup_cancel",
		show_yes = true,
		show_no = true,
		yes_event = "use_hint",
		no_event = nil,
		pause_input = true,
	},

	no_hints = {
		title = "popup_no_hints_title",
		text = "popup_no_hints_text",
		yes_label = "popup_ok",
		no_label = nil,
		show_yes = true,
		show_no = true,
		yes_event = nil,
		no_event = nil,
		pause_input = true,
	},
}

return M