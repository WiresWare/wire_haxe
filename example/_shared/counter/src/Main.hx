package ;

import controller.CounterController;

class Main {
    private static var _controller:CounterController;
    static public function main() {
        _controller = new CounterController();
    }
}
