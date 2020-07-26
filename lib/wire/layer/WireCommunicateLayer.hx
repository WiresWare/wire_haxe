package wire.layer;

import wire.WireListener;

class WireCommunicateLayer {

    private final _wireByWID:Map<Int, Wire> = new Map<Int, Wire>();
    private final _widsBySignal:Map<String, Array<Int>> = new Map<String, Array<Int>>();

    public function new() {}

    public function add(wire:Wire):Wire {
        var wid = wire.wid;
        var signal = wire.signal;

        if (_wireByWID.exists(wid)) {
            throw WireConstant.ERROR__WIRE_ALREADY_REGISTERED + Std.string(wid);
        }

        _wireByWID.set(wid, wire);

        if (!_widsBySignal.exists(signal)) {
            _widsBySignal[signal] = new Array<Int>();
        }

        _widsBySignal[signal].push(wid);

        return wire;
    }

    public function hasSignal(signal:String):Bool {
        return _widsBySignal.exists(signal);
    }

    public function hasWire(wire:Wire):Bool {
        return _wireByWID.exists(wire.wid);
    }

    public function send(signal:String, data:Dynamic = null):Bool {
        var noMoreSubscribers = true;
        if (hasSignal(signal)) {
            var WiresToRemove = new Array<Wire>();
            for (wid in _widsBySignal[signal]) {
                var wire:Wire = _wireByWID[wid];
                var replies = wire.replies;
                noMoreSubscribers = replies > 0 && --replies == 0;
                if (noMoreSubscribers) WiresToRemove.push(wire);
                wire.replies = replies;
                wire.transfer(data);
            }
            for (wire in WiresToRemove) noMoreSubscribers = _removeWire(wire);
        }
        return noMoreSubscribers;
    }

    public function remove(signal:String, scope:Dynamic = null, listener:WireListener = null):Bool {
        var exists = hasSignal(signal);
        if (exists) {
            var wiresToRemove = new Array<Wire>();
            for (wid in _widsBySignal[signal]) {
                var wire = _wireByWID[wid];
                var isWrongScope = scope != null && scope != wire.scope;
                var isWrongListener = listener != null && listener != wire.listener;
                if (isWrongScope || isWrongListener) return false;
                wiresToRemove.push(wire);
            }
            for (wire in wiresToRemove) _removeWire(wire);
        }
        return exists;
    }

    public function clear():Void {
        var wireToRemove = new Array<Wire>();
        for (wid in _wireByWID.keys()) {
            wireToRemove.push(_wireByWID.get(wid));
        }
        for (wire in wireToRemove) _removeWire(wire);
    }

    private function _removeWire(wire:Wire):Bool {
        var wid = wire.wid;
        var signal = wire.signal;

        // Remove Wire by wid
        _wireByWID.remove(wid);

        // Remove wid for Wire signal
        var widsForSignal:Array<Int> = _widsBySignal[signal];
        widsForSignal.remove(wid);

        var noMoreSignals = widsForSignal.length == 0;
        if (noMoreSignals) _widsBySignal.remove(signal);

        wire.clear();

        return noMoreSignals;
    }

    public function getBySignal(signal:String):Array<Wire> {
        return hasSignal(signal)
            ? _widsBySignal[signal].map((wid) -> _wireByWID.get(wid))
            : new Array<Wire>();
    }

    public function getByWID(wid:Int):Wire {
        return _wireByWID.exists(wid) ? _wireByWID.get(wid) : null;
    }

    public function getByScope(scope:Dynamic):Array<Wire> {
        var result = new Array<Wire>();
        for (wid in _wireByWID.keys()) {
            var wire = _wireByWID.get(wid);
            if (wire.scope == scope) result.push(wire);
        }
        return result;
    }

    public function getByListener(listener:WireListener):Array<Wire> {
        var result = new Array<Wire>();
        for (wid in _wireByWID.keys()) {
            var wire = _wireByWID.get(wid);
            if (wire.listener == listener) result.push(wire);
        }
        return result;
    }
}
