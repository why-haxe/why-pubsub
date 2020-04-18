package why.pubsub.rabbitmq;

import haxe.macro.Expr;
import haxe.macro.Type;

using tink.MacroApi;

class Helper {
	public static function getConfig(field:ClassField):Expr {
		return switch Macro.getMetaWithOneParam(field, ':why.pubsub.rabbitmq') {
			case None:
				field.pos.error('Missing config via meta @:why.pubsub.rabbitmq');
			case Some(expr):
				expr;
		}
	}
}
