package why.pubsub.rabbitmq;

import haxe.macro.Expr;
import haxe.macro.Type;
import tink.macro.BuildCache;

using tink.MacroApi;

class Publishers {
	public static function build() {
		return BuildCache.getType('why.pubsub.rabbitmq.Publishers', (ctx:BuildContext) -> {
			var name = ctx.name;
			var type = ctx.type;
			var ct = type.toComplex();
			var tp = switch ct {
				case TPath(v): v;
				case _: throw 'assert';
			}
			
			var fields = getFields(ctx.type, ctx.pos);
			
			var def = macro class $name extends why.pubsub.rabbitmq.Publishers.PublishersBase implements $tp {}
			
			for(f in fields) {
				var name = f.field.name;
				var msgCt = f.type.toComplex();
				
				var config = macro (${Helper.getConfig(f.field)}:why.pubsub.rabbitmq.Publisher.PublisherConfig<$msgCt>);
				
				switch f.variant {
					case Prop:
						var ct = f.field.type.toComplex();
						var getter = 'get_$name';
						def.fields = def.fields.concat((macro class {
							public var $name(get, null):$ct;
							function $getter():$ct {
								if($i{name} == null)
									$i{name} = new why.pubsub.rabbitmq.Publisher(manager, $config);
								return $i{name};
							}
						}).fields);
						
					case Func(args):
						var ct = macro:why.pubsub.Publisher<$msgCt>;
						
						var body = switch Helper.getCache(f.field, args) {
							case Some(cache):
								var cacheName = '__cache_$name';
								def.fields.push({
									name: cacheName,
									access: [],
									kind: FVar(macro:why.pubsub.Cache<String, $ct>, macro new why.pubsub.Cache.StringCache()),
									pos: f.field.pos,
								});
								
								var callArgs = args.map(arg -> macro $i{arg.name});
								macro {
									var key = $cache.getKey($a{callArgs});
									$i{cacheName}.get(key, _ -> new why.pubsub.rabbitmq.Publisher(manager, $config));
								}
							case None:
								macro new why.pubsub.rabbitmq.Publisher(manager, $config);
						}
						var func = body.func(args.map(arg -> arg.name.toArg(arg.t.toComplex(), arg.opt)), ct);
						def.fields.push({
							name: name,
							access: [APublic],
							kind: FFun(func),
							pos: f.field.pos,
						});
				}
			}
			
			def.pack = ['why', 'pubsub', 'rabbitmq'];
			def;
		});
	}
	
	static function getFields(type:Type, pos:Position) {
		return Helper.getFields(type, 'Publisher', pos);
	} 
}