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
				var ct = f.type.toComplex();
				var msgCt = f.messageType.toComplex();
				var name = f.name;
				var getter = 'get_$name';
				var config = switch f.meta.extract(':why.pubsub.rabbitmq') {
					case []: f.pos.error('Missing config via meta @:why.pubsub.rabbitmq');
					case [{params: [expr]}]: macro ($expr:{exchange:String, routingKey:String, serialize:$msgCt->tink.Chunk});
					case [{pos: pos}]: pos.error('@:why.pubsub.rabbitmq requires exactly one parameter');
					case _: f.pos.error('Only one @:why.pubsub.rabbitmq is allowed');
				}
				
				def.fields = def.fields.concat((macro class {
					public var $name(get, null):$ct;
					function $getter():$ct {
						if($i{name} == null) {
							var config = $config;
							$i{name} = new why.pubsub.rabbitmq.Publisher(manager, config.exchange, config.routingKey, config.serialize);
						}
						return $i{name};
					}
					
				}).fields);
			}
			
			def.pack = ['why', 'pubsub', 'rabbitmq'];
			def;
		});
	}
	
	static function getFields(type:Type, pos:Position) {
		return switch type {
			case TInst(_.get() => {isInterface: true, fields: _.get() => fields}, _): 
				[for(f in fields) switch f.type {
					case TInst(_.get() => {pack: ['why', 'pubsub'], name: 'Publisher'}, [msg]):
						{
							name: f.name,
							pos: f.pos,
							meta: f.meta,
							type: f.type,
							messageType: msg,
						}
					case _:
						f.pos.error('Only why.pubsub.Publisher<T> is supported here');
				}];
			case _:
				pos.error('Expected interface');
		}
	} 
}