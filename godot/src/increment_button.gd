extends Button

func _ready():
	GD2JS.js_set_meta("unfocus_godot", _unfocus)

func _pressed():
	GD2JS.js_update_meta("value",
		func(value):
			value += 1
			GD2JS.js_emit_signal("value_changed", value)
			return value
	, 0)

func _unfocus():
	var focused_node := get_viewport().gui_get_focus_owner()
	if focused_node:
		focused_node.release_focus()
