import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Sensor;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.WatchUi;

class AndroidTimeView extends WatchUi.DataField{

	hidden var loc as Array or Null;			// Edge 모델별 위치 설정
	hidden var fnt as Array or Null;			// Edge 모델별 폰트 설정
	
	hidden var tempUnit as String or Null;		// 온도 : C or F
	hidden var is24hr as Boolean or Null;		// 시간 : 12시간 or 24시간
	
	var width as Number or Null;				// 데이터필드 화면폭 크기(Half or Full 판정)
	var fontHeight as Number or Null;			// 1040, Edge Explorer 기기 판정용

	function initialize() {
		DataField.initialize();
		initVariables();
	}

	// 온도, 시간제 단위 변수 초기화
	function initVariables() {
		var settings = System.getDeviceSettings();
		var unitMetric = Application.Properties.getValue("unitMetric") as Number or Null;
		switch(unitMetric) {
		case 1:
			tempUnit = "C";
			break;
		case 2:
			tempUnit = "F";
			break;
		default:
			if (settings.temperatureUnits == System.UNIT_STATUTE) {
				tempUnit = "F";
			} else {
				tempUnit = "C";
			}
		} 
		var hr24 = Application.Properties.getValue("hr24");
		switch(hr24) {
		case 1:
			is24hr = false;
			break;
		case 2:
			is24hr = true;
			break;
		default:
			is24hr = settings.is24Hour;
		}
	}
	
	// 화면세팅. Edge 모델별 위치, 폰트 불러오기
	function onLayout(dc as Dc) as Void {
		width = dc.getWidth();
		fontHeight = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);
		getLOC();
	}

	function getLOC() as Void {

   		fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_MEDIUM, Graphics.FONT_TINY];

        switch (width) {
        	// 현재시간(x0,y1), 온도(x2,y3), 배터리(x4,y3)
        	// GPS 아이콘(x6,y7,width8,height9), 배터리 아이콘(x10,y11,width12,height13,양극크기14)
        	// loc[15]: 흑백, am/pm => a/p로 표시, loc[5]:am/pm y위치
        	// 시간폰트 0, 온도/배터리폰트 1, 오전/오후 2
        	case 140: //Edge 1030, 1030 plus
				if ( fontHeight != 48 ) {
	        		loc = [70,38, 7,5, 118,36, 48,8,24,20, 122,10,10,18,2, 1,36];
       			} else { //Edge 1040, 1040 solar
       				loc = [70,38, 7,10, 118,43, 48,8,24,20, 122,10,10,18,2, 1,43];
				}
        		break;
        	case 282: //Edge 1030, 1030 plus
				if ( fontHeight != 48 ) {
    	    		loc = [140,38, 77,5, 188,36, 118,8,24,20, 192,10,10,18,2, 1,36];
				} else { //Edge 1040, 1040 solar
		       		loc = [140,38, 77,10, 188,43, 118,8,24,20, 192,10,10,18,2, 1,43];
				}
        		break;
        	case 119: //Edge 1000
				if ( fontHeight != 48 ) {
        			loc = [59,38, 5,5, 98,37, 38,8,20,16, 103,9,8,14,2, 1,37];
				} else { //Edge Explorer2
					loc = [59,28, 5,6, 98,34, 38,9,20,16, 105,11,8,14,2, 1,34];
				}
        		break;
        	case 240: //Edge 1000
				if ( fontHeight != 48 ) {
	        		loc = [120,38, 65,5, 158,37, 98,8,20,16, 163,9,8,14,2, 1,37];
				} else { //Edge Explorer2
					loc = [120,28, 65,6, 158,34, 98,9,20,16, 165,11,8,14,2, 1,34];
				}
        		break;
        	case 114: //Edge 130
        	case 115: //Edge 130 plus
       			loc = [57,28, 5,2, 100,51, 46,10,16,16, 102,11,8,14,1, 0,51];
       			break;
        	case 230: //Edge 130 plus
       			loc = [115,28, 63,2, 158,51, 104,10,16,16, 160,11,8,14,1, 0,51];
       			break;
        	case 99: //Edge 520, 520 plus
        		loc = [49,24, 4,2, 83,24, 33,4,16,12, 86,6,7,10,2, 1,24];
        		fnt = [Graphics.FONT_NUMBER_MILD, Graphics.FONT_SMALL, Graphics.FONT_XTINY];
        		break;
        	case 200: //Edge 520, 520 plus
        		loc = [100,24, 54,2, 133,24, 83,4,16,12, 136,6,7,10,2, 1,24];
	        	fnt = [Graphics.FONT_NUMBER_MILD, Graphics.FONT_SMALL, Graphics.FONT_XTINY];
        		break;
        	case 122: //Edge 530, 830
        		loc = [61,24, 6,4, 100,27, 41,6,20,16, 106,8,8,14,2, 1,27];
	        	fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_XTINY];
        		break;
        	case 246: //Edge 530, 830
        		loc = [123,24, 68,4, 162,27, 103,6,20,16, 168,8,8,14,2, 1,27];
	        	fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_XTINY];
        		break;
        	default : //확인이 안될때는 1030 모델을 기본으로
        		loc = [70,38, 7,5, 118,36, 48,8,24,20, 122,10,10,18,2, 1,36];
        }
	}

	// 화면 표시
	function onUpdate(dc as Dc) as Void {
		// 배경화면색 판정. Black or White
		// onLayout에서 설정하면 주행중 화면 변화에 따라 변경되지 않음.
		var backgroundColor = getBackgroundColor();
		// 배경에 따른 글자, 배터리, GPS 색상 지정
		var txtColor;
		if (backgroundColor == Graphics.COLOR_BLACK) {
			txtColor = Graphics.COLOR_WHITE;
		} else {
			txtColor = Graphics.COLOR_BLACK;
		}
		var colors = {
            :background => backgroundColor,
            :color => txtColor
        };
		
		// 화면 초기화(지우기)
		dc.setColor(colors[:color], colors[:background]);
		dc.clear();

		// 현재시각 불러오기
		var clockTime = System.getClockTime();
		// 기본 색상 지정. -1은 투명 : Graphics.COLOR_TRANSPARENT와 동일.
		dc.setColor(colors[:color], -1);

		// String 변수
		var text;
		// 24시간제 일 경우
		if (is24hr) {
			text = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
			// 화면 중앙에 시계 표시
			dc.drawText(loc[0], loc[1], fnt[0], text, Graphics.TEXT_JUSTIFY_CENTER);
		// 12시간제 일 경우
		} else {
			text = Lang.format("$1$:$2$", [calc12hr(clockTime.hour).format("%d"), clockTime.min.format("%02d")]);
			// strings 에서 오전,오후 글자 불러오기
			var aORp = (clockTime.hour < 12) ? loadResource(Rez.Strings.am) : loadResource(Rez.Strings.pm);
			// 화면이 작으면 A나 P만 표시
			if (loc[15]==0) { 
				aORp = (clockTime.hour < 12) ? "A" : "P"; 
			}
			// am/pm 글자폭 재기
			var delta_x = dc.getTextWidthInPixels(aORp,fnt[2]);
			// 시계 글자폭 재기
			var clockSize = dc.getTextWidthInPixels(text,fnt[0]);
			// am/pm 포함하여 화면 중앙에 표시되도록 위치 지정
			// am/pm 표시
			dc.drawText(loc[0]-clockSize*0.5, loc[16], fnt[2], aORp, Graphics.TEXT_JUSTIFY_CENTER);
			// 시계 표시
			dc.drawText(loc[0]+delta_x*0.5, loc[1], fnt[0], text, Graphics.TEXT_JUSTIFY_CENTER);
		}		

		// sensor에서 온도를 불러와 데이터필드에 표시할 수 없음. 가민 데이터 저장소에 온도가 저장되어 있지 않기 때문이고
		// SDK에도 포함될 가능성이 희박함. 그러기 때문에 실시간 온도를 DF에 표시할 수는 없음.(워치페이스는 가능?)
		// 온도 불러오기 : 앱 시작시 백그라운드로 5분마다 측정되고 있음. 저장된 값 불러와서 단위에 맞게 수정.
		var temperature = Application.Storage.getValue("sensorTemp");
		if (temperature != null) {
			if (tempUnit.equals("F")) {
				temperature = (temperature * 1.8) + 32.0;
			}
			text = temperature.format("%d");
			// 온도 표시
			dc.drawText(loc[2], loc[3], fnt[1], text + tempUnit, Graphics.TEXT_JUSTIFY_LEFT);
		}		
		// 배터리 잔량 표시
		drawBatteryText(dc as Dc, colors);
		// 배터리 아이콘 표시
		drawBattery(dc as Dc, colors);
		// GPS 아이콘 표시
		drawGps(dc as Dc, colors);
	}

	// 시간을 입력받아 시간이 0이면 12, 12보다 크면 12를 빼서 12시간제로 반환
	function calc12hr(hour) as Number or Null{
		if (hour < 1) {	return hour + 12;}
		if (hour > 12) { return hour - 12; }
		return hour;
	}
	
	// 배터리 잔량 표시
	function drawBatteryText(dc as Dc, colors) as Void {
		var battery = System.getSystemStats().battery;	// Float 변수
		dc.setColor(colors[:color], -1);
		dc.drawText(loc[4], loc[3], fnt[1], battery.format("%d")+"%", Graphics.TEXT_JUSTIFY_RIGHT);
	}    

	// 배터리 아이콘 그리기
	function drawBattery(dc as Dc, colors) as Void{
		var greenColor, redColor, yellowColor, grayColor;
		// 배경이 흑색이면 밝은 컬러
		if (colors[:background] == Graphics.COLOR_BLACK) {
			greenColor = Graphics.COLOR_GREEN;
			redColor = Graphics.COLOR_RED;
			yellowColor = Graphics.COLOR_YELLOW;
			grayColor = Graphics.COLOR_DK_GRAY;
		// 배경이 흰색이면 어두운 컬러
		} else {
			greenColor = Graphics.COLOR_DK_GREEN;
			redColor = Graphics.COLOR_DK_RED;
			yellowColor = Graphics.COLOR_ORANGE;
			// 흑백 모델은 LT_GRAY 컬러가 안보임.
			grayColor = loc[15] == 1 ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY;
		}
		// 배터리 상태 가져오기
		var battery = System.getSystemStats().battery;	// Float 변수
		
		var x = loc[10];
		var y = loc[11].toFloat();
		var width = loc[12];
		var height = loc[13].toFloat();
		var cap = loc[14];
		var x2 = x + cap;
		var y2 = y - cap;
		var width2 = width - cap * 2;
		// 배터리 아이콘 외곽선 그리기
		dc.setColor(grayColor, -1);
    	dc.drawRectangle(x,y,width,height);
    	dc.drawRectangle(x2, y2, width2, cap);
		// 배터리 용량별 색상 지정		
		if (battery < 15) {
			dc.setColor(redColor, -1);
		} else if(battery < 30) {
			dc.setColor(yellowColor, -1);
		} else if(battery == 100) {
			dc.setColor(greenColor, -1);
			// 100% 일 때 전극 채우기 
			dc.fillRectangle(x2, y2, width2, cap);
    	} else {
			dc.setColor(greenColor, -1);
		}
		// 배터리 용량에 따라 색상 채우기
		// 계산 반올림 문제로 맨 아래 한픽셀이 가려지지 않는 문제가 있음
    	dc.fillRectangle(x, y + height*(1.0-battery/100.0), width, height*(battery/100.0));
    }
    
	// GPS 아이콘 그리기
	function drawGps(dc as Dc, colors) as Void {
		var yellowColor, grayColor;
		if (colors[:background] == Graphics.COLOR_BLACK) {
			yellowColor = Graphics.COLOR_YELLOW;
			grayColor = Graphics.COLOR_DK_GRAY;
		} else {
			yellowColor = Graphics.COLOR_ORANGE;
			grayColor = Graphics.COLOR_LT_GRAY;
		}
		// GPS 신호세기 가져오기
		var antenna = getGpsState();
		// GPS 아이콘 위치 변수 설정
		var x = loc[6]; var y = loc[7]; var width = loc[8]; var height = loc[9];
		var xd = width / 5.0;
		var yh = height / 4.0;
		// GPS 배경 그리기(그레이 색상)
		if (loc[15] == 1) {
			dc.setColor(grayColor, -1);
			dc.fillRectangle(x,      y + height - yh,   xd-1, yh);
			dc.fillRectangle(x+xd,   y + height - yh*2, xd-1, yh*2);
			dc.fillRectangle(x+xd*2, y + height - yh*3, xd-1, yh*3);
			dc.fillRectangle(x+xd*3, y + height - yh*4, xd-1, yh*4);
		}
		// GPS 색상 지정
		dc.setColor(yellowColor, -1);
		// 신호세기별 하나씩 그리기
		switch (antenna) {
			case 4 :
			dc.fillRectangle(x+xd*3, y + height - yh*4, xd-1, yh*4);
			case 3 :
			dc.fillRectangle(x+xd*2, y + height - yh*3, xd-1, yh*3);
			case 2 :
			dc.fillRectangle(x+xd,   y + height - yh*2, xd-1, yh*2);
			case 1 : 
			dc.fillRectangle(x,      y + height - yh,   xd-1, yh);
			default :				
		}
	}

	// GPS 신호 세기 가져오기
	// GPS 신호세기는 positionInfo의 정확도로 판정
    function getGpsState() as Number {
   		var positionInfo = Position.getInfo();
		if (positionInfo has :accuracy && positionInfo.accuracy != null) {
			return positionInfo.accuracy;
		}
		return 0;
    }
}