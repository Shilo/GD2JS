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

var _gd_eval_callback: JavaScriptObject

func _init() -> void:
	if !enabled: return
	
	var js_script: GDScript = load(_js_script_path)
	JavaScriptBridge.eval(js_script.js)

func _is_enabled() -> bool:
	if (!enabled):
		push_warning("[GDJS] Feature not allowed in non-web build.")
	return enabled

func eval(code: String, use_global_execution_context: bool = false) -> Variant:
	if !_is_enabled(): return
	
	return JavaScriptBridge.eval(code, use_global_execution_context)

func set_gd_eval(enable: bool) -> void:
	if !_is_enabled(): return
	
	_gd_eval_callback = JavaScriptBridge.create_callback(_gd_eval) if enable else null
	gd2js._eval = _gd_eval_callback

func _gd_eval(code: Array) -> Error:
	var error: Error
	
	for code_block in code:
		var script := GDScript.new()
		script.source_code = "static func _static_init():\n\t" + code_block.strip_edges().replace("\n", ";")
		var err = script.reload()
		if err: error = err
	
	return error
