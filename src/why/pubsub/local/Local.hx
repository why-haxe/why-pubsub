package why.pubsub.local;

import haxe.Timer;
import why.pubsub.Envelope;
import tink.Chunk;

using tink.CoreApi;

@:genericBuild(why.pubsub.local.Local.build())
class Local<PubSub> {}

class LocalBase {
	
	final messages:Map<String, Array<Chunk>>;
	final pollInterval:Int;
	
	public function new(pollInterval) {
		this.messages = new Map();
		this.pollInterval = pollInterval;
	}
	
	inline function ensure(name:String) {
		if(!messages.exists(name)) messages[name] = [];
	}
	
	public function publish(names:Names, message:Chunk):Promise<Noise> {
		for(name in names) {
			ensure(name);
			messages[name].push(message);
		}
		return Promise.NOISE;
	}
	
	public function subscribe(name:String, f:Chunk->(()->Void)->Void):CallbackLink {
		ensure(name);
		var timer = new Timer(pollInterval); // polling
		timer.run = function() {
			switch messages[name].shift() {
				case null: // do nth
				case v: f(v, messages[name].unshift.bind(v));
			}
		}
		return timer.stop;
	}
}