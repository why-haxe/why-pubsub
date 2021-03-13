package why.pubsub.mqtt;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import tink.macro.BuildCache;

using tink.MacroApi;

class Subscribers {
	public static function build() {
		return BuildCache.getType('why.pubsub.mqtt.Subscribers', (ctx:BuildContext) -> {
			var name = ctx.name;
			var tp = switch ctx.type.toComplex() {
				case TPath(v): v;
				case _: throw 'assert';
			}
			
			var def = macro class $name extends why.pubsub.mqtt.Subscribers.SubscribersBase implements $tp {}
			
			var fields = Macro.getFields(ctx.type, Subscriber, ctx.pos);
			Macro.populate(def, fields, Subscriber, f -> {
				var msgCt = f.type.toComplex();
				var config = macro (tink.Anon.merge(${Helper.getConfig(f.field)}, ${Macro.getConfig(f.field)}):why.pubsub.mqtt.Subscriber.SubscriberConfig<$msgCt>);
				macro new why.pubsub.mqtt.Subscriber(client, $config);
			});
			
			def.pack = ['why', 'pubsub', 'mqtt'];
			def;
		});
	}
}