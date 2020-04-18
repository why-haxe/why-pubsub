package;

import haxe.io.Bytes;
import why.pubsub.*;

using tink.CoreApi;

@:asserts
class RabbitMqTest {
	public function new() {}
	
	public function test() {
		var manager = amqp.AmqpConnectionManager.connect(['amqp://localhost']);
		var rabbitmq = new why.pubsub.rabbitmq.RabbitMq<PubSub>(manager);
		
		rabbitmq
			.sync({
				exchanges: [
					{name: 'foo', type: 'fanout'},
					{name: 'variant', type: 'direct'},
				],
				queues: [
					{name: 'bar', bindings: [{exchange: 'foo', pattern: ''}]},
					{name: 'variant_1', bindings: [{exchange: 'variant', pattern: 'variant.1'}]},
					{name: 'variant_2', bindings: [{exchange: 'variant', pattern: 'variant.2'}]},
				],
			})
			.next(_ -> {
				Promise.inSequence([
					new Promise(function(resolve, reject) {
						rabbitmq.publishers.foo.publish({foo: 1, bar: 'a'}).eager();
						
						var subscription = rabbitmq.subscribers.bar.subscribe(envelope -> switch envelope.content {
							case Success(message):
								envelope.ack();
								asserts.assert(message.foo == 1);
								asserts.assert(message.bar == 'a');
								resolve(Noise);
							case Failure(e):
								envelope.ack();
								reject(e);
						});
					}),
					new Promise(function(resolve, reject) {
						rabbitmq.publishers.variant('1').publish({foo: 2, bar: 'b'}).eager();
						
						var subscription = rabbitmq.subscribers.variant('1').subscribe(envelope -> switch envelope.content {
							case Success(message):
								envelope.ack();
								asserts.assert(message.foo == 2);
								asserts.assert(message.bar == 'b');
								resolve(Noise);
							case Failure(e):
								envelope.ack();
								reject(e);
						});
					}),
					new Promise(function(resolve, reject) {
						rabbitmq.publishers.variant('2').publish({foo: 3, bar: 'c'}).eager();
						
						var subscription = rabbitmq.subscribers.variant('2').subscribe(envelope -> switch envelope.content {
							case Success(message):
								envelope.ack();
								asserts.assert(message.foo == 3);
								asserts.assert(message.bar == 'c');
								resolve(Noise);
							case Failure(e):
								envelope.ack();
								reject(e);
						});
					}),
				]);
			})
			.flatMap(_ -> Future.delay(500, Success(Noise))) // give time to ack
			.handle(asserts.handle);
		
		return asserts;
	}
}

typedef PubSub = why.PubSub<Publishers, Subscribers>;

interface Publishers {
	@:why.pubsub.rabbitmq({exchange: 'foo', routingKey: '', serialize: v -> haxe.Serializer.run(v)})
	var foo(get, never):Publisher<{foo:Int, bar:String}>;
	
	@:why.pubsub.rabbitmq({exchange: 'variant', routingKey: 'variant.$id', serialize: v -> haxe.Serializer.run(v)})
	function variant(id:String):Publisher<{foo:Int, bar:String}>;
	
}

interface Subscribers {
	@:why.pubsub.rabbitmq({queue: 'bar', prefetch: 2, unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	var bar(get, never):Subscriber<{foo:Int, bar:String}>;
	
	@:why.pubsub.rabbitmq({queue: 'variant_$id', prefetch: 2, unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	function variant(id:String):Subscriber<{foo:Int, bar:String}>;
}