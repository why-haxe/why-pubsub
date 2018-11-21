package why.pubsub.adapters;

import ble.*;
import tink.Chunk;

using Lambda;
using tink.CoreApi;

/**
 * Bluetooth Low Energy (Central Role)
 */
class Ble implements why.pubsub.Adapter {
	
	var central:Central;
	
	public function new(central) {
		this.central = central;
	}
	
	public function publish(topic:String, payload:Chunk):Promise<Noise> {
		return switch parse(topic) {
			case Success(target):
				getCharacteristic(target)
					.next(function(characteristic) return characteristic.write(payload, target.withoutResponse));
			case Failure(e): e;
		}
	}
	
	public function subscribe(topic:String, handler:Callback<Pair<String, Chunk>>):Promise<CallbackLink> {
		return switch parse(topic) {
			case Success(target):
				getCharacteristic(target)
					.next(function(characteristic) return characteristic.subscribe(function(chunk) handler.invoke(new Pair(topic, chunk))));
			case Failure(e): e;
		}
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
	
	function parse(topic:String):Outcome<Target, Error> {
		return switch topic.split('/') {
			case [id, service, characteristic]: Success(new Target(id, service, characteristic, false));
			case [id, service, characteristic, 'true']: Success(new Target(id, service, characteristic, true));
			case [id, service, characteristic, 'false']: Success(new Target(id, service, characteristic, false));
			case _: Failure(new Error('Invalid topic format, expected: "<peripheral_id>/<service_uuid>/<characteristic_uuid>/[<write_without_response>]"'));
		}
	}
}

@:forward
private abstract Target(TargetObject) {
	public inline function new(id, service, characteristic, withoutResponse)
		this = {
			id: id,
			service: service,
			characteristic: characteristic,
			withoutResponse: withoutResponse,
		}
}

private typedef TargetObject = {
	id:String,
	service:Uuid,
	characteristic:Uuid,
	withoutResponse:Bool,
}