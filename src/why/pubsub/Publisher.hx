package why.pubsub;

using tink.CoreApi;

interface Publisher<Message> {
	function publish(message:Message):Promise<Noise>;
}