class_name CountLabel extends Label

var value: int:
	set(new_value):
		text = str(new_value)
	get:
		return int(text)

func _ready():
	# todo
	pass
