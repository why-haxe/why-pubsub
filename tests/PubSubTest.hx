package;

import haxe.io.Bytes;
import why.pubsub.*;

using tink.CoreApi;

typedef Rabbit = why.pubsub.amqp.Amqp<PubSub>;
typedef Local = why.pubsub.local.Local<PubSub>;
typedef Mqtt = why.pubsub.mqtt.Mqtt<PubSub>;

@:asserts
class PubSubTest {
	final pubsub:PubSub;
	
	public function new(pubsub) {
		this.pubsub = pubsub;
	}
	
	@:setup
	public function setup() {
		switch Std.downcast(pubsub, Rabbit) {
			case null:
			case amqp:
				return amqp.sync({
					exchanges: [
						{name: 'foo', type: 'fanout'},
						{name: 'variant', type: 'direct'},
					],
					queues: [
						{name: 'bar', bindings: [{exchange: 'foo', pattern: ''}]},
						{name: 'variant_1', bindings: [{exchange: 'variant', pattern: 'variant.1'}]},
						{name: 'variant_2', bindings: [{exchange: 'variant', pattern: 'variant.2'}]},
					],
				});
		}
		
		switch Std.downcast(pubsub, Mqtt) {
			case null:
			case mqtt:
				return mqtt.client.connect();
		}
		
		return Promise.NOISE;
	}
	
	public function cache() {
		
		asserts.assert(pubsub.publishers.variant('1') == pubsub.publishers.variant('1'), 'Cached instances');
		asserts.assert(pubsub.publishers.variant('1') != pubsub.publishers.variant('2'), 'Cached instances');
		
		asserts.assert(pubsub.subscribers.variant('1') == pubsub.subscribers.variant('1'), 'Cached instances');
		asserts.assert(pubsub.subscribers.variant('1') != pubsub.subscribers.variant('2'), 'Cached instances');
		
		asserts.assert(pubsub.publishers.cache('1', 2, true) == pubsub.publishers.cache('1', 2, true), 'Cached instances');
		asserts.assert(pubsub.publishers.cache('1', 2, true) != pubsub.publishers.cache('1', 2, false), 'Cached instances');
		asserts.assert(pubsub.publishers.cache('1', 2, true) != pubsub.publishers.cache('a', 2, true), 'Cached instances');
		
		asserts.assert(pubsub.subscribers.cache('1', 2, true) == pubsub.subscribers.cache('1', 2, true), 'Cached instances');
		asserts.assert(pubsub.subscribers.cache('1', 2, true) != pubsub.subscribers.cache('1', 2, false), 'Cached instances');
		asserts.assert(pubsub.subscribers.cache('1', 2, true) != pubsub.subscribers.cache('a', 2, true), 'Cached instances');
		
		return asserts.done();
	}
	
	public function test() {
		Promise.inSequence([
			new Promise(function(resolve, reject) {
				
				var subscription = pubsub.subscribers.bar.subscribe(envelope -> switch envelope.content.get() {
					case Success(message):
						envelope.ack();
						asserts.assert(message.foo == 1);
						asserts.assert(message.bar == 'a');
						resolve(Noise);
					case Failure(e):
						envelope.ack();
						reject(e);
				});
				pubsub.publishers.foo.publish({foo: 1, bar: 'a'}).eager();
			}, true),
			new Promise(function(resolve, reject) {
				
				var subscription = pubsub.subscribers.variant('1').subscribe(envelope -> switch envelope.content.get() {
					case Success(message):
						envelope.ack();
						asserts.assert(message.foo == 2);
						asserts.assert(message.bar == 'b');
						resolve(Noise);
					case Failure(e):
						envelope.ack();
						reject(e);
				});
				pubsub.publishers.variant('1').publish({foo: 2, bar: 'b'}).eager();
			}, true),
			new Promise(function(resolve, reject) {
				
				var subscription = pubsub.subscribers.variant('2').subscribe(envelope -> switch envelope.content.get() {
					case Success(message):
						envelope.ack();
						asserts.assert(message.foo == 3);
						asserts.assert(message.bar == 'c');
						resolve(Noise);
					case Failure(e):
						envelope.ack();
						reject(e);
				});
				pubsub.publishers.variant('2').publish({foo: 3, bar: 'c'}).eager();
			}, true),
		])
			.flatMap(_ -> Future.delay(200, Success(Noise))) // give time to ack
			.handle(asserts.handle);
		
		return asserts;
	}
}

