package why.pubsub.rabbitmq;

import haxe.macro.Expr;
import haxe.macro.Type;

using tink.MacroApi;

class Helper {
	public static function getConfig(field:ClassField):Expr {
		return switch Macro.getMetaWithOneParam(field, ':pubsub.rabbitmq') {
			case None:
				field.pos.error('Missing config via meta @:pubsub.rabbitmq');
			case Some(expr):
				expr;
		}
	}
}
