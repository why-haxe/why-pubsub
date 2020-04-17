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
    
    
    
    
    
    
    amqp.foo.subscribe();
    
  }
}


class AmqpMagic {
    var translator:Translator;
    var manager = AmqpConnectionManager.connect(['amqp://localhost/dasloop']);
    
    var foo = {
      var channel = Amqp.createChannel();
      var exchange = 'raw';
      var queue = 'general_report';
      var key = '';
      
      var error = Future.trigger();
      
      var channel = manager.createChannel({
        setup: channel -> cast channel.assertExchange(exchange, 'fanout')
          .then(_ -> channel.assertQueue(queue))
          .then(_ -> channel.bindQueue(queue, exchange, key)),
      });
      
      // channel.on('error', e -> error.trigger(Error.ofJsError(e)));
      
      {
        publish:
          function(payload:Chunk) {
            return new Promise((resolve, reject) -> {
              function send() {
                if(channel.publish(exchange, key, payload.toBuffer()))
                  resolve(Noise);
                else 
                  channel.once('drain', send);
              }
            });
          },
        subscribe:
          function(handler:AmqpMsg->Void) {
            
            var tag:Promise<String>;
            
            channel.addSetup(function setup(channel) {
              var ret = channel.consume(queue, handler);
              tag = Promise.ofJsPromise(ret).next(o -> o.consumerTag);
              return ret;
            });
            
            return new SimpleSubscription(
              () -> channel.removeSetup(setup, channel -> tag.next(channel.cancel).eager()),
              error
            );
          }
      }
    }
}


class Magic<T> extends why.PubSub<String, T> {
  @:pubsub('dasloop_id')
  public var foo:{data:String};
  
  public var plain:{data:String};
}
