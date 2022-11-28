import Toybox.Background;
import Toybox.Sensor;
import Toybox.System;

(:background)
class tempServiceDelegate extends System.ServiceDelegate {

	function initialize() {
		ServiceDelegate.initialize();
	}

	function onTemporalEvent() {
		var senInfo = Sensor.getInfo();
		if (senInfo has :temperature && senInfo.temperature != null) {
			Background.exit(senInfo.temperature);
		} else {
			Background.exit(null);
		} 
	}
}