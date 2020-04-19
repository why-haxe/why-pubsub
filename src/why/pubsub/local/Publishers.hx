package why.pubsub.local;

import why.pubsub.local.Local;

@:genericBuild(why.pubsub.local.Publishers.build())
class Publishers<T> {}

class PublishersBase {
	final local:LocalBase;
	
	public function new(local) {
		this.local = local;
	}
}