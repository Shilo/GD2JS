class_name CountLabel extends Label

func _ready():
	GD2JS.js_connect("gd2js-meta-changed", func(name, value, old_value):
		if name != "count": return
		
		text = str(value)
	)
	
	GD2JS.js_set_meta("count", randi_range(0, 100))
