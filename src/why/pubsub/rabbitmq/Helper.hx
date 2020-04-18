package why.pubsub.rabbitmq;

import haxe.macro.Expr;
import haxe.macro.Type;

using tink.MacroApi;

class Helper {
	
	public static function getFields(type:Type, name:String, pos:Position):Array<Entry> {
		return switch type {
			case TInst(_.get() => {isInterface: true, fields: _.get() => fields}, _): 
				[for(f in fields) {
					if(!f.meta.has(':compilerGenerated')) {
						switch [f.kind, f.type] {
							case [FVar(AccCall, AccNever | AccNo), TInst(_.get() => {pack: ['why', 'pubsub'], name: n}, [msg])] if (n == name):
								{
									field: f,
									type: msg,
									variant: Prop,
								}
							case [FMethod(_), TFun(args, TInst(_.get() => {pack: ['why', 'pubsub'], name: n}, [msg]))] if (n == name):
								{
									field: f,
									type: msg,
									variant: Func(args),
								}
							case [FVar(AccCall, AccNever | AccNo), v] | [FMethod(_), TFun(_, v)]:
								f.pos.error('Only why.pubsub.$name<T> is supported here but got (${v.getID()})');
							case _:
								f.pos.error('Only var(get, never/null) or function is supported here');
						}
					}
				}];
			case _:
				pos.error('Expected interface');
		}
	} 
}

typedef Entry = {
	field:ClassField,
	type:Type,
	variant:Variant,
}

enum Variant {
	Prop;
	Func(args:Array<{name:String, opt:Bool, t:Type}>);
}