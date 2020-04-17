package why.pubsub;

using tink.CoreApi;

interface Envelope<Message> {
	final id:String;
	final content:Outcome<Message, Error>;
	
	function ack():Void;
	function nack():Void;
}