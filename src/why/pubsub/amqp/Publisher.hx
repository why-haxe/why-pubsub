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
		#if why_pubsub_debug
		this.channel.on('error', cast js.Node.console.log);
		#end
		this.config = config;
	}
		
	public function publish(message:Message):Promise<Noise> {
		var buffer = config.serialize(message).toBuffer();
		var routingKey = config.routingKey(message);
		return Promise.ofJsPromise(channel.publish(config.exchange, routingKey, buffer)).noise();
	}
}

typedef PublisherConfig<Message> = {
	final exchange:String;
	final routingKey:RoutingKey<Message>;
	final serialize:Message->Chunk;
}

@:callable
abstract RoutingKey<Message>(Message->String) from Message->String to Message->String {
	@:from
	public static inline function ofString<Message>(v:String):RoutingKey<Message> {
		return _ -> v;
	}
}