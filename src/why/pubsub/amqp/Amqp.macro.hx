package why.pubsub.amqp;

import haxe.macro.Type;
import tink.macro.BuildCache;

using tink.MacroApi;

class Amqp {
	public static function build() {
		return BuildCache.getType('why.pubsub.amqp.Amqp', ctx -> {
			
			switch ctx.type.reduce() {
				case TInst(_.get() => {pack: ['why'], name: 'PubSub', isInterface: true}, [pub, sub]):
					var name = ctx.name;
					var pubCt = pub.toComplex();
					var subCt = sub.toComplex();
					macro class $name extends why.pubsub.amqp.Amqp.AmqpBase implements why.PubSub<$pubCt, $subCt> {
						public final publishers:$pubCt;
						public final subscribers:$subCt;
						
						public function new(manager) {
							super(manager);
							publishers = new why.pubsub.amqp.Publishers<$pubCt>(manager);
							subscribers = new why.pubsub.amqp.Subscribers<$subCt>(manager);
						}
					}
					
				case v:
					ctx.pos.error('Expected why.PubSub but got ${v.getID()}');
			}
			
		});
	}
}