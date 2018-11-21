package ;

class RunTests {

  static function main() {
    travix.Logger.println('it works');
    travix.Logger.exit(0); // make sure we exit properly, which is necessary on some targets, e.g. flash & (phantom)js
    
    why.pubsub.adapters.Ble;
    var adapter = new why.pubsub.adapters.Mqtt(null);
    var magic = new Magic(adapter);
    $type(magic.foo);
    $type(magic.plain);
    $type(magic.foo.publish({data:''}));
    $type(magic.foo.subscribe(function(o) trace($type(o))));
  }
  
}

class Magic extends why.PubSub {
  @:pub('foo')
  @:sub('foo')
  public var foo:{data:String};
  
  public var plain:{data:String};
}
