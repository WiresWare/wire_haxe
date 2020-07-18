package wire;

interface WireMiddleware {
    public function onAdd(wire:Wire):Void;
    public function onSend(signal:String, data:Dynamic):Void;
    public function onRemove(signal:String, scope:Dynamic, listener:WireListener):Void;
    public function onData(key:String, prevValue:Dynamic, nextValue:Dynamic):Void;
}
