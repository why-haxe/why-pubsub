package why.pubsub.rabbitmq;

import amqp.AmqpConnectionManager;

@:genericBuild(why.pubsub.rabbitmq.Publishers.build())
class Publishers<T> {}

class PublishersBase {
	final manager:AmqpConnectionManager;
	
	public function new(manager) {
		this.manager = manager;
	}
}