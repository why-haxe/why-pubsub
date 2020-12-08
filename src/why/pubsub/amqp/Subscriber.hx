package why.pubsub.amqp;

import tink.core.ext.Subscription;
import amqp.AmqpConfirmChannel;
import amqp.AmqpMsg;
import amqp.AmqpConnectionManager;
import why.pubsub.Subscriber.Handler;
import tink.Chunk;

using tink.CoreApi;

class Subscriber<Message> implements why.pubsub.Subscriber<Message> {
	
	final manager:AmqpConnectionManager;
	final config:SubscriberConfig<Message>;
	
	public function new(manager:AmqpConnectionManager, config) {
		this.manager = manager;
		this.config = config;
	}
		
	public function subscribe(handler:Handler<Message>):Subscription {
		var wrapper = manager.createChannel({
			setup: channel -> {
				channel.prefetch(config.prefetch);
				channel.consume(config.queue, function(msg) {
					var envelope:why.pubsub.Envelope<Message> = new Envelope(channel, msg, msg.content, config.unserialize(msg.content));
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

typedef SubscriberConfig<Message> = {
	final queue:String;
	final prefetch:Int;
	final unserialize:Chunk->Outcome<Message, Error>;
}

class Envelope<Message> implements why.pubsub.Envelope<Message> {
	public final id:String;
	public final raw:Chunk;
	public final content:Outcome<Message, Error>;
	
	final native:AmqpMsg;
	final channel:AmqpConfirmChannel;
	
	public function new(channel, native, raw, content) {
		this.channel = channel;
		this.native = native;
		this.id = native.properties == null ? null : native.properties.messageId;
		this.raw = raw;
		this.content = content;
	}
	
	public function ack():Void {
		channel.ack(native);
	}
	
	public function nack():Void {
		channel.nack(native);
	}
}