package why.pubsub.rabbitmq;

import amqp.AmqpConnectionManager;

@:genericBuild(why.pubsub.rabbitmq.Subscribers.build())
class Subscribers<T> {}

class SubscribersBase {
	final manager:AmqpConnectionManager;
	
	public function new(manager) {
		this.manager = manager;
	}
}