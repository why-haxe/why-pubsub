package why.pubsub;

import tink.core.ext.Subscription;
using tink.CoreApi;

typedef Handler<T> = Envelope<T>->Void;

interface Subscriber<Message> {
	function subscribe(handler:Handler<Message>):Subscription;
}