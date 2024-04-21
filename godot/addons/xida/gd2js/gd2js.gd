extends Node

var enabled: bool = OS.has_feature("web"):
	set(__): pass

var window: JavaScriptObject = JavaScriptBridge.get_interface("parent"):
	set(__): pass

var gd2js: JavaScriptObject:
	get: return window.GD2JS if window else null

var _js_script_path: String:
	get:
		var path: String = get_script().resource_path
		return path.insert(path.length() - 3, ".js")

func _init() -> void:
	if !enabled: return
	
	var js_script: GDScript = load(_js_script_path)
	JavaScriptBridge.eval(js_script.js)

func add_event_listener() -> void:
	if !_is_enabled(): return
	
	pass

func _is_enabled() -> bool:
	if (!enabled):
		push_warning("[GDJS] Feature not allowed in non-web build.")
	return enabled
