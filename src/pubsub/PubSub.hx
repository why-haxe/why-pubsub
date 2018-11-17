package pubsub;

import tink.Chunk;

using tink.CoreApi;

interface PubSub {
	function publish(topic:String, payload:Chunk):Promise<Noise>;
	function subscribe(topic:String, handler:Callback<Chunk>):CallbackLink;
}