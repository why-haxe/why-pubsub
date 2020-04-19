package why.pubsub.amqp;

import amqp.AmqpConnectionManager;

@:genericBuild(why.pubsub.amqp.Subscribers.build())
class Subscribers<T> {}

class SubscribersBase {
	final manager:AmqpConnectionManager;
	
	public function new(manager) {
		this.manager = manager;
	}
}