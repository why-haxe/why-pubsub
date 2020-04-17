package why.pubsub.adapters;

import mqtt.Mqtt as MqttLib;
import mqtt.Client as MqttClient;
import mqtt.Message as MqttMessage;
import tink.core.ext.Subscription;
import tink.Chunk;

using tink.CoreApi;

/**
 * MQTT
 */
class Mqtt implements why.pubsub.Adapter<MqttMessage, MqttMessage, String> {
	
	var client:MqttClient;
	
	var subscriptions:Map<String, Int>;
	
	public function new(client) {
		this.client = client;
		subscriptions = new Map();
	}
	
	public function publish(message:MqttMessage):Promise<Noise> {
		return
			if(!MqttLib.isValidTopic(message.topic)) new Error('Invalid topic');
			else(client.isConnected.value ? Promise.NOISE : client.connect())
				.next(function(_) return publish(message));
	}
	
	public function subscribe(pattern:String, handler:Callback<MqttMessage>):Subscription {
		
		var error = Future.trigger();
		
		if(!MqttLib.isValidPattern(pattern))
			error.trigger(new Error(BadRequest, 'Invalid topic filter'));
		
		subscriptions[pattern] =
			switch subscriptions[pattern] {
				case null | 0:
					client.subscribe(pattern);
					1;
				case v:
					v + 1;
			}
		
		return new SimpleSubscription(
			client.message.handle(function(message) if(MqttLib.match(message.topic, pattern)) handler.invoke(message)) & unsubscribe.bind(pattern),
			error
		);
	}
	
	function unsubscribe(pattern) {
		switch subscriptions[pattern] = subscriptions[pattern] - 1 {
			case 0: client.unsubscribe(pattern);
			case _:
		}
	}
}