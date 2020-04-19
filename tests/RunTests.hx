package;

import tink.testrunner.*;
import tink.unit.*;

class RunTests {

	static function main() {
		var local = new why.pubsub.local.Local<PubSub>(20);
		
		var manager = amqp.AmqpConnectionManager.connect(['amqp://localhost']);
		var rabbitmq = new why.pubsub.rabbitmq.RabbitMq<PubSub>(manager);
		
		
		Runner.run(TestBatch.make([
			new PubSubTest(local),
			new PubSubTest(rabbitmq),
		])).handle(Runner.exit);
	}
}

