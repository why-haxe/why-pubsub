package pubsub.driver;

import tink.Chunk;

using tink.CoreApi;

interface Driver {
	function publish(topic:String, payload:Chunk):Promise<Noise>;
	function subscribe(topic:String, handler:Callback<Pair<String, Chunk>>):CallbackLink;
}