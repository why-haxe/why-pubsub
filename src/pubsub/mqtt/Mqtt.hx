package pubsub.mqtt;

import mqtt.Mqtt as MqttLib;
import mqtt.Client as MqttClient;
import tink.Chunk;

using tink.CoreApi;

class Mqtt implements pubsub.PubSub {
	
	var client:MqttClient;
	
	var subscriptions:Map<String, Int>;
	
	public function new(client) {
		this.client = client;
		subscriptions = new Map();
	}
	
	public function publish(topic:String, payload:Chunk):Promise<Noise> {
		if(!MqttLib.isValidTopic(topic)) return new Error('Invalid topic');
		return (client.isConnected.value ? Promise.NOISE : client.connect())
			.next(function(_) return publish(topic, payload));
	}
	
	public function subscribe(pattern:String, handler:Callback<Chunk>):CallbackLink {
		if(!MqttLib.isValidPattern(pattern)) return null; // TODO: maybe need some warning?
		
		subscriptions[pattern] =
			switch subscriptions[pattern] {
				case null | 0:
					client.subscribe(pattern);
					1;
				case v:
					v + 1;
			}
		
		return
			client.message.handle(function(message) if(MqttLib.match(message.a, pattern)) handler.invoke(message.b)) &
			unsubscribe.bind(pattern);
	}
	
	function unsubscribe(pattern) {
		switch subscriptions[pattern] = subscriptions[pattern] - 1 {
			case 0: client.unsubscribe(pattern);
			case _:
		}
	}
}