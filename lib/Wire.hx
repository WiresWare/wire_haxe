package ;

import Type.ValueType;

import wire.WireMiddleware;
import wire.WireConstant;
import wire.WireData;
import wire.WireListener;
import wire.layer.WireDataContainerLayer;
import wire.layer.WireCommunicateLayer;

#if js
@:expose('WireJS')
#else
@:expose
#end
class Wire {
    static private var _INDEX:Int = 0;
    static final _COMMUNICATION_LAYER:WireCommunicateLayer = new WireCommunicateLayer();
    static final _DATA_CONTAINER_LAYER:WireDataContainerLayer = new WireDataContainerLayer();
    static final _MIDDLEWARE_LIST:Array<WireMiddleware> = new Array<WireMiddleware>();

    var _wid:Int;
    var _signal:String;
    var _scope:Dynamic;
    var _listener:WireListener;

    public var signal(get, never):String;
    function get_signal():String { return _signal; }

    public var listener(get, never):WireListener;
    function get_listener():WireListener { return _listener; }

    public var wid(get, never):Int;
    function get_wid():Int { return _wid; }

    public var scope(get, never):Dynamic;
    function get_scope():Dynamic { return _scope; }

    public var replies:Int = 0;

    public function new(scope:Dynamic, signal:String, listener:WireListener, replies:Int = 0) {
        _scope = scope;
        _signal = signal;
        _listener = listener;
        this.replies = replies;
        _wid = ++_INDEX;
    }

    public function transfer(data:Dynamic):Void {
        _listener(data, _wid);
    }

    public function clear() {
        _scope = null;
        _signal = null;
        _listener = null;
    }

    static public function attach(wire:Wire):Void {
        _COMMUNICATION_LAYER.add(wire);
    }

    static public function detach(wire:Wire):Bool {
        return _COMMUNICATION_LAYER.remove(wire.signal, wire.scope, wire.listener);
    }

    static public function add(scope:Dynamic, signal:String, listener:WireListener, replies:Int = 0):Wire {
        var wire = new Wire(scope, signal, listener, replies);
        for (m in _MIDDLEWARE_LIST) m.onAdd(wire);
        attach(wire);
        return wire;
    }

    static public function has(signal:String, wire:Wire):Bool {
        if (signal != null) return _COMMUNICATION_LAYER.hasSignal(signal);
        if (wire != null) return _COMMUNICATION_LAYER.hasWire(wire);
        return false;
    }

    static public function send(signal:String, data:Dynamic = null):Bool {
        for (m in _MIDDLEWARE_LIST) m.onSend(signal, data);
        return _COMMUNICATION_LAYER.send(signal, data);
    }

    static public function purge(withMiddleware:Bool = false):Void {
        _COMMUNICATION_LAYER.clear();
        _DATA_CONTAINER_LAYER.clear();
        if (withMiddleware) while(_MIDDLEWARE_LIST.length > 0)
            _MIDDLEWARE_LIST.pop();
    }

    static public function remove(signal:String, scope:Dynamic = null, listener:WireListener = null):Bool {
        var existed:Bool = _COMMUNICATION_LAYER.remove(signal, scope, listener);
        if (existed) {
            for (m in _MIDDLEWARE_LIST) m.onRemove(signal, scope, listener);
        }
        return existed;
    }

    static public function middleware(value:WireMiddleware):Void {
        if (_MIDDLEWARE_LIST.indexOf(value) < 0) {
            _MIDDLEWARE_LIST.push(value);
        } else {
            throw WireConstant.ERROR__MIDDLEWARE_EXISTS + value;
        }
    }

    static public function get(signal:String, scope:Dynamic, listener:WireListener, wid:Int):Array<Wire> {
        var result = new Array<Wire>();
        if (signal != null) {
            result = result.concat(_COMMUNICATION_LAYER.getBySignal(signal));
        }
        if (scope != null) {
            result = result.concat(_COMMUNICATION_LAYER.getByScope(scope));
        }
        if (listener != null) {
            result = result.concat(_COMMUNICATION_LAYER.getByListener(listener));
        }
        if (wid != null) {
            result.push(_COMMUNICATION_LAYER.getByWID(wid));
        }
        return result;
    }

    static public function data(key:String, value:Dynamic = null):WireData {
        var wireData = _DATA_CONTAINER_LAYER.get(key);
        if (value != null) {
            var prevValue = wireData.value;
            var nextValue = Type.typeof(value) == ValueType.TFunction ? value(prevValue) : value;
            for (m in _MIDDLEWARE_LIST) m.onData(key, prevValue, nextValue);
            wireData.value = nextValue;
        }
        return wireData;
    }
}
