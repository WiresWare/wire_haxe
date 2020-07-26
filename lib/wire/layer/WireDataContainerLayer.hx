package wire.layer;

class WireDataContainerLayer {
    public function new() {}

    private final _map:Map<String, WireData> = new Map<String, WireData>();

    public function get(key:String):WireData {
        if (!_map.exists(key))
            _map[key] = new WireData(key, _map.remove);
        return _map.get(key);
    }

    public function clear():Void {
        for (key in _map.keys()) {
            _map.get(key).remove();
            _map.remove(key);
        }
    }
}
