extends Button

@export var count: CountLabel

func _pressed():
	count.value += 3
	DisplayServer.virtual_keyboard_show("")
