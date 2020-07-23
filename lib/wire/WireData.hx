package wire;

#if js
@:expose('WireDataJS')
#else
@:expose
#end
class WireData {
    private var _onRemove:String->Void;
    private final _listeners:Array<WireDataListener>
        = new Array<WireDataListener>();

    private var _isSet:Bool = false;
    var isSet(get, never):Bool;
    public function get_isSet() { return _isSet; }

    private var _key:String;
    var key(get, never):String;
    public function get_key() { return _key; }

    private var _value:Dynamic;
    public var value(get, set):Dynamic;
    function get_value() { return _value; }
    function set_value(input:Dynamic):Dynamic {
        _value = input;
        _isSet = true;
        refresh();
        return _value;
    }

    public function new(key:String, onRemove:String->Void) {
        _key = key;
        _onRemove = onRemove;
    }

    public function refresh():Void {
        for (listener in _listeners) {
            listener(_value);
        }
    }

    public function remove():Void {
        _onRemove(_key);
        _onRemove = null;

        _key = null;
        // null value means remove element that listening on change (unsubscribe)
        value = null;

        while(_listeners.length > 0) _listeners.pop();
    }

    public function subscribe(listener:WireDataListener):WireData {
        if (!hasListener(listener)) _listeners.push(listener);
        return this;
    }

    public function unsubscribe(listener:WireDataListener = null):WireData {
        if (hasListener(listener)) _listeners.remove(listener);
        return this;
    }

    public function hasListener(listener:WireDataListener):Bool {
        return _listeners.indexOf(listener) >= 0;
    }
}
