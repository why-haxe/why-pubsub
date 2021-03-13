package why.pubsub;

import tink.Chunk;
using tink.CoreApi;

interface Envelope<Message> {
	final id:String;
	final raw:Chunk;
	final content:Lazy<Outcome<Message, Error>>;
	
	/*
		The following methods are only relevant for message-queue-style pub/sub such as AMQP (e.g. RabbitMQ)
		where each message in a queue will only be processed by one consumer.
		
		For broadcast-style pub/sub such as MQTT, they are no-op.
	*/
	function ack():Void;
	function nack():Void;
}