package why.pubsub.mqtt;

import haxe.macro.Expr;
import haxe.macro.Type;

using tink.MacroApi;

class Helper {
	public static function getConfig(field:ClassField):Expr {
		return switch Macro.getMetaWithOneParam(field, ':pubsub.mqtt') {
			case None:
				field.pos.error('Missing config via meta @:pubsub.mqtt');
			case Some(expr):
				expr;
		}
	}
}
