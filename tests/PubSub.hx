package;

import why.pubsub.*;

typedef PubSub = why.PubSub<Publishers, Subscribers>;

interface Publishers {
	@:why.pubsub.rabbitmq({exchange: 'foo', routingKey: '', serialize: v -> haxe.Serializer.run(v)})
	@:why.pubsub.local({name: 'foo', serialize: v -> haxe.Serializer.run(v)})
	var foo(get, never):Publisher<{foo:Int, bar:String}>;
	
	@:why.pubsub.rabbitmq({exchange: 'variant', routingKey: 'variant.$id', serialize: v -> haxe.Serializer.run(v)})
	@:why.pubsub.local({name: 'variant_$id', serialize: v -> haxe.Serializer.run(v)})
	@:why.pubsub.cache({key: id})
	function variant(id:String):Publisher<{foo:Int, bar:String}>;
	
	@:why.pubsub.rabbitmq({exchange: 'cache', routingKey: 'cache.$id', serialize: v -> haxe.Serializer.run(v)})
	@:why.pubsub.local({name: 'cache_$id', serialize: v -> haxe.Serializer.run(v)})
	@:why.pubsub.cache({key: id + foo + bar})
	function cache(id:String, foo:Int, bar:Bool):Publisher<{foo:Int, bar:String}>;
	
}

interface Subscribers {
	@:why.pubsub.rabbitmq({queue: 'bar', prefetch: 2, unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:why.pubsub.local({name: 'foo', unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	var bar(get, never):Subscriber<{foo:Int, bar:String}>;
	
	@:why.pubsub.rabbitmq({queue: 'variant_$id', prefetch: 2, unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:why.pubsub.local({name: 'variant_$id', unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:why.pubsub.cache({key: id})
	function variant(id:String):Subscriber<{foo:Int, bar:String}>;
	
	@:why.pubsub.rabbitmq({queue: 'cache_$id', prefetch: 2, unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:why.pubsub.local({name: 'cache_$id', unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:why.pubsub.cache({key: id + foo + bar})
	function cache(id:String, foo:Int, bar:Bool):Subscriber<{foo:Int, bar:String}>;
}