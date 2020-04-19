package why.pubsub.local;

import haxe.macro.Type;
import tink.macro.BuildCache;

using tink.MacroApi;

class Local {
	public static function build() {
		return BuildCache.getType('why.pubsub.local.Local', ctx -> {
			
			switch ctx.type.reduce() {
				case TInst(_.get() => {pack: ['why'], name: 'PubSub', isInterface: true}, [pub, sub]):
					var name = ctx.name;
					var pubCt = pub.toComplex();
					var subCt = sub.toComplex();
					macro class $name extends why.pubsub.local.Local.LocalBase implements why.PubSub<$pubCt, $subCt> {
						public final publishers:$pubCt;
						public final subscribers:$subCt;
						
						public function new() {
							super();
							publishers = new why.pubsub.local.Publishers<$pubCt>(this);
							subscribers = new why.pubsub.local.Subscribers<$subCt>(this);
						}
					}
					
				case v:
					ctx.pos.error('Expected why.PubSub but got ${v.getID()}');
			}
			
		});
	}
}