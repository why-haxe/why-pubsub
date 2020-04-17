package why.pubsub.rabbitmq;

import tink.macro.BuildCache;

using tink.MacroApi;

class RabbitMq {
	public static function build() {
		return BuildCache.getType2('why.pubsub.rabbitmq.RabbitMq', ctx -> {
			var name = ctx.name;
			var pubType = ctx.type;
			var subType = ctx.type2;
			var pubCt = pubType.toComplex();
			var subCt = subType.toComplex();
			macro class $name {
				public final publishers:$pubCt;
				public final subscribers:$subCt;
				
				public function new(manager) {
					publishers = new why.pubsub.rabbitmq.Publishers<$pubCt>(manager);
					subscribers = new why.pubsub.rabbitmq.Subscribers<$subCt>(manager);
				}
			}
		});
	}
}