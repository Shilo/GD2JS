const js := """
(function () {
	if (parent.GD2JS) return

	const self = {
		metadata: {},
		_listeners: {},

		setMeta: (name, value) => self.metadata[name] = value,
		removeMeta: (name) => delete self.metadata[name],
		clearAllMeta: () => self.metadata = {},
		getMeta: (name, defaultValue = null) => self.metadata[name] ?? defaultValue,
		callMeta: (name, ...args) => {
			const value = self.getMeta(name)
			if (typeof value === 'function')
				return value(...args)

			console.warn(`GD2JS: Meta "${name}" is not a function.`)
			return undefined
		},
		callMetaV: (name, argsArray) => {
			const value = self.getMeta(name)
			if (typeof value === 'function')
				return value(...argsArray)

			console.warn(`GD2JS: Meta "${name}" is not a function.`)
			return undefined
		},
		hasMeta: (name) => self.metadata.hasOwnProperty(name),
		getMetaKeys: () => JSON.stringify(Object.keys(self.metadata)),
		getMetaData: () => JSON.stringify(self.metadata),

		addEventListener: (type, listener, options) => {
			const wrappedListener = (event) => listener(...event.detail)
			document.addEventListener(type, wrappedListener, options)

			if (!self._listeners[type])
				self._listeners[type] = []
			self._listeners[type].push({ listener, wrappedListener })

			return wrappedListener
		},
		isEventListener: (type, listener) => {
			const listeners = self._listeners[type]
			if (!listeners) return false
			return listeners.some(l => l.listener === listener)
		},
		removeEventListener: (type, listener, options) => {
			const listeners = self._listeners[type]
			if (!listeners) return false

			const index = listeners.findIndex(l => l.listener === listener)
			if (index === -1) return false

			document.removeEventListener(type, listeners[index].wrappedListener, options)

			listeners.splice(index, 1)
			if (listeners.length === 0)
				delete self._listeners[type]

			return true
		},
		removeAllEventListeners: (type) => {
			if (!type) {
				Object.keys(self._listeners).forEach(type => self.removeAllEventListeners(type))
				return true
			}

			const listeners = self._listeners[type]
			if (!listeners) return false

			listeners.forEach(l => document.removeEventListener(type, l.wrappedListener))
			delete self._listeners[type]
			return true
		},
		dispatchEvent: (event, ...args) => {
			if (!(event instanceof Event || typeof event === 'Event'))
				event = new CustomEvent(event.toString(), { detail: args })
			return document.dispatchEvent(event)
		},
		dispatchEventV: (event, argsArray) => {
			if (!(event instanceof Event || typeof event === 'Event'))
				event = new CustomEvent(event.toString(), { detail: argsArray })
			return document.dispatchEvent(event)
		},

		_eval: null,
		eval: (...code) => self._eval ? self._eval(...code) : console.warn('GD2JS: Eval is disabled.'),

		// Convenience methods for Godot style.

		set_meta: (...args) => self.setMeta.apply(null, args),
		remove_meta: (...args) => self.removeMeta.apply(null, args),
		clear_all_meta: (...args) => self.clearAllMeta.apply(null, args),
		get_meta: (...args) => self.getMeta.apply(null, args),
		call_meta: (...args) => self.callMeta.apply(null, args),
		call_meta_v: (...args) => self.callMetaV.apply(null, args),
		has_meta: (...args) => self.hasMeta.apply(null, args),
		get_meta_list: (...args) => self.getMetaKeys.apply(null, args),
		get_meta_data: (...args) => self.getMetaData.apply(null, args),

		connect: (...args) => self.addEventListener.apply(null, args),
		is_connected: (...args) => self.isEventListener.apply(null, args),
		disconnect: (...args) => self.removeEventListener.apply(null, args),
		disconnect_all: (...args) => self.removeAllEventListeners.apply(null, args),
		emit_signal: (...args) => self.dispatchEvent.apply(null, args),
		emit_signal_v: (...args) => self.dispatchEventV.apply(null, args),
	}
	parent.GD2JS = self
}())
"""
