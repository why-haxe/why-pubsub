package why.pubsub.mqtt;

import haxe.macro.Type;
import tink.macro.BuildCache;

using tink.MacroApi;

class Mqtt {
	public static function build() {
		return BuildCache.getType('why.pubsub.mqtt.Mqtt', ctx -> {
			
			switch ctx.type.reduce() {
				case TInst(_.get() => {pack: ['why'], name: 'PubSub', isInterface: true}, [pub, sub]):
					var name = ctx.name;
					var pubCt = pub.toComplex();
					var subCt = sub.toComplex();
					macro class $name extends why.pubsub.mqtt.Mqtt.MqttBase implements why.PubSub<$pubCt, $subCt> {
						public final publishers:$pubCt;
						public final subscribers:$subCt;
						
						public function new(client) {
							super(client);
							publishers = new why.pubsub.mqtt.Publishers<$pubCt>(client);
							subscribers = new why.pubsub.mqtt.Subscribers<$subCt>(client);
						}
					}
					
				case v:
					ctx.pos.error('Expected why.PubSub but got ${v.getID()}');
			}
			
		});
	}
}