package;

import why.pubsub.*;

typedef PubSub = why.PubSub<Publishers, Subscribers>;

interface Publishers {
	@:pubsub({serialize: v -> haxe.Serializer.run(v)})
	@:pubsub.amqp({exchange: 'foo', routingKey: ''})
	@:pubsub.mqtt({topic: 'haxe/why/pubsub/mqtt/foo'})
	@:pubsub.local({to: 'foo'})
	var foo(get, never):Publisher<{foo:Int, bar:String}>;
	
	@:pubsub({serialize: v -> haxe.Serializer.run(v)})
	@:pubsub.amqp({exchange: 'variant', routingKey: 'variant.$id'})
	@:pubsub.mqtt({topic: 'haxe/why/pubsub/mqtt/variant_$id'})
	@:pubsub.local({to: 'variant_$id'})
	@:pubsub.cache({key: id})
	function variant(id:String):Publisher<{foo:Int, bar:String}>;
	
	@:pubsub({serialize: v -> haxe.Serializer.run(v)})
	@:pubsub.amqp({exchange: 'cache', routingKey: 'cache.$id'})
	@:pubsub.mqtt({topic: 'haxe/why/pubsub/mqtt/cache_$id'})
	@:pubsub.local({to: 'cache_$id'})
	@:pubsub.cache({key: id + foo + bar})
	function cache(id:String, foo:Int, bar:Bool):Publisher<{foo:Int, bar:String}>;
	
}

interface Subscribers {
	@:pubsub({unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:pubsub.amqp({queue: 'bar', prefetch: 2, metadata: m -> {key: m.fields.routingKey}})
	@:pubsub.mqtt({topic: 'haxe/why/pubsub/mqtt/foo', metadata: () -> {key: ''}})
	@:pubsub.local({to: 'foo', metadata: () -> {key: ''}})
	var bar(get, never):Subscriber<{foo:Int, bar:String}, Meta>;
	
	@:pubsub({unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:pubsub.amqp({queue: 'variant_$id', prefetch: 2, metadata: m -> {key: m.fields.routingKey}})
	@:pubsub.mqtt({topic: 'haxe/why/pubsub/mqtt/variant_$id', metadata: () -> {key: ''}})
	@:pubsub.local({to: 'variant_$id', metadata: () -> {key: ''}})
	@:pubsub.cache({key: id})
	function variant(id:String):Subscriber<{foo:Int, bar:String}, Meta>;
	
	@:pubsub({unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:pubsub.amqp({queue: 'cache_$id', prefetch: 2, metadata: m -> {key: m.fields.routingKey}})
	@:pubsub.mqtt({topic: 'haxe/why/pubsub/mqtt/cache_$id', metadata: () -> {key: ''}})
	@:pubsub.local({to: 'cache_$id', metadata: () -> {key: ''}})
	@:pubsub.cache({key: id + foo + bar})
	function cache(id:String, foo:Int, bar:Bool):Subscriber<{foo:Int, bar:String}, Meta>;
}

typedef Meta = {
	final key:String;
}