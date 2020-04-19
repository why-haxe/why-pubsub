package why.pubsub.local;

import tink.core.ext.Subscription;
import tink.Chunk;
import why.pubsub.Subscriber.Handler;
import why.pubsub.local.Local;

using tink.CoreApi;

class Subscriber<Message> implements why.pubsub.Subscriber<Message> {
	
	final local:LocalBase;
	final config:SubscriberConfig<Message>;
	
	public function new(local, config) {
		this.local = local;
		this.config = config;
	}
		
	public function subscribe(handler:Handler<Message>):Subscription {
		var binding = local.subscribe(config.to, function(chunk, retry) {
			handler(new Envelope(config.unserialize(chunk), retry));
		});
		
		return new SimpleSubscription(binding, Signal.trigger());
	}
}

typedef SubscriberConfig<Message> = {
	final to:String;
	final unserialize:Chunk->Outcome<Message, Error>;
}

class Envelope<Message> implements why.pubsub.Envelope<Message> {
	public final id:String = null;
	public final content:Outcome<Message, Error>;
	
	final retry:()->Void;
	
	public function new(content, retry) {
		this.content = content;
		this.retry = retry;
	}
	
	public function ack():Void {
		// ok
	}
	
	public function nack():Void {
		retry();
	}
}