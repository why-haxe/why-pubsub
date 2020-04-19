package why.pubsub.amqp;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import tink.macro.BuildCache;

using tink.MacroApi;

class Subscribers {
	public static function build() {
		return BuildCache.getType('why.pubsub.amqp.Subscribers', (ctx:BuildContext) -> {
			var name = ctx.name;
			var tp = switch ctx.type.toComplex() {
				case TPath(v): v;
				case _: throw 'assert';
			}
			
			var def = macro class $name extends why.pubsub.amqp.Subscribers.SubscribersBase implements $tp {}
			
			var fields = Macro.getFields(ctx.type, Subscriber, ctx.pos);
			Macro.populate(def, fields, Subscriber, f -> {
				var msgCt = f.type.toComplex();
				var config = macro (tink.Anon.merge(${Helper.getConfig(f.field)}, ${Macro.getConfig(f.field)}):why.pubsub.amqp.Subscriber.SubscriberConfig<$msgCt>);
				macro new why.pubsub.amqp.Subscriber(manager, $config);
			});
			
			def.pack = ['why', 'pubsub', 'amqp'];
			def;
		});
	}
}