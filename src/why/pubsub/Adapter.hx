package why.pubsub;

import tink.Chunk;
import tink.core.ext.Subscription;

using tink.CoreApi;

interface Adapter<Outgoing, Incoming, Filter> {
	function publish(payload:Outgoing):Promise<Noise>;
	function subscribe(filter:Filter, handler:Callback<Incoming>):Subscription;
}
