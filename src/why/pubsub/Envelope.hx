package why.pubsub;

interface Envelope<Message> {
	final id:String;
	final content:Message;
	
	function ack():Void;
	function nack():Void;
}