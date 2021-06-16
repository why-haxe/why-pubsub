package why.pubsub.local;

import tink.core.ext.Subscription;
import tink.Chunk;
import why.pubsub.Subscriber.Handler;
import why.pubsub.local.Local;

using tink.CoreApi;

class Subscriber<Message, Metadata> implements why.pubsub.Subscriber<Message, Metadata> {
	
	final local:LocalBase;
	final config:SubscriberConfig<Message, Metadata>;
	
	public function new(local, config) {
		this.local = local;
		this.config = config;
	}
		
	public function subscribe(handler:Handler<Message, Metadata>):Subscription {
		var binding = local.subscribe(config.to, function(chunk, retry) {
			handler(new Envelope(chunk, config.unserialize.bind(chunk), config.metadata, retry));
		});
		
		return new SimpleSubscription(binding, Signal.trigger());
	}
}

typedef SubscriberConfig<Message, Metadata> = {
	final to:String;
	final unserialize:Chunk->Outcome<Message, Error>;
	final metadata:()->Metadata;
}

class Envelope<Message, Metadata> implements why.pubsub.Envelope<Message, Metadata> {
	public final id:String = null;
	public final raw:Chunk;
	public final content:Lazy<Outcome<Message, Error>>;
	public final metadata:Lazy<Metadata>;
	
	final retry:()->Void;
	
	public function new(raw, content, metadata, retry) {
		this.raw = raw;
		this.content = content;
		this.metadata = metadata;
		this.retry = retry;
	}
	
	public function ack():Void {
		// ok
	}
	
	public function nack():Void {
		retry();
	}
}