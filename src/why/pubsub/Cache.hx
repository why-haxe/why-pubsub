package why.pubsub;

interface Cache<K, V> {
	function get(k:K, factory:K->V):V;
}

typedef CacheConfig<K> = {
	final key:K;
}

class StringCache<V> implements Cache<String, V> {
	final map = new Map<String, V>();
	
	public function new() {}
	
	public function get(k:String, factory:String->V):V {
		if(!map.exists(k)) map.set(k, factory(k));
		return map.get(k);
	}
}