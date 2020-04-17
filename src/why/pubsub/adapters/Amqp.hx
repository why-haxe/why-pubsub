package why.pubsub.adapters;

class Amqp implements Adapter<Topic> {
	public function publish(topic:Topic, payload:Chunk):Promise<Noise>;
	public function subscribe(topic:Topic, handler:Callback<Pair<Topic, Chunk>>):Subscription;
}

enum PublishTarget {
	Exchange(name:String);
	Queue(name:String);
}

enum SubscribeTarget {
	Exchange(name:String);
	Queue(name:String);
}