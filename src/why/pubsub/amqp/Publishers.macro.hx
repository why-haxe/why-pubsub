package why.pubsub.amqp;

import haxe.macro.Expr;
import haxe.macro.Type;
import tink.macro.BuildCache;

using tink.MacroApi;

class Publishers {
	public static function build() {
		return BuildCache.getType('why.pubsub.amqp.Publishers', (ctx:BuildContext) -> {
			var name = ctx.name;
			var tp = switch ctx.type.toComplex() {
				case TPath(v): v;
				case _: throw 'assert';
			}
			
			var def = macro class $name extends why.pubsub.amqp.Publishers.PublishersBase implements $tp {}
			
			var fields = Macro.getFields(ctx.type, Publisher, ctx.pos);
			Macro.populate(def, fields, Publisher, f -> {
				var msgCt = f.type.toComplex();
				var config = macro (tink.Anon.merge(${Helper.getConfig(f.field)}, ${Macro.getConfig(f.field)}):why.pubsub.amqp.Publisher.PublisherConfig<$msgCt>);
				macro new why.pubsub.amqp.Publisher(manager, $config);
			});
			
			def.pack = ['why', 'pubsub', 'amqp'];
			def;
		});
	}
}