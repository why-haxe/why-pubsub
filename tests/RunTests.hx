package;

import tink.testrunner.*;
import tink.unit.*;

class RunTests {

	static function main() {
		var local = new why.pubsub.local.Local<PubSub>(20);
		
		var manager = amqp.AmqpConnectionManager.connect(['amqp://localhost']);
		var amqp = new why.pubsub.amqp.Amqp<PubSub>(manager);
		
		Runner.run(TestBatch.make([
			new PubSubTest(local),
			new PubSubTest(amqp),
		])).handle(Runner.exit);
	}
}

