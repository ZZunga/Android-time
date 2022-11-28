import Toybox.Application;
import Toybox.Background;
import Toybox.Time;

class AndroidTimeApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
    	if (System has :ServiceDelegate) {
    		// Read temperature sensor every 5 minutes
    		// Background event period cannot be less than 5 minutes
    		Background.registerForTemporalEvent(new Time.Duration(5 * 60)); 
   		} else {
   			System.println("****background not available on this device****");
   		}
        return [ new AndroidTimeView() ];
    }

    // value provided by the tempServiceDelegate
    function onBackgroundData(temperature) {
        if (temperature != null) {
            Storage.setValue("sensorTemp", temperature);
        }
	}
	
	function getServiceDelegate(){
		return [new tempServiceDelegate()];
	}
}