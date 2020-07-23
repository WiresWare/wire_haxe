package ;

import Type.ValueType;

import wire.WireMiddleware;
import wire.WireConstant;
import wire.WireData;
import wire.WireListener;
import wire.WireStore;
import wire.WireLayer;

#if js
@:expose('WireJS')
#else
@:expose
#end
class Wire {
    static private var _INDEX:Int = 0;
    static final _LAYER:WireLayer = new WireLayer();
    static final _STORE:WireStore = new WireStore();
    static final _MIDDLEWARES:Array<WireMiddleware> = new Array<WireMiddleware>();

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
        _listener(_hash, data);
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
        for (m in _MIDDLEWARES) m.onAdd(wire);
        attach(wire);
        return wire;
    }

    static public function has(signal:String, wire:Wire):Bool {
        if (signal != null) return _LAYER.hasSignal(signal);
        if (wire != null) return _LAYER.hasWire(wire);
        return false;
    }

    static public function send(signal:String, data:Dynamic = null):Bool {
        for (m in _MIDDLEWARES) m.onSend(signal, data);
        return _LAYER.send(signal, data);
    }

    static public function purge(withMiddleware:Bool = false):Void {
        _LAYER.clear();
        _STORE.clear();
        if (withMiddleware) while(_MIDDLEWARES.length > 0)
            _MIDDLEWARES.pop();
    }

    static public function remove(signal:String, scope:Dynamic = null, listener:WireListener = null):Bool {
        var existed:Bool = _LAYER.remove(signal, scope, listener);
        if (existed) {
            for (m in _MIDDLEWARES) m.onRemove(signal, scope, listener);
        }
        return existed;
    }

    static public function middleware(value:WireMiddleware):Void {
        if (_MIDDLEWARES.indexOf(value) < 0) {
            _MIDDLEWARES.push(value);
        } else {
            throw WireConstant.ERROR__MIDDLEWARE_EXISTS + value;
        }
    }

    static public function get(signal:String, scope:Dynamic, listener:WireListener, hash:Int):Array<Wire> {
        var result = new Array<Wire>();
        if (signal != null && scope == null && listener == null && hash == null) {
            result = result.concat(_LAYER.getBySignal(signal));
        }
        if (signal == null && scope != null && listener == null && hash == null) {
            result = result.concat(_LAYER.getByScope(scope));
        }
        if (signal == null && scope == null && listener != null && hash == null) {
            result = result.concat(_LAYER.getByListener(listener));
        }
        if (signal == null && scope == null && listener == null && hash != null) {
            result.push(_LAYER.getByHash(hash));
        }
        // TODO: Implement combined cases
        return result;
    }

    static public function data(key:String, value:Dynamic = null):WireData {
        var wireData = _STORE.get(key);
        if (value != null) {
            var prevValue = wireData.value;
            var nextValue = Type.typeof(value) == ValueType.TFunction ? value(prevValue) : value;
            for (m in _MIDDLEWARES) m.onData(key, prevValue, nextValue);
            wireData.value = nextValue;
        }
        return wireData;
    }
}
