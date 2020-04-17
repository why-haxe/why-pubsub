package why.pubsub.rabbitmq;

import amqp.AmqpConnectionManager;

@:genericBuild(why.pubsub.rabbitmq.RabbitMq.build())
class RabbitMq<Pub, Sub> {}

class RabbitMqBase {}