local M = {}

M.types = {
	hint_confirm_endless = {
		title = "Подсказка",
		text = "Использовать подсказку?\nОсталось: {balance}",
		yes_label = "Использовать",
		no_label = "Отмена",
		show_yes = true,
		show_no = true,
		yes_event = "use_hint_endless",
		no_event = nil,
		pause_input = true,
	},

	hint_confirm_blitz = {
		title = "Подсказка",
		text = "Использовать подсказку?\nОсталось: {balance}",
		yes_label = "Использовать",
		no_label = "Отмена",
		show_yes = true,
		show_no = true,
		yes_event = "use_hint_blitz",
		no_event = nil,
		pause_input = true,
	},
	
	exit_confirm = {
		title = "Выход",
		text = "Выйти в главное меню?\nПрогресс уровня не сохранится.",
		yes_label = "Да",
		no_label = "Нет",
		show_yes = true,
		show_no = true,
		yes_event = "back_to_menu",
		no_event = nil,
		pause_input = true,
	},
	
	hint_confirm = {
		title = "Подсказка",
		text = "Использовать подсказку?\nОсталось: {balance}",
		yes_label = "Использовать",
		no_label = "Отмена",
		show_yes = true,
		show_no = true,
		yes_event = "use_hint",
		no_event = nil,
		pause_input = true,
	},
	
	no_hints = {
		title = "Подсказки закончились",
		text = "У вас не осталось подсказок.",
		yes_label = "OK",
		no_label = nil,
		show_yes = true,
		show_no = true,
		yes_event = nil,
		no_event = nil,
		pause_input = true,
	},
}

return M