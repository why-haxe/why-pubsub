package;

import haxe.io.Bytes;
import why.pubsub.*;

using tink.CoreApi;

@:asserts
class RabbitMqTest {
	public function new() {}
	
	public function test() {
		var manager = amqp.AmqpConnectionManager.connect(['amqp://localhost']);
		var rabbitmq = new why.pubsub.rabbitmq.RabbitMq<Publishers, Subscribers>(manager);
		rabbitmq.publishers.foo.publish({foo: 1, bar: 'a'}).eager();
		
		var subscription = rabbitmq.subscribers.bar.subscribe(envelope -> switch envelope.content {
			case Success(message):
				envelope.ack();
				asserts.assert(message.foo == 1);
				asserts.assert(message.bar == 'a');
				asserts.done();
			case Failure(e):
				envelope.ack();
				asserts.fail(e);
		});
		
		subscription.error.handle(e -> trace(e));
		
		return asserts;
	}
}

interface Publishers {
	@:why.pubsub.rabbitmq({exchange: 'foo', routingKey: '', serialize: v -> haxe.Serializer.run(v)})
	var foo(get, never):Publisher<{foo:Int, bar:String}>;
}

interface Subscribers {
	@:why.pubsub.rabbitmq({queue: 'bar', prefetch: 2, unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	var bar(get, never):Subscriber<{foo:Int, bar:String}>;
}