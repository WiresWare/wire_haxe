package wire;

import wire.WireListener;

class WireLayer {

    private final _wireByHash:Map<Int, Wire> = new Map<Int, Wire>();
    private final _hashesBySignal:Map<String, Array<Int>> = new Map<String, Array<Int>>();

    public function new() {}

    public function add(wire:Wire):Wire {
        var hash = wire.hash;
        var signal = wire.signal;

        if (_wireByHash.exists(hash)) {
            throw WireConstant.ERROR__WIRE_ALREADY_REGISTERED + Std.string(hash);
        }

        _wireByHash.set(hash, wire);

        if (!_hashesBySignal.exists(signal)) {
            _hashesBySignal[signal] = new Array<Int>();
        }

        _hashesBySignal[signal].push(hash);

        return wire;
    }

    public function hasSignal(signal:String):Bool {
        return _hashesBySignal.exists(signal);
    }

    public function hasWire(wire:Wire):Bool {
        return _wireByHash.exists(wire.hash);
    }

    public function send(signal:String, data:Dynamic = null):Bool {
        var noMoreSubscribers = true;
        if (hasSignal(signal)) {
            var WiresToRemove = new Array<Wire>();
            for (hash in _hashesBySignal[signal]) {
                var wire:Wire = _wireByHash[hash];
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
            for (hash in _hashesBySignal[signal]) {
                var wire = _wireByHash[hash];
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
        for (hash in _wireByHash.keys()) {
            wireToRemove.push(_wireByHash.get(hash));
        }
        for (wire in wireToRemove) _removeWire(wire);
    }

    private function _removeWire(wire:Wire):Bool {
        var hash = wire.hash;
        var signal = wire.signal;

        // Remove Wire by hash
        _wireByHash.remove(hash);

        // Remove hash for Wire signal
        var hashesForSignal:Array<Int> = _hashesBySignal[signal];
        hashesForSignal.remove(hash);

        var noMoreSignals = hashesForSignal.length == 0;
        if (noMoreSignals) _hashesBySignal.remove(signal);

        wire.clear();

        return noMoreSignals;
    }

    public function getBySignal(signal:String):Array<Wire> {
        return hasSignal(signal)
            ? _hashesBySignal[signal].map((hash) -> _wireByHash.get(hash))
            : new Array<Wire>();
    }

    public function getByScope(scope:Dynamic):Array<Wire> {
        var result = new Array<Wire>();
        for (hash in _wireByHash.keys()) {
            var wire = _wireByHash.get(hash);
            if (wire.scope == scope) result.push(wire);
        }
        return result;
    }

    public function getByListener(listener:WireListener):Array<Wire> {
        var result = new Array<Wire>();
        for (hash in _wireByHash.keys()) {
            var wire = _wireByHash.get(hash);
            if (wire.listener == listener) result.push(wire);
        }
        return result;
    }
}
