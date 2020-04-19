package why.pubsub.amqp;

import amqp.AmqpConnectionManager;

@:genericBuild(why.pubsub.amqp.Publishers.build())
class Publishers<T> {}

class PublishersBase {
	final manager:AmqpConnectionManager;
	
	public function new(manager) {
		this.manager = manager;
	}
}