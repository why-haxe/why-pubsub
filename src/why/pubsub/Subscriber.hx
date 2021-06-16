package why.pubsub;

import tink.core.ext.Subscription;
using tink.CoreApi;

typedef Handler<T, M> = Envelope<T, M>->Void;

interface Subscriber<Message, Metadata> {
	function subscribe(handler:Handler<Message, Metadata>):Subscription;
}