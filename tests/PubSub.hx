package;

import why.pubsub.*;

typedef PubSub = why.PubSub<Publishers, Subscribers>;

interface Publishers {
	@:pubsub({serialize: v -> haxe.Serializer.run(v)})
	@:pubsub.rabbitmq({exchange: 'foo', routingKey: ''})
	@:pubsub.local({name: 'foo'})
	var foo(get, never):Publisher<{foo:Int, bar:String}>;
	
	@:pubsub({serialize: v -> haxe.Serializer.run(v)})
	@:pubsub.rabbitmq({exchange: 'variant', routingKey: 'variant.$id'})
	@:pubsub.local({name: 'variant_$id'})
	@:pubsub.cache({key: id})
	function variant(id:String):Publisher<{foo:Int, bar:String}>;
	
	@:pubsub({serialize: v -> haxe.Serializer.run(v)})
	@:pubsub.rabbitmq({exchange: 'cache', routingKey: 'cache.$id'})
	@:pubsub.local({name: 'cache_$id'})
	@:pubsub.cache({key: id + foo + bar})
	function cache(id:String, foo:Int, bar:Bool):Publisher<{foo:Int, bar:String}>;
	
}

interface Subscribers {
	@:pubsub({unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:pubsub.rabbitmq({queue: 'bar', prefetch: 2})
	@:pubsub.local({name: 'foo'})
	var bar(get, never):Subscriber<{foo:Int, bar:String}>;
	
	@:pubsub({unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:pubsub.rabbitmq({queue: 'variant_$id', prefetch: 2})
	@:pubsub.local({name: 'variant_$id'})
	@:pubsub.cache({key: id})
	function variant(id:String):Subscriber<{foo:Int, bar:String}>;
	
	@:pubsub({unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:pubsub.rabbitmq({queue: 'cache_$id', prefetch: 2})
	@:pubsub.local({name: 'cache_$id'})
	@:pubsub.cache({key: id + foo + bar})
	function cache(id:String, foo:Int, bar:Bool):Subscriber<{foo:Int, bar:String}>;
}