package why.pubsub.local;

import haxe.macro.Expr;
import haxe.macro.Type;

using tink.MacroApi;

class Helper {
	public static function getConfig(field:ClassField):Expr {
		return switch Macro.getMetaWithOneParam(field, ':pubsub.local') {
			case None:
				field.pos.error('Missing config via meta @:pubsub.local');
			case Some(expr):
				expr;
		}
	}
}
