package why.pubsub.adapters;

import why.ble.*;
import tink.Chunk;
import tink.core.ext.Subscription;

using Lambda;
using tink.CoreApi;

/**
 * Bluetooth Low Energy (Central Role)
 */
class Ble implements why.pubsub.Adapter<Target> {
	
	var central:Central;
	
	public function new(central) {
		this.central = central;
	}
	
	public function publish(target:Target, payload:Chunk):Promise<Noise> {
		return getCharacteristic(target)
			.next(function(characteristic) return characteristic.write(payload, target.withoutResponse));
	}
	
	public function subscribe(target:Target, handler:Callback<Pair<Target, Chunk>>):Subscription {
		var error = Future.trigger(); // TODO: handle error
		var subscription:Subscription = null;
		
		getCharacteristic(target)
			.handle(function(o) switch o {
				case Success(characteristic):
					subscription = characteristic.subscribe(function(chunk) handler.invoke(new Pair(target, chunk)));
				case Failure(e):
					error.trigger(e);
			});
			
		return new SimpleSubscription(
			function() subscription.cancel(),
			subscription.error.first(error)
		);
	}
	
	function getCharacteristic(target:Target):Promise<Characteristic> {
		return central.peripherals.observe(target.id).nextTime(function(peripheral) return peripheral != null)
			.next(function(peripheral) {
				if(!peripheral.connected.value) peripheral.connect();
				return peripheral.connected.nextTime(function(v) return v)
					.next(function(_) return peripheral.discoverServices())
					.next(function(services) return switch services.find(function(s) return s.uuid == target.service) {
						case null: new Error('Cannot find service of UUID: ${target.service}');
						case service: service.discoverCharacteristics();
					})
					.next(function(characteristics) return switch characteristics.find(function(c) return c.uuid == target.characteristic) {
						case null: new Error('Cannot find characteristic of UUID: ${target.characteristic}');
						case characteristic: characteristic;
					});
			});
	}
	
	public static function parse(topic:String):Target {
		return switch topic.split('/') {
			case [id, service, characteristic]: makeTarget(id, service, characteristic);
			case [id, service, characteristic, 'true']: makeTarget(id, service, characteristic, true);
			case [id, service, characteristic, 'false']: makeTarget(id, service, characteristic, false);
			case _: throw 'Invalid topic format, expected: "<peripheral_id>/<service_uuid>/<characteristic_uuid>/[<write_without_response>]"';
		}
	}
	
	static inline function makeTarget(id, service, characteristic, ?withoutResponse):Target
		return {
			id: id,
			service: service,
			characteristic: characteristic,
			withoutResponse: withoutResponse,
		}
}

@:structInit
class Target {
	public var id(default, never):String;
	public var service(default, never):Uuid;
	public var characteristic(default, never):Uuid;
	@:optional public var withoutResponse(default, never):Bool;
}