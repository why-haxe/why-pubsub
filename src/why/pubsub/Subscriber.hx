package why.pubsub;

using tink.CoreApi;

interface Subscriber<Message> {
	function subscribe(handler:Envelope<Message>->Void):Subscription;
}