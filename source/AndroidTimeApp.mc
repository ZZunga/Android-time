import Toybox.Application;
import Toybox.Background;
import Toybox.Time;

(:background)
class AndroidTimeApp extends Application.AppBase {

	var dataField;
	
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
    	dataField = new AndroidTimeView();
    	if (System has :ServiceDelegate) {
    		// 5분마다 센서 온도 읽기
    		// 백그라운드 작업은 5분보다 작을 수 없음.
    		Background.registerForTemporalEvent(new Time.Duration(5 * 60)); 
   		}
        return [ dataField ];
    }

    // tempServiceDelegate 권한대행를 통해서 온도값 저장
    function onBackgroundData(temperature) {
        if (temperature != null) {
            Storage.setValue("sensorTemp", temperature);
        }
	}
	
	function getServiceDelegate(){
		return [new tempServiceDelegate()];
	}

	// 세팅 변경되었으면 화면 업데이트
	function onSettingsChanged() {
		dataField.initVariables();
		dataField.getLOC();
	}
}
