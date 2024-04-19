class_name GD2JS extends Object

static var ENABLED: bool = OS.has_feature("web")

static func _static_init() -> void:
	if !_is_enabled(): return
	
	print("is web")

static func add_event_listener() -> void:
	pass

static func _is_enabled() -> bool:
	if (!ENABLED):
		push_warning("[GDJS] Feature not allowed in non-web build.")
	return ENABLED
