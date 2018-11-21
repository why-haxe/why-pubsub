package;

import why.pubsub.adapters.Ble;
import why.pubsub.adapters.Mqtt;
import why.pubsub.Translator;

class RunTests {

  static function main() {
    travix.Logger.println('it works');
    travix.Logger.exit(0); // make sure we exit properly, which is necessary on some targets, e.g. flash & (phantom)js
    
    var adapter = new Ble(null);
    var ble = new Magic(adapter, new SimpleTranslator((v:Target) -> v.id, (v:String) -> {id: v, service: '', characteristic: ''}));
    var adapter = new Mqtt(null);
    var mqtt = new Magic(adapter, new DefaultTranslator());
    $type(ble);
    $type(ble.foo);
    $type(ble.plain);
    $type(ble.foo.publish({data:''}));
    $type(ble.foo.subscribe(function(o) trace($type(o))));
    $type(mqtt);
    $type(mqtt.foo);
    $type(mqtt.plain);
    $type(mqtt.foo.publish({data:''}));
    $type(mqtt.foo.subscribe(function(o) trace($type(o))));
  }
}

class Magic<T> extends why.PubSub<String, T> {
  @:pubsub('dasloop_id')
  public var foo:{data:String};
  
  public var plain:{data:String};
}
