# Android-time

This data field displays the current time (12/24 hours), current temperature (C/F), GPS signal strength, and battery status (%). 

- The current time is displayed as a 12-hour clock and a 24-hour clock depending on the device settings or app settings.
- Temperature unit It is also displayed in Celsius temperature (C) and Fahrenheit temperature (F) units depending on the device settings or app settings.

- The current temperature is programmed to be updated every 5 minutes by a background task.
- GPS signal strength can be checked in 3D if there are 3~4 vertical lines, and 2 lines can be recognized in 2D. 
  In 1 square, only the last position is verified.
  To reduce errors in saving records, please check the GPS status before starting a ride recording.
- The battery icon is red when the capacity is less than 15%, yellow when it is less than 30%, and green otherwise.
- 
![image](https://user-images.githubusercontent.com/116134685/210191922-198f8aa5-1824-4ad6-bf39-c2437959e48d.png)
