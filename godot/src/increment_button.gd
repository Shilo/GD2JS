extends Button

func _pressed():
	GD2JS.js_update_meta("value",
		func(value):
			value += 1
			GD2JS.js_emit_signal("value_changed", value)
			return value
	, 0)
