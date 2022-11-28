import Toybox.Position;
import Toybox.Sensor;
import Toybox.WatchUi;

class AndroidTimeView extends WatchUi.DataField {

	hidden var loc;
	hidden var fnt;
	
    hidden var bgColorOpt;
    hidden var backgroundColor;
    hidden var txtColor;
	
	hidden var tempUnit="C";
	hidden var is24hr;

	var i;

    function initialize() {
        DataField.initialize();
		var settings = System.getDeviceSettings();
        if (settings.temperatureUnits == System.UNIT_STATUTE) {
        	tempUnit = "F";
        } else {
        	tempUnit = "C";
        } 
        is24hr = settings.is24Hour;
        i = 0;
   		fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_MEDIUM, Graphics.FONT_TINY];
    }

    function onLayout(dc as Dc) as Void {
		backgroundColor = getBackgroundColor();
		txtColor = backgroundColor == Graphics.COLOR_BLACK ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;

    	var width = dc.getWidth();
		var fontHeight = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);

        switch (width) {
        	// Current time (x0,y1), Current Temperature (x2,y3), Battery Percentage (x4,y3)
        	// GPS states (x6, y7, width8, height9), Battery icon (x10, y11, width12, height13, cation14)
        	// GPS on/off Batt on/off am/pm 15, pm locY 16
        	// Time font 0, Temp/Batt font 1, am or pm font 2, 
        	
        	// diet  3=5, 

        	case 140: //Edge 1030, 1030 plus
				if ( fontHeight != 48 ) {
	        		loc = [70,38, 7,5, 118,0, 50,8,24,20, 122,10,10,18,2, 1,36];
       			} else { //Edge 1040, 1040 solar
       				loc = [70,40, 7,10, 118,0, 50,8,24,20, 122,10,10,18,2, 1,45];
				}
        		break;
        	case 282: //Edge 1030, 1030 plus
				if ( fontHeight != 48 ) {
    	    		loc = [140,38, 77,5, 188,0, 120,8,24,20, 192,10,10,18,2, 1,36];
				} else { //Edge 1040, 1040 solar
		       		loc = [140,40, 77,10, 188,0, 120,8,24,20, 192,10,10,18,2, 1,45];
				}
        		break;
        	case 119: //Edge 1000
				if ( fontHeight != 48 ) {
        			loc = [59,34, 5,5, 100,0, 42,7,20,16, 103,8,8,14,2, 1,33];
				} else { //Edge Explorer2
					loc = [59,30, 5,6, 100,0, 42,7,20,16, 103,8,8,14,2, 1,36];
				}
        		break;
        	case 240: //Edge 1000
				if ( fontHeight != 48 ) {
	        		loc = [120,34, 65,5, 160,0, 102,7,20,16, 163,8,8,14,2, 1,33];
				} else { //Edge Explorer2
					loc = [120,30, 65,6, 160,0, 102,7,20,16, 163,8,8,14,2, 1,36];
				}
        		break;
        	case 114: //Edge 130
        	case 115: //Edge 130 plus
       			loc = [57,25, 10,2, 105,0, 40,9,19,14, 99,11,8,12,1, 0,47];
       			break;
        	case 230: //Edge 130 plus
       			loc = [115,25, 68,2, 163,0, 98,9,19,14, 157,11,8,12,1, 0,47];
       			break;
        	case 99: //Edge 520, 520 plus
        		loc = [49,23, 4,2, 83,0, 35,5,16,12, 86,7,7,10,2, 1,23];
	        		fnt = [Graphics.FONT_NUMBER_MILD, Graphics.FONT_SMALL, Graphics.FONT_XTINY];
        		break;
        	case 200: //Edge 520, 520 plus
        		loc = [100,23, 54,2, 133,0, 85,5,16,12, 136,7,7,10,2, 1,23];
	        		fnt = [Graphics.FONT_NUMBER_MILD, Graphics.FONT_SMALL, Graphics.FONT_XTINY];
        		break;
        	case 122: //Edge 530, 830
        		loc = [61,26, 6,4, 102,0, 43,6,20,16, 106,8,8,14,2, 1,29];
	        		fnt = [Graphics.FONT_NUMBER_MILD, Graphics.FONT_SMALL, Graphics.FONT_XTINY];
        		break;
        	case 246: //Edge 530, 830
        		loc = [123,26, 68,4, 164,0, 105,6,20,16, 168,8,8,14,2, 1,29];
	        		fnt = [Graphics.FONT_NUMBER_MILD, Graphics.FONT_SMALL, Graphics.FONT_XTINY];
        		break;
        	default :
        		loc = [70,38, 7,5, 118,0, 50,8,24,20, 122,10,10,18,2, 1,36];
        }
/*        
		// check variables
		var height = dc.getHeight();
		if (i < 5) { 
			System.println(width + ", " + height);
			System.println(txtColor);
			System.println(curTextSize[0] + ", " + curTextSize[1]);  //fontsize 
		}
		i++;
*/
	}

    function onUpdate(dc as Dc) as Void {

		backgroundColor = getBackgroundColor();
		txtColor = backgroundColor == Graphics.COLOR_BLACK ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;

        dc.setColor(txtColor, backgroundColor);
        dc.clear();
        
        var clockTime = System.getClockTime();
        var text;

        dc.setColor(txtColor, Graphics.COLOR_TRANSPARENT);
		//clockTime.hour = 0;
		//clockTime.min = 55;
        if (is24hr) {
			text = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
			dc.drawText(loc[0], loc[1], fnt[0], text, Graphics.TEXT_JUSTIFY_CENTER);
		} else {
			text = Lang.format("$1$:$2$", [calc12Hr(clockTime.hour), clockTime.min.format("%02d")]);
			var aORp = (clockTime.hour < 12) ? loadResource(Rez.Strings.am) : loadResource(Rez.Strings.pm);
			if (loc[15]==0) { 
				aORp = (clockTime.hour < 12) ? "A" : "P"; 
			}
			var delta_x = dc.getTextDimensions(aORp,fnt[2]);
			var clockSize = dc.getTextDimensions(text, fnt[0]);
			dc.drawText(loc[0]-clockSize[0]*0.5, loc[16], fnt[2], aORp, Graphics.TEXT_JUSTIFY_CENTER);
			dc.drawText(loc[0]+delta_x[0]*0.5, loc[1], fnt[0], text, Graphics.TEXT_JUSTIFY_CENTER);
		}		
		        
		var temperature = Application.Storage.getValue("sensorTemp");
        if (temperature != null) {
        	if (tempUnit.equals("F")) {
        		temperature = (temperature * 1.8) + 32;
        	}
        	text = temperature.format("%d");
        	dc.drawText(loc[2], loc[3], fnt[1], text + tempUnit, Graphics.TEXT_JUSTIFY_LEFT);
		}		

		drawBatteryText(dc);

		if (loc[15]==1) { drawGps(dc); }
		if (loc[15]==1) { drawBattery(dc); }
    }

	function calc12Hr(hour) {
		if (hour < 1) {	return hour + 12;}
		if (hour > 12) { return hour - 12; }
		return hour;
	}
	
    function drawBattery(dc) {
		var battery = System.getSystemStats().battery;

		dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    	dc.fillRectangle(loc[10] + loc[14], loc[11] - loc[14], loc[12] - loc[14] * 2, loc[14]);
    	dc.fillRectangle(loc[10], loc[11], loc[12], loc[13]);

		if (battery < 15) {
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		} else if(battery < 30) {
			dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
		} else if(battery == 100) {
			dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
			dc.fillRectangle(loc[10] + loc[14], loc[11] - loc[12] / 4, loc[12] - loc[14] * 2, loc[14]);
    	} else {
			dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
		}
				
    	dc.fillRectangle(loc[10], loc[11] + loc[13]*(1-battery/100)+0.5, loc[12], loc[13]*(battery/100)+0.5);
    }
    
    function drawBatteryText(dc) {
		var battery = System.getSystemStats().battery;
    	dc.setColor(txtColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText(loc[4], loc[3], fnt[1], battery.format("%d")+"%", Graphics.TEXT_JUSTIFY_RIGHT);
	}    
    
    function getGpsState() {
   		var positionInfo = Position.getInfo();
		if (positionInfo has :accuracy && positionInfo.accuracy != null) {
			return positionInfo.accuracy;
		}
		return 0;
    }

	function drawGps(dc) {
		var antenna = getGpsState();
		dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
		
		var x = loc[6]; var y = loc[7]; var width = loc[8]; var height = loc[9];
		var xd = width / 5 - 1;
		var yh = height / 4;

		dc.fillRectangle(x, y + height - yh, xd, yh);
		dc.fillRectangle(x+xd+1, y + height - yh*2, xd, yh*2);
		dc.fillRectangle(x+(xd+1)*2, y + height - yh*3, xd, yh*3);
		dc.fillRectangle(x+(xd+1)*3, y + height - yh*4, xd, yh*4);
		
		dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
		switch (antenna) {
			case 4 :
		dc.fillRectangle(x+(xd+1)*3, y + height - yh*4, xd, yh*4);
			case 3 :
		dc.fillRectangle(x+(xd+1)*2, y + height - yh*3, xd, yh*3);
			case 2 :
		dc.fillRectangle(x+xd+1, y + height - yh*2, xd, yh*2);
			case 1 : 
		dc.fillRectangle(x, y + height - yh, xd, yh);
			default :				
    	}
	}
}
