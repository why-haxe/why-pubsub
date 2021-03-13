package why.pubsub.mqtt;

import why.mqtt.Client;

using tink.CoreApi;

@:genericBuild(why.pubsub.mqtt.Mqtt.build())
class Mqtt<PubSub> {}

class MqttBase {
	
	public final client:Client;
	
	public function new(client) {
		this.client = client;
	}
}