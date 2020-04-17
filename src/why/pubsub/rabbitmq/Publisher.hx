package why.pubsub.rabbitmq;

import amqp.AmqpConnectionManager;
import tink.Chunk;

using tink.CoreApi;

class Publisher<Message> implements why.pubsub.Publisher<Message> {
	
	final channel:AmqpChannelWrapper;
	final exchange:String;
	final routingKey:String;
	final serialize:Message->Chunk;
	
	public function new(manager:AmqpConnectionManager, exchange, routingKey, serialize) {
		this.channel = manager.createChannel({
			setup: channel -> js.lib.Promise.resolve(),
		});
		this.exchange = exchange;
		this.routingKey = routingKey;
		this.serialize = serialize;
	}
		
	public function publish(message:Message):Promise<Noise> {
		return Promise.ofJsPromise(channel.publish(exchange, routingKey, serialize(message).toBuffer())).noise();
	}
}