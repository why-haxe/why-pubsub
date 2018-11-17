package ;

class RunTests {

  static function main() {
    pubsub.PubSub;
    pubsub.mqtt.Mqtt;
    
    travix.Logger.println('it works');
    travix.Logger.exit(0); // make sure we exit properly, which is necessary on some targets, e.g. flash & (phantom)js
  }
  
}