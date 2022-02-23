package why.pubsub.mqtt;

import tink.core.ext.Subscription;
import tink.Chunk;
import why.pubsub.Subscriber.Handler;
import why.mqtt.Qos;

using tink.CoreApi;

class Subscriber<Message, Metadata> implements why.pubsub.Subscriber<Message, Metadata> {
	
	final client:why.mqtt.Client;
	final config:SubscriberConfig<Message, Metadata>;
	
	public function new(client, config) {
		this.client = client;
		this.config = config;
	}
		
	public function subscribe(handler:Handler<Message, Metadata>):Subscription {
		final errors = Signal.trigger();
		
		var binding1:CallbackLink = null;
		binding1 = client.subscribe(config.topic, config).handle(o -> switch o {
			case Success(sub): binding1 = sub;
			case Failure(e): errors.trigger(e);
		});
		
		final binding2 = client.messageReceived.handle(message -> {
			if(config.topic.match(message.topic))
				handler(new Envelope(message.payload, config.unserialize.bind(message.payload), config.metadata.bind(message)));
		});
		
		return new SimpleSubscription(() -> {
			binding1.cancel();
			binding2.cancel();
		}, Signal.trigger());
	}
}

typedef SubscriberConfig<Message, Metadata> = {
	final topic:why.mqtt.Topic;
	final ?qos:Qos;
	final unserialize:Chunk->Outcome<Message, Error>;
	final metadata:why.mqtt.Message->Metadata; // TODO: mqtt meta
}

class Envelope<Message, Metadata> implements why.pubsub.Envelope<Message, Metadata> {
	public final id:String = null;
	public final raw:Chunk;
	public final content:Lazy<Outcome<Message, Error>>;
	public final metadata:Lazy<Metadata>;
	
	public function new(raw, content, metadata) {
		this.raw = raw;
		this.content = content;
		this.metadata = metadata;
	}
	
	public function ack():Void {
		// nothing to do
	}
	
	public function nack():Void {
		// nothing to do
	}
}