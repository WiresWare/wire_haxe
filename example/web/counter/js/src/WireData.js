export default class WireData {
	constructor(wire_data_js) {
		let that = this
		let originalRemove = wire_data_js.remove
		this._ = wire_data_js
		this._.remove = () => {
			that._ = null
			originalRemove()
			that = null
		}
		this._.wrapper = this
	}
	
	get isSet() { return this._._isSet; }
	get value() { return this._.get_value(); }
	set value(data) { return this._.set_value(data); }
	
	refresh() { this._.refresh() }
	remove() { this._.remove() }
	subscribe(listener) { return this._.subscribe(listener) }
	unsubscribe(listener) { return this._.unsubscribe(listener) }
	hasListener(listener) { return this._.hasListener(listener) }
}
