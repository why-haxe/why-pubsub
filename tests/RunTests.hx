package;

import tink.testrunner.*;
import tink.unit.*;

class RunTests {

	static function main() {
		var local = new why.pubsub.local.Local<PubSub>(20);
		
		var manager = amqp.AmqpConnectionManager.connect(['amqp://localhost']);
		var amqp = new why.pubsub.amqp.Amqp<PubSub>(manager);
		
		var client = new why.mqtt.client.MqttJsClient({url: 'mqtt://test.mosquitto.org:1883'});
		var mqtt = new why.pubsub.mqtt.Mqtt<PubSub>(client);
		
		Runner.run(TestBatch.make([
			new PubSubTest(local),
			new PubSubTest(amqp),
			new PubSubTest(mqtt),
		])).handle(Runner.exit);
	}
}

