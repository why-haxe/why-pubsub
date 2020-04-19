package why.pubsub.local;

import why.pubsub.local.Local;

@:genericBuild(why.pubsub.local.Subscribers.build())
class Subscribers<T> {}

class SubscribersBase {
	final local:LocalBase;
	
	public function new(local) {
		this.local = local;
	}
}