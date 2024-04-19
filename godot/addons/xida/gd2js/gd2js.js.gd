const js := """
(function () {
	const self = {
		metadata: {},

		setMeta: (name, value) => self.metadata[name] = value,
		removeMeta: (name) => delete self.metadata[name],
		clearMeta: () => self.metadata = {},
		getMeta: (name, defaultValue = null) => self.metadata[name] ?? defaultValue,
		hasMeta: (name) => self.metadata.hasOwnProperty(name),
		getMetaKeys: () => Object.keys(self.metadata),

		addEventListener: (type, listener, options) => document.addEventListener(type, listener, options),
		removeEventListener: (type, listener, options) => document.removeEventListener(type, listener, options),
		dispatchEvent: (event, ...args) => {
			// TODO: Allow arguments passed directly to addEventListener
			if (!(event instanceof Event || typeof event === 'Event'))
				event = new CustomEvent(event.toString(), { detail: args })
			document.dispatchEvent(event)
		},

		// Convenience methods for Godot style.

		set_meta: (...args) => self.setMeta.apply(null, args),
		remove_meta: (...args) => self.removeMeta.apply(null, args),
		clear_meta: (...args) => self.clearMeta.apply(null, args),
		get_meta: (...args) => self.getMeta.apply(null, args),
		has_meta: (...args) => self.hasMeta.apply(null, args),
		get_meta_list: (...args) => self.getMetaKeys.apply(null, args),

		connect: (...args) => self.addEventListener.apply(null, args),
		disconnect: (...args) => self.removeEventListener.apply(null, args),
		emit_signal: (...args) => self.dispatchEvent.apply(null, args),
	}
	parent.GD2JS = self
}());
"""
