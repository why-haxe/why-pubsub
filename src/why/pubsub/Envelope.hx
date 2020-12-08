package why.pubsub;

import tink.Chunk;
using tink.CoreApi;

interface Envelope<Message> {
	final id:String;
	final raw:Chunk;
	final content:Outcome<Message, Error>;
	
	function ack():Void;
	function nack():Void;
}