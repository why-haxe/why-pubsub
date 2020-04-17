package why.pubsub.rabbitmq;

import amqp.AmqpConnectionManager;

using tink.CoreApi;

@:genericBuild(why.pubsub.rabbitmq.RabbitMq.build())
class RabbitMq<Pub, Sub> {}

class RabbitMqBase {
	final manager:AmqpConnectionManager;
	
	public function new(manager) {
		this.manager = manager;
	}
	
	public function sync(config:RabbitMqConfig):Promise<Noise> {
		// TODO: remove existing bindings that are not specified in config
		return Future.async(function(cb) {
			var wrapped;
			wrapped = manager.createChannel({
				setup: channel -> {
					Promise.inParallel([for(exchange in config.exchanges) Promise.ofJsPromise(channel.assertExchange(exchange.name, exchange.type))])
						.next(_ -> Promise.inParallel([for(queue in config.queues) Promise.ofJsPromise(channel.assertQueue(queue.name))]))
						.next(_ -> Promise.inParallel([for(queue in config.queues) for(binding in queue.bindings) Promise.ofJsPromise(channel.bindQueue(queue.name, binding.exchange, binding.pattern))]))
						.noise()
						.map(o -> {
							haxe.Timer.delay(function() wrapped.close(), 0);
							cb(o);
							o;
						})
						.asPromise()
						.swap((null:Any))
						.toJsPromise();
				}
			});
		});
	}
}

typedef RabbitMqConfig = {
	final exchanges:Array<ExchangeConfig>;
	final queues:Array<QueueConfig>;
}

typedef ExchangeConfig = {
	final name:String;
	final type:String;
}
typedef QueueConfig = {
	final name:String;
	final bindings:Array<BindingConfig>;
}
typedef BindingConfig = {
	final exchange:String;
	final pattern:String;
}