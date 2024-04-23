class_name CountLabel extends Label

func _ready():
	GD2JS.js_connect(GD2JS.EventType.META_CHANGED, func(name, value, old_value):
		if name != "count": return
		
		text = str(value)
	)
	
	GD2JS.js_set_meta("count", randi_range(0, 100))
