import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Sensor;
import Toybox.System;
import Toybox.WatchUi;

class AndroidTimeView extends WatchUi.DataField{

	hidden var loc;
	hidden var fnt;
	
    hidden var backgroundColor;
    hidden var txtColor;
	
	hidden var tempUnit="C";
	hidden var is24hr;
	
	var width;
	var fontHeight;

    function initialize() {
        DataField.initialize();
		var settings = System.getDeviceSettings();
        if (settings.temperatureUnits == System.UNIT_STATUTE) {
        	tempUnit = "F";
        } else {
        	tempUnit = "C";
        } 
        is24hr = settings.is24Hour;
   		fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_MEDIUM, Graphics.FONT_TINY];
    }

    function onLayout(dc as Dc) as Void {
    	width = dc.getWidth();
		fontHeight = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);

    	getLOC();
	}

	function getLOC() as Void {

   		fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_MEDIUM, Graphics.FONT_TINY];

        switch (width) {
        	// Current time (x0,y1), Current Temperature (x2,y3), Battery Percentage (x4,y3)
        	// GPS states (x6, y7, width8, height9), Battery icon (x10, y11, width12, height13, cation14)
        	// GPS on/off Batt on/off am/pm 15, pm locY 16
        	// Time font 0, Temp/Batt font 1, am or pm font 2, 
        	
        	case 140: //Edge 1030, 1030 plus
				if ( fontHeight != 48 ) {
	        		loc = [70,38, 7,5, 118,0, 50,8,24,20, 122,10,10,18,2, 1,36];
       			} else { //Edge 1040, 1040 solar
       				loc = [70,38, 7,10, 118,0, 50,8,24,20, 122,10,10,18,2, 1,43];
				}
        		break;
        	case 282: //Edge 1030, 1030 plus
				if ( fontHeight != 48 ) {
    	    		loc = [140,38, 77,5, 188,0, 120,8,24,20, 192,10,10,18,2, 1,36];
				} else { //Edge 1040, 1040 solar
		       		loc = [140,38, 77,10, 188,0, 120,8,24,20, 192,10,10,18,2, 1,43];
				}
        		break;
        	case 119: //Edge 1000
				if ( fontHeight != 48 ) {
        			loc = [59,38, 5,5, 100,0, 42,8,20,16, 103,9,8,14,2, 1,37];
				} else { //Edge Explorer2
					loc = [59,28, 5,6, 100,0, 40,9,20,16, 105,11,8,14,2, 1,34];
				}
        		break;
        	case 240: //Edge 1000
				if ( fontHeight != 48 ) {
	        		loc = [120,38, 65,5, 160,0, 102,8,20,16, 163,9,8,14,2, 1,37];
				} else { //Edge Explorer2
					loc = [120,28, 65,6, 160,0, 100,9,20,16, 165,11,8,14,2, 1,34];
				}
        		break;
        	case 114: //Edge 130
        	case 115: //Edge 130 plus
       			loc = [57,28, 10,2, 105,0, 38,9,19,14, 102,11,8,12,1, 0,51];
       			break;
        	case 230: //Edge 130 plus
       			loc = [115,28, 68,2, 163,0, 96,9,19,14, 160,11,8,12,1, 0,51];
       			break;
        	case 99: //Edge 520, 520 plus
        		loc = [49,24, 4,2, 83,0, 35,4,16,12, 86,6,7,10,2, 1,24];
        		fnt = [Graphics.FONT_NUMBER_MILD, Graphics.FONT_SMALL, Graphics.FONT_XTINY];
        		break;
        	case 200: //Edge 520, 520 plus
        		loc = [100,24, 54,2, 133,0, 85,4,16,12, 136,6,7,10,2, 1,24];
	        	fnt = [Graphics.FONT_NUMBER_MILD, Graphics.FONT_SMALL, Graphics.FONT_XTINY];
        		break;
        	case 122: //Edge 530, 830
        		loc = [61,24, 6,4, 102,0, 43,6,20,16, 106,8,8,14,2, 1,27];
	        	fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_XTINY];
        		break;
        	case 246: //Edge 530, 830
        		loc = [123,24, 68,4, 164,0, 105,6,20,16, 168,8,8,14,2, 1,27];
	        	fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_XTINY];
        		break;
        	default :
        		loc = [70,38, 7,5, 118,0, 50,8,24,20, 122,10,10,18,2, 1,36];
        }
	}

	function clearDC(dc as Dc) as Void {
		backgroundColor = getBackgroundColor();
		txtColor = backgroundColor == Graphics.COLOR_BLACK ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;

        dc.setColor(txtColor, backgroundColor);
        dc.clear();
	}
		
    function onUpdate(dc as Dc) as Void {

		clearDC(dc);
		        
        var clockTime = System.getClockTime();
        dc.setColor(txtColor, Graphics.COLOR_TRANSPARENT);

        var text;
        if (is24hr) {
			text = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
			dc.drawText(loc[0], loc[1], fnt[0], text, Graphics.TEXT_JUSTIFY_CENTER);
		} else {
			text = Lang.format("$1$:$2$", [calc12Hr(clockTime.hour).format("%d"), clockTime.min.format("%02d")]);

			var aORp = (clockTime.hour < 12) ? loadResource(Rez.Strings.am) : loadResource(Rez.Strings.pm);
			if (loc[15]==0) { 
				aORp = (clockTime.hour < 12) ? "A" : "P"; 
			}
			var delta_x = dc.getTextWidthInPixels(aORp,fnt[2]);
			var clockSize = dc.getTextWidthInPixels(text,fnt[0]);
			dc.drawText(loc[0]-clockSize*0.5, loc[16], fnt[2], aORp, Graphics.TEXT_JUSTIFY_CENTER);
			dc.drawText(loc[0]+delta_x*0.5, loc[1], fnt[0], text, Graphics.TEXT_JUSTIFY_CENTER);
		}		
		        
		var temperature = Application.Storage.getValue("sensorTemp");
        if (temperature != null) {
        	if (tempUnit.equals("F")) {
        		temperature = (temperature * 1.8) + 32.0;
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
	
    function drawBattery(dc as Dc) as Void{
		var battery = System.getSystemStats().battery.toFloat();

		var x = loc[10];
		var y = loc[11];
		var width = loc[12];
		var height = loc[13];
		var cap = loc[14];
		var x2 = x + cap;
		var y2 = y - cap;
		var width2 = width - cap*2;
		
		dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    	dc.fillRectangle(x, y, width, height);
    	dc.fillRectangle(x2, y2, width2, cap);

		if (battery < 15) {
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		} else if(battery < 30) {
			dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
		} else if(battery == 100) {
			dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
			dc.fillRectangle(x2, y2, width2, cap);
    	} else {
			dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
		}
				
    	dc.fillRectangle(x, y + height.toFloat()*(1.0-battery/100.0), width, height.toFloat()*(battery/100.0));
    }
    
    function drawBatteryText(dc as Dc) as Void {
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

	function drawGps(dc as Dc) as Void {
		var antenna = getGpsState();
		dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
		
		var x = loc[6]; var y = loc[7]; var width = loc[8]; var height = loc[9];

		var xd = width / 5.0;
		var yh = height / 4.0;

		dc.fillRectangle(x,        y + height - yh,     xd-1, yh);
		dc.fillRectangle(x+xd,     y + height - yh*2.0, xd-1, yh*2.0);
		dc.fillRectangle(x+xd*2.0, y + height - yh*3.0, xd-1, yh*3.0);
		dc.fillRectangle(x+xd*3.0, y + height - yh*4.0, xd-1, yh*4.0);
		
		dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
		switch (antenna) {
			case 4 :
		dc.fillRectangle(x+xd*3.0, y + height - yh*4.0, xd-1, yh*4.0);
			case 3 :
		dc.fillRectangle(x+xd*2.0, y + height - yh*3.0, xd-1, yh*3.0);
			case 2 :
		dc.fillRectangle(x+xd,     y + height - yh*2.0, xd-1, yh*2.0);
			case 1 : 
		dc.fillRectangle(x,        y + height - yh,     xd-1, yh);
			default :				
    	}
	}
}
