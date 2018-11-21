package why.pubsub;

import tink.Chunk;

using tink.CoreApi;

class Field<T> {
	var pubs:Array<String>;
	var subs:Array<String>;
	var adapter:Adapter;
	var serialize:T->Chunk;
	var unserialize:Pair<String, Chunk>->T;
	
	public function new(pubs, subs, adapter, serialize, unserialize) {
		this.pubs = pubs;
		this.subs = subs;
		this.adapter = adapter;
		this.serialize = serialize;
		this.unserialize = unserialize;
	}
	
	public function publish(value:T):Promise<Noise> {
		var payload = serialize(value);
		return Promise.inParallel([for(topic in pubs) adapter.publish(topic, payload)]);
	}
	
	public function subscribe(handler:Callback<T>):CallbackLink {
		function callback(pair:Pair<String, Chunk>) handler.invoke(unserialize(pair));
		return [for(topic in subs) adapter.subscribe(topic, callback)];
	}
}