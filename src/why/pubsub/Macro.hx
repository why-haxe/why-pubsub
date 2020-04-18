package why.pubsub;

import haxe.ds.Option;
import haxe.macro.Expr;
import haxe.macro.Type;

using tink.MacroApi;

class Macro {
	
	public static function getFields(type:Type, kind:PubSubKind, pos:Position):Array<Entry> {
		return switch type {
			case TInst(_.get() => {isInterface: true, fields: _.get() => fields}, _): 
				[for(f in fields) {
					if(!f.meta.has(':compilerGenerated')) {
						switch [f.kind, f.type] {
							case [FVar(AccCall, AccNever | AccNo), TInst(_.get() => {pack: ['why', 'pubsub'], name: name}, [msg])] if ((kind:String) == name):
								{
									field: f,
									type: msg,
									variant: Prop,
								}
							case [FMethod(_), TFun(args, TInst(_.get() => {pack: ['why', 'pubsub'], name: name}, [msg]))] if ((kind:String) == name):
								{
									field: f,
									type: msg,
									variant: Func(args),
								}
							case [FVar(AccCall, AccNever | AccNo), v] | [FMethod(_), TFun(_, v)]:
								f.pos.error('Only why.pubsub.$kind<T> is supported here but got (${v.getID()})');
							case _:
								f.pos.error('Only var(get, never/null) or function is supported here');
						}
					}
				}];
			case _:
				pos.error('Expected interface');
		}
	} 
	
	public static function getMetaWithOneParam(field:ClassField, name:String):Option<Expr> {
		return switch field.meta.extract(name) {
			case []:
				None;
			case [{params: [expr]}]:
				Some(expr);
			case [{pos: pos}]:
				pos.error('$name requires exactly one parameter');
			case _:
				field.pos.error('Only one $name is allowed');
		}
	}
	
	public static function populate(def:TypeDefinition, fields:Array<Entry>, kind:PubSubKind, getFactory:Entry->Expr) {
		for(f in fields) {
			var name = f.field.name;
			var msgCt = f.type.toComplex();
			var factory = getFactory(f);
			
			switch f.variant {
				case Prop:
					var ct = f.field.type.toComplex();
					var getter = 'get_$name';
					def.fields = def.fields.concat((macro class {
						public var $name(get, null):$ct;
						function $getter():$ct {
							if($i{name} == null)
								$i{name} = $factory;
							return $i{name};
						}
					}).fields);
					
				case Func(args):
					var ct = macro:why.pubsub.$kind<$msgCt>;
					
					var body = switch getMetaWithOneParam(f.field, ':why.pubsub.cache') {
						case Some(cache):
							var cacheName = '__cache_$name';
							def.fields.push({
								name: cacheName,
								access: [],
								kind: FVar(macro:why.pubsub.Cache<String, $ct>, macro new why.pubsub.Cache.StringCache()),
								pos: f.field.pos,
							});
							
							macro {
								var cache = $cache;
								var key = cache.key;
								$i{cacheName}.get(key, _ ->  $factory);
							}
						case None:
							factory;
					}
					var func = body.func(args.map(arg -> arg.name.toArg(arg.t.toComplex(), arg.opt)), ct);
					def.fields.push({
						name: name,
						access: [APublic],
						kind: FFun(func),
						pos: f.field.pos,
					});
			}
		}
	}
}

enum abstract PubSubKind(String) to String {
	var Publisher = 'Publisher';
	var Subscriber = 'Subscriber';
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