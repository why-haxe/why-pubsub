package why.pubsub;

import tink.Chunk;

using tink.CoreApi;

class Field<T> {
	var pubs:Array<String>;
	var subs:Array<String>;
	var driver:Driver;
	var serialize:T->Chunk;
	var unserialize:Chunk->T;
	
	public function new(pubs, subs, driver, serialize, unserialize) {
		this.pubs = pubs;
		this.subs = subs;
		this.driver = driver;
		this.serialize = serialize;
		this.unserialize = unserialize;
	}
	
	public function publish(value:T):Promise<Noise> {
		var payload = serialize(value);
		return Promise.inParallel([for(topic in pubs) driver.publish(topic, payload)]);
	}
	
	public function subscribe(handler:Callback<T>):CallbackLink {
		function callback(pair:Pair<String, Chunk>) handler.invoke(unserialize(pair.b));
		return [for(topic in subs) driver.subscribe(topic, callback)];
	}
}