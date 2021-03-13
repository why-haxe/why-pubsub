package why.pubsub;

// a generic per-message config generator

@:callable
abstract Config<Message, Option>(Message->Option) from Message->Option to Message->Option {
	@:from
	public static inline function ofConst<Message, Option>(v:Option):Config<Message, Option> {
		return _ -> v;
	}
}