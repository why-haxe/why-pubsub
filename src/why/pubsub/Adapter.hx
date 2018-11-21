package why.pubsub;

import tink.Chunk;

using tink.CoreApi;

interface Adapter<Topic> {
	function publish(topic:Topic, payload:Chunk):Promise<Noise>;
	function subscribe(topic:Topic, handler:Callback<Outcome<Pair<Topic, Chunk>, Error>>):CallbackLink;
}
