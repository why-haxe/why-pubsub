package why.pubsub.local;

import tink.Chunk;
import why.pubsub.local.Local;

using tink.CoreApi;

class Publisher<Message> implements why.pubsub.Publisher<Message> {
	
	final local:LocalBase;
	final config:PublisherConfig<Message>;
	
	public function new(local, config) {
		this.local = local;
		this.config = config;
	}
		
	public function publish(message:Message):Promise<Noise> {
		return local.publish(config.to, config.serialize(message));
	}
}

typedef PublisherConfig<Message> = {
	final to:Names;
	final serialize:Message->Chunk;
}