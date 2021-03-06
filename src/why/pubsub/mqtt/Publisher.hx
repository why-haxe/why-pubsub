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
		final topics = config.topic(message);
		final payload = config.serialize(message);
		final qos = switch config.qos {
			case null: null;
			case f: f(message);
		}
		final retain = switch config.retain {
			case null: null;
			case f: f(message);
		}
		return Promise.inParallel([for(topic in topics) client.publish(new why.mqtt.Message(topic, payload, qos, retain))]);
	}
}

typedef PublisherConfig<Message> = {
	final topic:TopicConfig<Message>;
	final ?qos:why.pubsub.Config<Message, Qos>;
	final ?retain:why.pubsub.Config<Message, Bool>;
	final serialize:Message->Chunk;
}


@:callable
private abstract TopicConfig<Message>(Message->Array<Topic>) from Message->Array<Topic> to Message->Array<Topic> {
	@:from
	public static inline function ofSingle<Message>(v:Topic):TopicConfig<Message> {
		return _ -> [v];
	}
	@:from
	public static inline function ofConst<Message>(v:Array<Topic>):TopicConfig<Message> {
		return _ -> v;
	}
	@:from
	public static inline function ofString<Message>(v:String):TopicConfig<Message> {
		return _ -> [(v:Topic)];
	}
	@:from
	public static inline function ofStringArray<Message>(v:Array<String>):TopicConfig<Message> {
		return _ -> v.map(v -> (v:Topic));
	}
}