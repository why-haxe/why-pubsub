# Why PubSub

Abstraction of various (cloud) pub/sub systems.

## Interface

A quick glance:

```haxe
interface Publisher<Message> {
	function publish(message:Message):Promise<Noise>;
}

interface Subscriber<Message> {
	function subscribe(handler:Envelope<T>->Void):Subscription;
}

interface Envelope<Message> {
	final content:Outcome<Message, Error>;
	function ack():Void;
	function nack():Void;
}
```

## Usage

Define two interfaces containing all the publishers and subscribers needed. 
Then, pick an implementation class and use the interfaces as type parameters, wrapped by `why.PubSub`.

Example:

```haxe
var amqp = new why.pubsub.amqp.Amqp<MyPubSub>(...);
var pubsub:MyPubSub = amqp; // ok, the instance will implement the specified interface

typedef MyPubSub = why.PubSub<Publishers, Subscribers>;

interface Publishers {
	@:pubsub({serialize: v -> haxe.Serializer.run(v)})
	@:pubsub.amqp({exchange: 'foo', routingKey: ''})
	var foo(get, never):Publisher<{foo:Int, bar:String}>;
	
	
	@:pubsub({serialize: v -> haxe.Serializer.run(v)})
	@:pubsub.amqp({exchange: 'cache', routingKey: 'cache.$id'})
	@:pubsub.cache({key: id + foo + bar})
	function cache(id:String, foo:Int, bar:Bool):Publisher<{foo:Int, bar:String}>;
}

interface Subscribers {
	@:pubsub({unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:pubsub.amqp({queue: 'bar', prefetch: 2})
	var bar(get, never):Subscriber<{foo:Int, bar:String}>;
	
	
	@:pubsub({unserialize: v -> tink.core.Error.catchExceptions(haxe.Unserializer.run.bind(v))})
	@:pubsub.amqp({queue: 'cache_$id', prefetch: 2})
	@:pubsub.cache({key: id + foo + bar})
	function cache(id:String, foo:Int, bar:Bool):Subscriber<{foo:Int, bar:String}>;
}
```

## Implementations

#### `why.pubsub.amqp.Amqp`

Node.js only. Based on the npm package `amqplib` for the AMQP 0-9-1 protocol. Compatible to RabbitMQ.

Use the `.sync({...})` function to set up the exchanges and queues in the broker.

#### `why.pubsub.local.Local`

A simple in-memory message queue. Mainly for local testing.

## Metadata

**`@:pubsub` on Publisher: (required for all implementations)**  

```haxe
{
	// serialize message into binary
	final serialize:T->Chunk;
}
```

**`@:pubsub` on Subscriber: (required for all implementations)**  

```haxe
{
	// unserialize binary into message
	final unserialize:Chunk->Outcome<T, Error>;
}
```

**`@:pubsub.cache` on Publisher & Subscriber: (optional for all implementations)**  

Only applicable to functions. If not specified, every time the function gets called, a new instance will be returned. Otherwise, the returned value will be cached by the key specified.

```haxe
{
	// cache key. function arguments are accessible here
	final key:String;
}
```

**`@:pubsub.local` on Publisher: (required for `Local`)**  

```haxe
{
	// publish messages to this queue name
	final name:String;
}
```

**`@:pubsub.local` on Subscriber: (required for `Local`)**  

```haxe
{
	// subscribe to messages in this queue name
	final name:String;
}
```

**`@:pubsub.amqp` on Publisher: (required for `Amqp`)**  

```haxe
{
	// publish messages to this exchange
	final exchange:String;
	
	// publish messages with this routing key
	final routingKey:String;
}
```

**`@:pubsub.amqp` on Subscriber: (required for `Amqp`)**  

```haxe
{
	// subscribe to messages in this queue
	final queue:String;
	
	// max "in-flight" messages for this subscription (see amqp doc for more info)
	final prefetch:Int;
}
```

## TODO

- [ ] GCP PubSub
- [ ] AWS SQS