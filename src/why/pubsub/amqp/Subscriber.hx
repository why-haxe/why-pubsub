package why.pubsub.amqp;

import tink.core.ext.Subscription;
import amqp.AmqpConfirmChannel;
import amqp.AmqpMsg;
import amqp.AmqpConnectionManager;
import why.pubsub.Subscriber.Handler;
import tink.Anon.merge;
import tink.Chunk;

using tink.CoreApi;

class Subscriber<Message, Metadata> implements why.pubsub.Subscriber<Message, Metadata> {
	
	final manager:AmqpConnectionManager;
	final config:SubscriberConfig<Message, Metadata>;
	
	public function new(manager:AmqpConnectionManager, config) {
		this.manager = manager;
		this.config = config;
	}
		
	public function subscribe(handler:Handler<Message, Metadata>):Subscription {
		var wrapper = manager.createChannel({
			setup: channel -> {
				channel.prefetch(config.prefetch);
				channel.consume(config.queue, function(msg) {
					var envelope:why.pubsub.Envelope<Message, Metadata> = new Envelope(channel, msg, msg.content, config.unserialize.bind(msg.content), config.metadata.bind(merge(msg)));
					handler(envelope);
				});
				js.lib.Promise.resolve();
			}
		});
		
		var error = new Signal(cb -> {
			wrapper.on('error', function onError(e)
				cb #if (tink_core < "2").invoke #end (Error.ofJsError(e)));
			wrapper.removeListener.bind('error', onError);
		});
		
		return new SimpleSubscription(wrapper.close, error);
	}
}

typedef SubscriberConfig<Message, Metadata> = {
	final queue:String;
	final prefetch:Int;
	final unserialize: Chunk->Outcome<Message, Error>;
	final metadata:AmqpMeta->Metadata;
}

private typedef AmqpMeta = {
	final fields:amqp.AmqpMsg.AmqpMsgFields;
	final properties:amqp.AmqpMsg.AmqpMsgProperties;
}

class Envelope<Message, Metadata> implements why.pubsub.Envelope<Message, Metadata> {
	public final id:String;
	public final raw:Chunk;
	public final content:Lazy<Outcome<Message, Error>>;
	public final metadata:Lazy<Metadata>;
	
	final native:AmqpMsg;
	final channel:AmqpConfirmChannel;
	
	public function new(channel, native, raw, content, metadata) {
		this.channel = channel;
		this.native = native;
		this.id = native.properties == null ? null : native.properties.messageId;
		this.raw = raw;
		this.content = content;
		this.metadata = metadata;
	}
	
	public function ack():Void {
		channel.ack(native);
	}
	
	public function nack():Void {
		channel.nack(native);
	}
}