extends Node

var enabled: bool = OS.has_feature("web"):
	set(__): pass

var window: JavaScriptObject = JavaScriptBridge.get_interface("parent"):
	set(__): pass

var js: JavaScriptObject:
	get: return window.GD2JS if window else null

var _js_script_path: String:
	get:
		var path: String = get_script().resource_path
		return path.insert(path.length() - 3, ".js")

var _gd_eval_callback: JavaScriptObject
var _callbacks: Dictionary

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
	js._eval = _gd_eval_callback

func _gd_eval(code: Array) -> Error:
	for code_block in code:
		var script := GDScript.new()
		script.source_code = "static func _static_init():" + code_block.strip_edges().replace("\n", ";")
		
		var error := script.reload()
		if error:
			return error
	
	return OK

func js_connect(type: String, callable: Callable, options: Variant = false) -> JavaScriptObject:
	if !_is_enabled(): return
	
	var wrapped_callback := JavaScriptBridge.create_callback(func(args): callable.callv(args))
	var result: JavaScriptObject = js.addEventListener(type, wrapped_callback, options)
	
	if !_callbacks[type]:
		_callbacks[type] = []
	_callbacks[type].push_back({
		"callback": callable,
		"wrapped_callback": wrapped_callback
	})
	
	return result

func js_is_connected(type: String, callable: Callable) -> bool:
	if !_is_enabled(): return false
	
	return js.isEventListener(type, callable)

func js_disconnect(type: String, callable: Callable, options: Variant = false) -> bool:
	if !_is_enabled(): return false
	
	var callbacks: Array = _callbacks[type]
	if !callbacks: return false
	
	var index: int = -1
	var i: int = 0
	for c in callbacks:
		if c.callback == callable:
			index = i
			break
		i += 1
	if index == -1: return false
	
	var result = js.removeEventListener(type, callbacks[index].wrapped_callback, options)
	
	callbacks.remove_at(index)
	if callbacks.size() == 0:
		_callbacks.erase(type)
	
	return result

func js_disconnect_all(type: String = "") -> bool:
	if !_is_enabled(): return false
	
	if !type:
		for callback_type in _callbacks:
			js.removeAllEventListeners(callback_type)
		return true
	
	var result: bool = js.removeAllEventListeners(type)
	
	var callbacks = _callbacks[type]
	if callbacks:
		_callbacks.erase(type)
	
	return result

func js_emit_signal(type:String, arg1: Variant = NAN, arg2: Variant = NAN, arg3: Variant = NAN, arg4: Variant = NAN) -> JavaScriptObject:
	if !_is_enabled(): return
	
	if is_nan(arg1): return js.dispatchEvent(type)
	if is_nan(arg2): return js.dispatchEvent(type, arg1)
	if is_nan(arg3): return js.dispatchEvent(type, arg1, arg2)
	if is_nan(arg4): return js.dispatchEvent(type, arg1, arg2, arg3)
	return js.dispatchEvent(type, arg1, arg2, arg3, arg4)

func js_emit_signal_v(type:String, args: Array[Variant]) -> JavaScriptObject:
	if !_is_enabled(): return
	
	args.push_front(type)
	return js_emit_signal.callv(args)
