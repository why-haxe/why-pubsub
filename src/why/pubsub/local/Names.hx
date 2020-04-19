package why.pubsub.local;

@:forward
abstract Names(Array<String>) from Array<String> to Array<String> {
	@:from public static inline function single(v):Names return [v];
}