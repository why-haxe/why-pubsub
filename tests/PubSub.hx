package;

import why.pubsub.*;

typedef PubSub = why.PubSub<Publishers, Subscribers>;

interface Publishers {
	@:pubsub({serialize: v -> haxe.Serializer.run(v)})
	@:pubsub.amqp({exchange: 'foo', routingKey: ''})
	@:pubsub.local({to: 'foo'})
	var foo(get, never):Publisher<{foo:Int, bar:String}>;
	
	@:pubsub({serialize: v -> haxe.Serializer.run(v)})
	@:pubsub.amqp({exchange: 'variant', routingKey: 'variant.$id'})
	@:pubsub.local({to: 'variant_$id'})
	@:pubsub.cache({key: id})
	function variant(id:String):Publisher<{foo:Int, bar:String}>;
	
	@:pubsub({serialize: v -> haxe.Serializer.run(v)})
	@:pubsub.amqp({exchange: 'cache', routingKey: 'cache.$id'})
	@:pubsub.local({to: 'cache_$id'})
	@:pubsub.cache({key: id + foo + bar})
	function cache(id:String, foo:Int, bar:Bool):Publisher<{foo:Int, bar:String}>;
	
}

interface Subscribers {
	@:pubsub({unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:pubsub.amqp({queue: 'bar', prefetch: 2})
	@:pubsub.local({to: 'foo'})
	var bar(get, never):Subscriber<{foo:Int, bar:String}>;
	
	@:pubsub({unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:pubsub.amqp({queue: 'variant_$id', prefetch: 2})
	@:pubsub.local({to: 'variant_$id'})
	@:pubsub.cache({key: id})
	function variant(id:String):Subscriber<{foo:Int, bar:String}>;
	
	@:pubsub({unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:pubsub.amqp({queue: 'cache_$id', prefetch: 2})
	@:pubsub.local({to: 'cache_$id'})
	@:pubsub.cache({key: id + foo + bar})
	function cache(id:String, foo:Int, bar:Bool):Subscriber<{foo:Int, bar:String}>;
}