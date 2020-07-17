import wire.WireListener;
import Wire;

class Scope {
    public function new() {}
}

class Main {
    static public function main() {
        trace("Welcome Wire");

        /// SUBSCRIBER and API EXAMPLE ======================================
        var
            SIGNAL_1        :String = 'SIGNAL_1',
            SIGNAL_ONCE     :String = 'SIGNAL_1_ONCE',
            SIGNAL_2        :String = 'SIGNAL_2';

        var SCOPE = new Scope();

        Wire.add(SCOPE, SIGNAL_1, function(wire:Wire, data:Dynamic):Void {
            trace('> SIGNAL 1 (subscriber 1) -> Hello: ' + data);
        });

        var listener1:WireListener = function(wire:Wire, data:Dynamic) {
            trace('> SIGNAL 1 (subscriber 2) -> Hello: ' + data);
        };

        Wire.add(SCOPE, SIGNAL_1, listener1);

        Wire.send(SIGNAL_1, 'World');
        Wire.send(SIGNAL_1, 'Haxe');
        Wire.send(SIGNAL_1, 'Programming');
        Wire.remove(SIGNAL_1);

        /// SUBSCRIBER END =========================================
        ///
        /// REMOVE EXAMPLE ===========================================

        var listener2:WireListener = function(wire:Wire, data:Dynamic) {
            trace('> Remove: SIGNAL (listener 2) -> data: ' + data);
        };
        var SCOPE_2 = new Scope();
        var SIGNAL_3 = 'SIGNAL_3';
        var SIGNAL_4 = 'SIGNAL_4';

        /* 1 */ Wire.add(SCOPE, SIGNAL_3, listener2); // Will be removed
        /* 2 */ Wire.add(SCOPE, SIGNAL_4, listener2);
        /* 3 */ Wire.add(SCOPE_2, SIGNAL_3, listener2); // Will be removed
        /* 4 */ Wire.add(SCOPE_2, SIGNAL_4, function(wire:Wire, data:Dynamic) { trace('> Remove: SIGNAL 2 -> data: ' + data); });

        /* 1 */ Wire.remove(SIGNAL_3, null, listener2);
        /* 3 */ Wire.remove(SIGNAL_3, SCOPE_2);

        Wire.send(SIGNAL_3, 'SIGNAL_3');
        Wire.send(SIGNAL_4, 'SIGNAL_4');

        /* 2 */ Wire.remove(SIGNAL_1, SCOPE);
        /* 4 */ Wire.remove(SIGNAL_2, SCOPE_2);

        /// ONCE EXAMPLE ===========================================
        Wire.add(SCOPE, SIGNAL_ONCE, function(wire:Wire, data:Dynamic) {
            trace('> SIGNAL 1 (limit 1) -> Goodbye: ' + data);
        }, 1);

        trace('\tNo ends: ' + Wire.send(SIGNAL_ONCE, 'World'));
        trace('\tNo ends: ' + Wire.send(SIGNAL_ONCE, 'Haxe'));
        trace('\tNo ends: ' + Wire.send(SIGNAL_ONCE, 'Programming'));
        /// ONCE END ===============================================

        Wire.add(SCOPE, SIGNAL_2, function(wire:Wire, data:Dynamic) {
            trace('> SIGNAL 2 -> I do: ' + data);
        });

        Wire.add(SCOPE, SIGNAL_2, function(wire:Wire, data:Dynamic) {
            trace('> SIGNAL 2 (limit 2) -> I do: ' + data);
        }, 2);

        trace('\tSend ends: ' + Wire.send(SIGNAL_2, 'Code'));
        trace('\tSend ends: ' + Wire.send(SIGNAL_2, 'Gym'));
        trace('\tSend ends: ' + Wire.send(SIGNAL_2, 'Eat'));
        trace('\tSend ends: ' + Wire.send(SIGNAL_2, 'Sleep'));
        trace('\tSend ends: ' + Wire.send(SIGNAL_2, 'Repeat'));
    }
}
