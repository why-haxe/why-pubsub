package why.pubsub.amqp;

import amqp.AmqpConnectionManager;
import tink.Chunk;

using tink.CoreApi;

class Publisher<Message> implements why.pubsub.Publisher<Message> {
	
	final channel:AmqpChannelWrapper;
	final config:PublisherConfig<Message>;
	
	public function new(manager:AmqpConnectionManager, config) {
		this.channel = manager.createChannel({
			setup: channel -> js.lib.Promise.resolve(),
		});
		this.config = config;
	}
		
	public function publish(message:Message):Promise<Noise> {
		var buffer = config.serialize(message).toBuffer();
		return Promise.ofJsPromise(channel.publish(config.exchange, config.routingKey, buffer)).noise();
	}
}

typedef PublisherConfig<Message> = {
	final exchange:String;
	final routingKey:String;
	final serialize:Message->Chunk;
}