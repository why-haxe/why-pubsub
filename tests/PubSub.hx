package;

import why.pubsub.*;

typedef PubSub = why.PubSub<Publishers, Subscribers>;

interface Publishers {
	@:why.pubsub({serialize: v -> haxe.Serializer.run(v)})
	@:why.pubsub.rabbitmq({exchange: 'foo', routingKey: ''})
	@:why.pubsub.local({name: 'foo'})
	var foo(get, never):Publisher<{foo:Int, bar:String}>;
	
	@:why.pubsub({serialize: v -> haxe.Serializer.run(v)})
	@:why.pubsub.rabbitmq({exchange: 'variant', routingKey: 'variant.$id'})
	@:why.pubsub.local({name: 'variant_$id'})
	@:why.pubsub.cache({key: id})
	function variant(id:String):Publisher<{foo:Int, bar:String}>;
	
	@:why.pubsub({serialize: v -> haxe.Serializer.run(v)})
	@:why.pubsub.rabbitmq({exchange: 'cache', routingKey: 'cache.$id'})
	@:why.pubsub.local({name: 'cache_$id'})
	@:why.pubsub.cache({key: id + foo + bar})
	function cache(id:String, foo:Int, bar:Bool):Publisher<{foo:Int, bar:String}>;
	
}

interface Subscribers {
	@:why.pubsub({unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:why.pubsub.rabbitmq({queue: 'bar', prefetch: 2})
	@:why.pubsub.local({name: 'foo'})
	var bar(get, never):Subscriber<{foo:Int, bar:String}>;
	
	@:why.pubsub({unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:why.pubsub.rabbitmq({queue: 'variant_$id', prefetch: 2})
	@:why.pubsub.local({name: 'variant_$id'})
	@:why.pubsub.cache({key: id})
	function variant(id:String):Subscriber<{foo:Int, bar:String}>;
	
	@:why.pubsub({unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:why.pubsub.rabbitmq({queue: 'cache_$id', prefetch: 2})
	@:why.pubsub.local({name: 'cache_$id'})
	@:why.pubsub.cache({key: id + foo + bar})
	function cache(id:String, foo:Int, bar:Bool):Subscriber<{foo:Int, bar:String}>;
}