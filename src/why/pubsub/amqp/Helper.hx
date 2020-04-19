package why.pubsub.amqp;

import haxe.macro.Expr;
import haxe.macro.Type;

using tink.MacroApi;

class Helper {
	public static function getConfig(field:ClassField):Expr {
		return switch Macro.getMetaWithOneParam(field, ':pubsub.amqp') {
			case None:
				field.pos.error('Missing config via meta @:pubsub.amqp');
			case Some(expr):
				expr;
		}
	}
}
