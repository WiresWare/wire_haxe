package ;

import wire.WireListener;
import wire.WireLayer;

class Wire {
    static private var _INDEX:Int = 0;
    static final _LAYER:WireLayer = new WireLayer();

    var _hash:Int;
    var _signal:String;
    var _scope:Dynamic;
    var _listener:WireListener;

    public var signal(get, never):String;
    function get_signal():String { return _signal; }

    public var listener(get, never):WireListener;
    function get_listener():WireListener { return _listener; }

    public var hash(get, never):Int;
    function get_hash():Int { return _hash; }

    public var scope(get, never):Dynamic;
    function get_scope():Dynamic { return _scope; }

    public var replies:Int = 0;

    public function new(scope:Dynamic, signal:String, listener:WireListener, replies:Int = 0) {
        _scope = scope;
        _signal = signal;
        _listener = listener;
        this.replies = replies;
        _hash = ++_INDEX;
    }

    public function transfer(data:Dynamic):Void {
        _listener(this, data);
    }

    public function clear() {
        _scope = null;
        _signal = null;
        _listener = null;
    }

    static public function attach(wire:Wire):Void {
        _LAYER.add(wire);
    }

    static public function detach(wire:Wire):Bool {
        return _LAYER.remove(wire.signal, wire.scope, wire.listener);
    }

    static public function add(scope:Dynamic, signal:String, listener:WireListener, replies:Int = 0):Wire {
        var wire = new Wire(scope, signal, listener, replies);
        attach(wire);
        return wire;
    }

    static public function has(signal:String, wire:Wire):Bool {
        if (signal != null) return _LAYER.hasSignal(signal);
        if (wire != null) return _LAYER.hasWire(wire);
        return false;
    }

    static public function send(signal:String, data:Dynamic = null):Bool {
        return _LAYER.send(signal, data);
    }

    static public function purge(withMiddleware:Bool = false):Void {
        _LAYER.clear();
    }

    static public function remove(signal:String, scope:Dynamic = null, listener:WireListener = null):Bool {
        return _LAYER.remove(signal, scope, listener);
    }
}
