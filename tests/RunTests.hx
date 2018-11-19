package ;

class RunTests {

  static function main() {
    why.pubsub.mqtt.Mqtt;
    
    travix.Logger.println('it works');
    travix.Logger.exit(0); // make sure we exit properly, which is necessary on some targets, e.g. flash & (phantom)js
    
    var magic = new Magic(null);
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
