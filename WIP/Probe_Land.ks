clearscreen.
PRINT "Scola-AutoGuide v0.1" at (3,2).


lock gShipPos to SHIP:GEOPOSITION.
lock gSurfEl to gShipPos:TERRAINHEIGHT.
lock gAltRad to max( 0.1, ALTITUDE - gSurfEl).
lock impactTime to betterALTRADAR / -VERTICALSPEED.
set GRAVITY to (constant():G * body:mass) / body:radius^2.
lock TWR to MAX( 0.001, MAXTHRUST / (MASS*GRAVITY)).
set gTgApo to 85000.

SAS off.
RCS on.
lights on.
SET TVAL TO 0.
lock throttle to TVAL.
gear off.
panels on.

WHEN MAXTHRUST = 0 THEN {
  LOCK THROTTLE to 0.
  PRINT "Staging".
  WAIT 1.
  STAGE.
  WAIT 1.
  LOCK THROTTLE to TVAL.
}.

PRINT "-> Waiting for Descent..." at (3,3).

WAIT UNTIL VERTICALSPEED < 0.

PRINT "-> Descent Initiated..." at (3,3).
LOCK STEERING to RETROGRADE.

set TVAL to 0.
set tDVMax to 200.
lock gLandAlt to MIN(ALT:RADAR,gAltRad).
UNTIL gLandAlt < 20000 {
  PRINT "-> Burn in " + ROUND((gAltRad-20000)/VERTICALSPEED,2) + " sec" at (3,3).	
}
clearscreen.
UNTIL Groundspeed < 1 {
	set tTWR to MAX(0,MIN(1,GROUNDSPEED)).
	set TVAL to tTWR.
	print "THROTTLE: " + TVAL at (7,3).
	print "ALTITUDE: " + round(gLandAlt) + " m." at (7,4).
	print "HSI: " + round(GROUNDSPEED) + " m/sec" at (7,5).
	print "VSI: " + round(VERTICALSPEED) + " m/sec" at (7,6).
}
set TVAL to 0.
WAIT UNTIL SHIP:ALTITUDE < 8000.
PRINT "Final Descend...".

clearscreen.
print "BRAKING BURN..." at (5,1).
UNTIL gLandAlt < 16 {
	if (gLandAlt > 50) {
		set tVSpd to (gLandAlt*0.10).
	} else {
		set tVSpd to 3.0.
	}
	set tDVNow to (VERTICALSPEED*-1)-tVSpd.
	set tTWRErr to tDVNow/tDVMax.
	set tTWR to (1/TWR)+tTWRErr*1.50.
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