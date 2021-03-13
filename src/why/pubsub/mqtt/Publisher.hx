package why.pubsub.mqtt;

import tink.Chunk;
import why.mqtt.Client;
import why.mqtt.Topic;
import why.mqtt.Qos;

using tink.CoreApi;

class Publisher<Message> implements why.pubsub.Publisher<Message> {
	
	final client:Client;
	final config:PublisherConfig<Message>;
	
	public function new(client, config) {
		this.client = client;
		this.config = config;
	}
		
	public function publish(message:Message):Promise<Noise> {
		return client.publish(new why.mqtt.Message(
			config.topic(message),
			config.serialize(message),
			switch config.qos {
				case null: null;
				case f: f(message);
			},
			switch config.retain {
				case null: null;
				case f: f(message);
			}
		));
	}
}

typedef PublisherConfig<Message> = {
	final topic:TopicConfig<Message>;
	final ?qos:why.pubsub.Config<Message, Qos>;
	final ?retain:why.pubsub.Config<Message, Bool>;
	final serialize:Message->Chunk;
}


@:callable
private abstract TopicConfig<Message>(Message->Topic) from Message->Topic to Message->Topic {
	@:from
	public static inline function ofConst<Message>(v:Topic):TopicConfig<Message> {
		return _ -> v;
	}
	@:from
	public static inline function ofString<Message>(v:String):TopicConfig<Message> {
		return _ -> (v:Topic);
	}
}