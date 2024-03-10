extends Button

@export var count: CountLabel

func _pressed():
	count.value += 2
	if DisplayServer.virtual_keyboard_get_height() > 0:
		DisplayServer.virtual_keyboard_hide()
	else:
		DisplayServer.virtual_keyboard_show("")
