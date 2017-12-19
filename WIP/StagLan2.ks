clearscreen.
PRINT "System Standby...".


lock shipLatLng to SHIP:GEOPOSITION.
lock surfaceElevation to shipLatLng:TERRAINHEIGHT.
lock betterALTRADAR to max( 0.1, ALTITUDE - surfaceElevation).
lock impactTime to betterALTRADAR / -VERTICALSPEED.
set GRAVITY to (constant():G * body:mass) / body:radius^2.
lock TWR to MAX( 0.001, MAXTHRUST / (MASS*GRAVITY)).

WAIT UNTIL SHIP:ALTITUDE > 65000.
SAS off.
RCS on.
lights on.
SET TVAL TO 0.
lock throttle to TVAL.
gear off.
panels on.

PRINT "System Idle, Waiting for Descent...".
UNTIL VERTICALSPEED < 0 {
	if (ETA:APOAPSIS < 40) {
		lock STEERING to UP.
	} else {
		lock STEERING to PROGRADE.
	}
}
PRINT "Descent Initiated...".
LOCK STEERING to RETROGRADE.
WAIT UNTIL SHIP:ALTITUDE < 50000.
PRINT "Starting First Braking Burn...".
SET TVAL TO 0.50.

WAIT UNTIL VERTICALSPEED > -650.
PRINT "Burn Complete...".
SET TVAL TO 0.

WAIT UNTIL SHIP:ALTITUDE < 45000.
PRINT "Starting Aerobraking...".
brakes on.

WAIT UNTIL SHIP:ALTITUDE < 25000.
PRINT "Starting Second Braking Burn...".
SET TVAL TO 0.50.

WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < 1000.
PRINT "Burn Complete...".
SET TVAL TO 0.

WAIT UNTIL SHIP:ALTITUDE < 5500.
PRINT "Starting Third Braking Burn...".
SET TVAL TO 0.70.

WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < 600.
PRINT "Burn Complete...".
SET TVAL TO 0.

WAIT UNTIL SHIP:ALTITUDE < 5000.
PRINT "Final Descend...".

set TVAL to 1.
set tDVMax to 200.
clearscreen.
print "BRAKING BURN..." at (5,1).
lock gLandAlt to MIN(ALT:RADAR,betterALTRADAR).
lock STEERING to UP.
UNTIL gLandAlt < 16 {
	if (gLandAlt > 100) {
		set tVSpd to (gLandAlt*0.10).
	} else {
		set tVSpd to 2.0.
	}
	set tDVNow to (VERTICALSPEED*-1)-tVSpd.
	set tTWRErr to tDVNow/tDVMax.
	set tTWR to (1/TWR)+tTWRErr.
	set TVAL to MAX(0,MIN(1,tTWR)).
	print "Target Speed: " + round(tVSpd) + "     " at (7,2).
	print "THROTTLE: " + TVAL at (7,3).
	print "ALTITUDE: " + round(gLandAlt) + " m." at (7,4).
	print "VSI: " + round(VERTICALSPEED) + " m/sec" at (7,5).
}
clearscreen.
PRINT "Descent Complete...OK".
PRINT "Hovering 3 sec...".
wait 3.
set TVAL to 0.
lock throttle to 0.