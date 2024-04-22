class_name CountLabel extends Label

func _ready():
	GD2JS.js_connect("value_changed", func(value):
		text = str(value)
	)
	
	var initial_value: int = randi_range(0, 100)
	GD2JS.js_set_meta("value", initial_value)
	GD2JS.js_emit_signal("value_changed", initial_value)
