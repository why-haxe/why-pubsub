package why;

import why.pubsub.Adapter;

#if !macro

@:autoBuild(why.PubSub.build())
class PubSub {
	var adapter:Adapter;
	
	public function new(adapter) {
		this.adapter = adapter;
	}
}

#else

import haxe.macro.Expr;
using tink.MacroApi;

class PubSub {
	public static function build() {
		var builder = new ClassBuilder();
		
		for(member in builder) {
			
			switch member.kind {
				case FVar(ct, _):
					function extractTopics(name:String) {
						return switch member.metaNamed(name) {
							case []: [];
							case meta:
								var topics = [];
								for(m in meta) topics = topics.concat(m.params.map(function(e) return e.getString().sure()));
								topics;
						}
					}
					
					var serializer = switch member.metaNamed(':pubsubSerializer') {
						case []: macro function(v:$ct):tink.Chunk return tink.Json.stringify(v);
						case [{params: [e]}]: e;
						case _: member.pos.error('Invalid use of @:pubsubSerializer');
					}
					
					var unserializer = switch member.metaNamed(':pubsubUnerializer') {
						case []: macro function(c:tink.Chunk):$ct return tink.Json.parse(c);
						case [{params: [e]}]: e;
						case _: member.pos.error('Invalid use of @:pubsubUnerializer');
					}
					
					switch [extractTopics(':pub'), extractTopics(':sub'), extractTopics(':pubsub')] {
						case [[], [], []]: // skip
						case [pubs, subs, pubsubs]:
							var pubs = macro $a{unique(pubs.concat(pubsubs)).map(function(s) return macro $v{s})};
							var subs = macro $a{unique(subs.concat(pubsubs)).map(function(s) return macro $v{s})};
							member.kind = FProp('get', 'null', macro:why.pubsub.Field<$ct>, null);
							
							var field = macro $i{member.name};
							var getter = 'get_' + member.name;
							builder.addMembers(macro class {
								function $getter() {
									if($field == null) $field = new why.pubsub.Field<$ct>($pubs, $subs, adapter, $serializer, $unserializer);
									return $field;
								}
							});
					}
				
				case _:
					
			}
			
		}
		
		return builder.export();
	}
	
	static function unique<T>(a:Array<T>) {
		var ret = [];
		for(i in a) if(ret.indexOf(i) == -1) ret.push(i);
		return ret;
	}
	
	// public static function buildField() {
	// 	return tink.macro.BuildCache.getType('pubsub.Field', function(ctx) {
	// 		var ct = ctx.type.toComplex();
	// 		var name = ctx.name;
	// 		var pos = ctx.pos;
	// 		var def = macro class $name extends pubsub.Builder.Base {
	// 			public function publish(value:$ct):tink.core.Promise<tink.core.Noise> {
	// 				var payload = tink.Chunk.EMPTY; // TODO
	// 				return tink.core.Promise.inParallel([for(topic in pubs) pubsub.publish(topic, payload)]);
	// 			}
				
	// 			public function subscribe(handler:tink.core.Callback<$ct>):tink.core.Callback.CallbackLink {
	// 				function callback(pair) handler.invoke(null); // TODO
	// 				return [for(topic in subs) pubsub.subscribe(topic, callback)];
	// 			}
	// 		}
			
	// 		def.pack = ['pubsub'];
			
	// 		return def;
	// 	});
	// }
}

#end