package why.pubsub.mqtt;

import why.pubsub.mqtt.Mqtt;

@:genericBuild(why.pubsub.mqtt.Publishers.build())
class Publishers<T> {}

typedef PublishersBase = MqttBase;