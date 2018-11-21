package why.pubsub;

interface Translator<Abstract, Concrete> {
	function abstractify(v:Concrete):Abstract;
	function concrete(v:Abstract):Concrete;
}

class SimpleTranslator<Abstract, Concrete> implements Translator<Abstract, Concrete> {
	
	var _abstractify:Concrete->Abstract;
	var _concrete:Abstract->Concrete;
	
	public function new(abstractify, concrete) {
		this._abstractify = abstractify;
		this._concrete = concrete;
	}
	
	public function abstractify(v:Concrete):Abstract
		return _abstractify(v);
		
	public function concrete(v:Abstract):Concrete
		return _concrete(v);
	
}

class DefaultTranslator<T> implements Translator<T, T> {
	public function new() {}
	public function abstractify(v:T):T return v;
	public function concrete(v:T):T return v;
}