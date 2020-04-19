package why.pubsub.local;

import haxe.Timer;
import why.pubsub.Envelope;
import tink.Chunk;

using tink.CoreApi;

@:genericBuild(why.pubsub.local.Local.build())
class Local<PubSub> {}

class LocalBase {
	
	final pubs:Map<String, Array<String>>; // pub name => sub names
	final subs:Map<String, Array<Chunk>>; // sub name => messages
	
	public function new() {
		pubs = new Map();
		subs = new Map();
	}
	
	public function sync(config:LocalConfig):Promise<Noise> {
		return Error.catchExceptions(() -> {
			for(pub in config.publishers) {
			if(!pubs.exists(pub.name)) pubs[pub.name] = [];
			}
			for(sub in config.subscribers) {
				if(!subs.exists(sub.name)) subs[sub.name] = [];
				if(pubs[sub.publisher].indexOf(sub.name) == -1) pubs[sub.publisher].push(sub.name);
			}
			Noise;
		});
	}
	
	public function publish(name:String, message:Chunk):Promise<Noise> {
		return Error.catchExceptions(() -> {
			for(sub in pubs[name]) subs[sub].push(message);
			Noise;
		});
	}
	
	public function subscribe(name:String, f:Chunk->(()->Void)->Void):CallbackLink {
		if(!subs.exists(name)) throw 'No subscription named "$name"';
		var timer = new Timer(100); // polling
		timer.run = function() {
			switch subs[name].shift() {
				case null: // do nth
				case v: f(v, subs[name].unshift.bind(v));
			}
		}
		return timer.stop;
	}
}

// class LocalEnvelope<Message> implements Envelope<Message>{
	
// 	public final id:String = null;
// 	public final content:Outcome<Message, Error>;
	
// 	public function new(message) {
// 		content = Success(Message);
// 	}
	
// 	public function ack():Void {
		
// 	}
	
// 	public function nack():Void {
		
// 	}
	
// }

typedef LocalConfig = {
	final publishers:Array<{name:String}>;
	final subscribers:Array<{name:String, publisher:String}>;
}

/*

{
	publishers: [{name: ''}],
	subscribers: [{name: '', publisher: ''}],
}

Pub:
@:pubsub.local({name: ''})

Sub:
@:pubsub.local({name: ''})

*/