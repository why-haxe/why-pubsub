package why.pubsub;

import tink.Chunk;

using tink.CoreApi;

interface Adapter {
	function publish(topic:String, payload:Chunk):Promise<Noise>;
	function subscribe(topic:String, handler:Callback<Pair<String, Chunk>>):CallbackLink;
}