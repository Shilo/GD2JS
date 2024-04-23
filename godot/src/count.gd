class_name CountLabel extends Label

func _ready():
	GD2JS.js_connect(GD2JS.EventType.META_CHANGED, func(meta, value, _old_value):
		if meta != "count": return
		
		text = str(value)
	)
	
	GD2JS.js_set_meta("count", randi_range(0, 100))
