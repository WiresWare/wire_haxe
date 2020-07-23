import { WireJS } from 'WireJS'
import WireData from 'WireData'

export default class Wire {
	
	constructor(scope, signal, listener, replies = 0) {
		this._ = new WireJS(scope, signal, listener, replies)
		this._.wrapper = this
	}
	
	get signal() { return this._._signal; }
	get hash() { return this._._hash; }
	get listener() { return this._._listener; }
	get scope() { return this._._scope; }
	get replies() { return this._.replies; }
	
	transfer(data) { this._.transfer(data) }
	clear() { this._.clear() }
	
	static get(signal, scope, listener, hash) {
		return WireJS.get(signal, scope, listener, hash).map(wjs => wjs.wrapper)
	}
	
	static add(scope, signal, listener, replies = 0) {
		let originalWire = new Wire(scope, signal, listener, replies = 0)
		WireJS.attach(originalWire._)
		return originalWire
	}
	
	static send(signal, data = null) {
		return WireJS.send(signal, data)
	}
	
	static data(key, value = null) {
		let originalWireData = WireJS.data(key, value)
		if (originalWireData.wrapper == null)
			return new WireData(originalWireData)
		return originalWireData.wrapper
	}
}
