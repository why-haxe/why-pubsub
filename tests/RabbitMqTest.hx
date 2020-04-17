package;

import haxe.io.Bytes;
import why.pubsub.Publisher;

@:asserts
class RabbitMqTest {
	public function new() {}
	
	public function test() {
		var manager = amqp.AmqpConnectionManager.connect(['amqp://localhost']);
		var rabbitmq = new why.pubsub.rabbitmq.RabbitMq<Publishers, Subscribers>(manager);
		rabbitmq.publishers.raw.publish(Bytes.alloc(10)).handle(asserts.handle);
		
		return asserts;
	}
}

interface Publishers {
	@:why.pubsub.rabbitmq({exchange: '', routingKey: '', serialize: v -> v})
	var raw(get, never):Publisher<Bytes>;
}

interface Subscribers {
}