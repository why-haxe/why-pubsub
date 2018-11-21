package why.pubsub;

import tink.Chunk;

using tink.CoreApi;

interface Adapter<Topic> {
	function publish(topic:Topic, payload:Chunk):Promise<Noise>;
	function subscribe(topic:Topic, handler:Callback<Pair<Topic, Chunk>>):Promise<CallbackLink>;
}
