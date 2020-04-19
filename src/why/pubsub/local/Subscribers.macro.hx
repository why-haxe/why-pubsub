package why.pubsub.local;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import tink.macro.BuildCache;

using tink.MacroApi;

class Subscribers {
	public static function build() {
		return BuildCache.getType('why.pubsub.local.Subscribers', (ctx:BuildContext) -> {
			var name = ctx.name;
			var tp = switch ctx.type.toComplex() {
				case TPath(v): v;
				case _: throw 'assert';
			}
			
			var def = macro class $name extends why.pubsub.local.Subscribers.SubscribersBase implements $tp {}
			
			var fields = Macro.getFields(ctx.type, Subscriber, ctx.pos);
			Macro.populate(def, fields, Subscriber, f -> {
				var msgCt = f.type.toComplex();
				var config = macro (${Helper.getConfig(f.field)}:why.pubsub.local.Subscriber.SubscriberConfig<$msgCt>);
				macro new why.pubsub.local.Subscriber(local, $config);
			});
			
			def.pack = ['why', 'pubsub', 'local'];
			def;
		});
	}
}