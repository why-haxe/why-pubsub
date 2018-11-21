package why.pubsub;

import tink.Chunk;

using tink.CoreApi;

class Field<Abstract, Concrete, Data> {
	var pubs:Array<Concrete>;
	var subs:Array<Concrete>;
	var adapter:Adapter<Concrete>;
	var translator:Translator<Abstract, Concrete>;
	var serialize:Data->Chunk;
	var unserialize:Chunk->Data;
	
	public function new(adapter, translator, pubs, subs, serialize, unserialize) {
		this.adapter = adapter;
		this.translator = translator;
		this.pubs = pubs.map(translator.concrete);
		this.subs = subs.map(translator.concrete);
		this.serialize = serialize;
		this.unserialize = unserialize;
	}
	
	public function publish(value:Data):Promise<Noise> {
		var payload = serialize(value);
		return Promise.inParallel([for(topic in pubs) adapter.publish(topic, payload)]);
	}
	
	public function subscribe(handler:Callback<Pair<Abstract, Data>>):Promise<CallbackLink> {
		function callback(pair:Pair<Concrete, Chunk>)
			handler.invoke(new Pair(translator.abstractify(pair.a), unserialize(pair.b)));
			
		return Promise.inParallel([for(topic in subs) adapter.subscribe(topic, callback)])
			.next(CallbackLink.fromMany);
	}
}