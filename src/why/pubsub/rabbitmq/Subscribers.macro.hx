package why.pubsub.rabbitmq;

import haxe.macro.Expr;
import haxe.macro.Type;
import tink.macro.BuildCache;

using tink.MacroApi;

class Subscribers {
	public static function build() {
		return BuildCache.getType('why.pubsub.rabbitmq.Subscribers', (ctx:BuildContext) -> {
			var name = ctx.name;
			var type = ctx.type;
			var ct = type.toComplex();
			var tp = switch ct {
				case TPath(v): v;
				case _: throw 'assert';
			}
			
			var fields = getFields(ctx.type, ctx.pos);
			
			var def = macro class $name extends why.pubsub.rabbitmq.Subscribers.SubscribersBase implements $tp {}
			
			for(f in fields) {
				var ct = f.type.toComplex();
				var msgCt = f.messageType.toComplex();
				var name = f.name;
				var getter = 'get_$name';
				var config = switch f.meta.extract(':why.pubsub.rabbitmq') {
					case []: f.pos.error('Missing config via meta @:why.pubsub.rabbitmq');
					case [{params: [expr]}]: macro ($expr:why.pubsub.rabbitmq.Subscriber.SubscriberConfig<$msgCt>);
					case [{pos: pos}]: pos.error('@:why.pubsub.rabbitmq requires exactly one parameter');
					case _: f.pos.error('Only one @:why.pubsub.rabbitmq is allowed');
				}
				
				def.fields = def.fields.concat((macro class {
					public var $name(get, null):$ct;
					function $getter():$ct {
						if($i{name} == null)
							$i{name} = new why.pubsub.rabbitmq.Subscriber(manager, $config);
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
					case TInst(_.get() => {pack: ['why', 'pubsub'], name: 'Subscriber'}, [msg]):
						{
							name: f.name,
							pos: f.pos,
							meta: f.meta,
							type: f.type,
							messageType: msg,
						}
					case v:
						f.pos.error('Only why.pubsub.Subscriber<T> is supported here but got (${v.getID()})');
				}];
			case _:
				pos.error('Expected interface');
		}
	} 
}