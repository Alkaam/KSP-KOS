clearscreen.
set gSwOrbit to 1.
set gSwLaunchOnly to 1.

PRINT "Scola-AutoGuide v0.1" at (3,2).

Lock gShipPos to SHIP:GEOPOSITION.
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
panels off.

PRINT "-> Throttle UP!      " at (3,3).
set TVAL to 1.
WAIT 2.
stage.
PRINT "-> Ascent Initiated...      " at (3,3).
WAIT 0.50.
lock STEERING to PROGRADE.

WHEN MAXTHRUST = 0 THEN {
    LOCK THROTTLE to 0.
    PRINT "Staging".
    STAGE.
    LOCK THROTTLE to TVAL.
}.

UNTIL gAltRad > 60000 {
	set tDApo to gTgApo-SHIP:APOAPSIS.
	set targetPitch to max( 5, 90 * (1 - ALT:RADAR / 50000)).
	PRINT "Pitch: "+round(targetPitch) at (7,4).
	PRINT "Fuel: "+round(stage:Liquidfuel) at (7,5).
	PRINT "ETA-Ap: "+round(ETA:APOAPSIS) at (7,6).
	PRINT "HGH-Ap: "+round(SHIP:APOAPSIS) at (7,7).
	PRINT "THR-Pw: "+TVAL at (7,8).
	if (SHIP:APOAPSIS < gTgApo and ABS(tDApo) < 50) {
		set TVAL to MIN(1,(1+tDApo/TWR)).
	} else if (SHIP:APOAPSIS < gTgApo and ABS(tDApo) > 50 and ALTITUDE > 300) {
		set TVAL to MIN(1,2.5/TWR).
		
	} else if (SHIP:APOAPSIS > gTgApo) {
		set TVAL to 0.
		PRINT "-> Waiting to Exit Atmosphere..." at (3,3).
	} else {
		set TVAL to 1.
	}
	lock steering to heading ( 90, targetPitch). 
}
set TVAL to 0.

WAIT UNTIL SHIP:ALTITUDE > 70000.
panels on.
		PRINT "-> Switch to Orbit Guidance Payload..." at (3,3).
		WAIT 1.
		RUNPATH("LowOrbitSat.ks").
