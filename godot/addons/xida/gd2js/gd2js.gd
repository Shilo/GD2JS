extends Node

const JS_UNDEFINED: float = NAN

const EventType: Dictionary = {
	"LOADED": "gd2js-loaded",
	"META_CHANGED": "gd2js-meta-changed"
}

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
var _event_callbacks: Dictionary
var _meta_callables: Dictionary

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

func js_eval(code: String, use_global_execution_context: bool = false) -> Variant:
	return JavaScriptBridge.eval(code, use_global_execution_context)

func js_set_meta(name: String, value: Variant) -> Variant:
	if !_is_enabled(): return
	value = js_variant(value)
	
	if value is Callable:
		var callable: Callable = value
		value = JavaScriptBridge.create_callback(func(args: Array):
			var resolve: JavaScriptObject = args.pop_back()
			
			var result: Variant = callable.callv(args)
			
			if resolve && resolve.resolve:
				resolve.resolve(result)
			return result
		)
		_meta_callables[name] = {"callable": callable, "wrapped_callable": value}
	
	return js.setMeta(name, value)

func js_update_meta(name: String, updater: Callable, default: Variant = null) -> Variant:
	if !_is_enabled(): return
	
	var js_updater: JavaScriptObject = JavaScriptBridge.create_callback(func(args: Array):
		var resolve: JavaScriptObject = args.pop_back()
		
		var result = updater.callv(args)
		
		resolve.resolve(result)
		return result
	)
	
	return js.updateMetaAsync(name, js_updater, default)

func js_remove_meta(name: String) -> bool:
	if !_is_enabled(): return false
	
	if _meta_callables.has(name):
		_meta_callables[name] = null
	
	return js.removeMeta(name)

func js_clear_all_meta() -> Variant:
	if !_is_enabled(): return
	
	_meta_callables.clear()
	return js.clearAllMeta()

func js_get_meta(name: String, default: Variant = null) -> Variant:
	if !_is_enabled(): return
	default = js_variant(default)
	
	return js.getMeta(name, default)

func js_call_meta(name:String, arg1: Variant = JS_UNDEFINED, arg2: Variant = JS_UNDEFINED, arg3: Variant = JS_UNDEFINED, arg4: Variant = JS_UNDEFINED) -> Variant:
	if !_is_enabled(): return
	
	if _meta_callables.has(name):
		var callable: Callable = _meta_callables[name].callable
		if _is_undefined(arg1): return callable.call()
		if _is_undefined(arg2): return callable.call(arg1)
		if _is_undefined(arg3): return callable.call(arg1, arg2)
		if _is_undefined(arg4): return callable.call(arg1, arg2, arg3)
		return callable.call(arg1, arg2, arg3, arg4)
	
	arg1 = js_variant(arg1)
	arg2 = js_variant(arg2)
	arg3 = js_variant(arg3)
	arg4 = js_variant(arg4)
	
	if _is_undefined(arg1): return js.callMetaAsync(name)
	if _is_undefined(arg2): return js.callMetaAsync(name, arg1)
	if _is_undefined(arg3): return js.callMetaAsync(name, arg1, arg2)
	if _is_undefined(arg4): return js.callMetaAsync(name, arg1, arg2, arg3)
	return js.callMetaAsync(name, arg1, arg2, arg3, arg4)

func js_call_meta_v(name:String, args: Array[Variant]) -> Variant:
	if !_is_enabled(): return
	
	if _meta_callables.has(name):
		var callable: Callable = _meta_callables[name].callable
		return callable.callv(args)
	
	args = js_variant(args)
	
	return js.callMetaVAsync(name, args)

func js_has_meta(name: String) -> bool:
	if !_is_enabled(): return false
	
	return js.hasMeta(name)

func js_get_meta_list() -> Array:
	if !_is_enabled(): return []
	
	return str_to_var(js.getMetaKeys())

func js_get_meta_data() -> Dictionary:
	if !_is_enabled(): return {}
	
	return str_to_var(js.getMetaData())

func js_connect(type: String, callable: Callable, options: Variant = false) -> JavaScriptObject:
	if !_is_enabled(): return
	options = js_variant(options)
	
	var wrapped_callback := JavaScriptBridge.create_callback(func(args): callable.callv(args))
	var result: JavaScriptObject = js.addEventListener(type, wrapped_callback, options)
	
	if !_event_callbacks.has(type):
		_event_callbacks[type] = []
	_event_callbacks[type].push_back({
		"callback": callable,
		"wrapped_callback": wrapped_callback
	})
	
	return result

func js_is_connected(type: String, callable: Callable) -> bool:
	if !_is_enabled(): return false
	
	return js.isEventListener(type, callable)

func js_disconnect(type: String, callable: Callable, options: Variant = false) -> bool:
	if !_is_enabled(): return false
	options = js_variant(options)
	
	var callbacks: Array = _event_callbacks.get(type)
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
		_event_callbacks.erase(type)
	
	return result

func js_disconnect_all(type: String = "") -> bool:
	if !_is_enabled(): return false
	
	if !type:
		for callback_type in _event_callbacks:
			js.removeAllEventListeners(callback_type)
		return true
	
	var result: bool = js.removeAllEventListeners(type)
	
	var callbacks = _event_callbacks.get(type)
	if callbacks:
		_event_callbacks.erase(type)
	
	return result

func js_emit_signal(type:String, arg1: Variant = JS_UNDEFINED, arg2: Variant = JS_UNDEFINED, arg3: Variant = JS_UNDEFINED, arg4: Variant = JS_UNDEFINED) -> Variant:
	if !_is_enabled(): return
	arg1 = js_variant(arg1)
	arg2 = js_variant(arg2)
	arg3 = js_variant(arg3)
	arg4 = js_variant(arg4)
	
	if _is_undefined(arg1): return js.dispatchEvent(type)
	if _is_undefined(arg2): return js.dispatchEvent(type, arg1)
	if _is_undefined(arg3): return js.dispatchEvent(type, arg1, arg2)
	if _is_undefined(arg4): return js.dispatchEvent(type, arg1, arg2, arg3)
	return js.dispatchEvent(type, arg1, arg2, arg3, arg4)

func js_emit_signal_v(type:String, args: Array[Variant]) -> Variant:
	if !_is_enabled(): return
	args = js_variant(args)
	
	return js.dispatchEventV(type, args)

func js_variant(variant: Variant) -> Variant:
	if variant is Array:
		var array: JavaScriptObject = JavaScriptBridge.create_object("Array")
		for value in variant:
			array.push(value)
		return array
	
	if variant is Dictionary:
		var dictionary: JavaScriptObject = JavaScriptBridge.create_object("Object")
		for key in variant:
			dictionary[key] = variant[key]
		return dictionary
	
	return variant

func _is_undefined(value: Variant) -> bool:
	return value is float && is_nan(value)
