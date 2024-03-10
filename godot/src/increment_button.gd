extends Button

@export var count: CountLabel

func _pressed():
	count.value += 1
