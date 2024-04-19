class_name GD2JS extends Object

static var enabled: bool = OS.has_feature("web"):
	set(__): pass

static var window: JavaScriptObject = JavaScriptBridge.get_interface("parent"):
	set(__): pass

static var gd2js: JavaScriptObject:
	get: return window.GD2JS if window else null
	set(__): pass

static func _static_init() -> void:
	if !_is_enabled(): return
	
	var js_script: GDScript = load("res://addons/xida/gd2js/gd2js.js.gd")
	JavaScriptBridge.eval(js_script.js)

static func add_event_listener() -> void:
	pass

static func _is_enabled() -> bool:
	if (!enabled):
		push_warning("[GDJS] Feature not allowed in non-web build.")
	return enabled
