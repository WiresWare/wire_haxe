package controller;

import const.CounterDataKey;
import const.CounterSignal;

class CounterController {
  public function new() {

    Wire.add(this, CounterSignal.INCREASE, (data, wid) -> {
      trace('> Processor: INCREASE -> handle: ' + data);
      Wire.data(CounterDataKey.COUNT, (value) -> value + 1);
    });

    Wire.add(this, CounterSignal.DECREASE, (data, wid) -> {
      trace('> Processor: DECREASE -> handle: ' + data);
      Wire.data(CounterDataKey.COUNT, (value) -> value > 0 ? value - 1 : 0);
    });

    trace('Processor Ready');
  }
}
