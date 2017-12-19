clearscreen.
PRINT "Scola-AutoGuide v0.1" at (3,2).
PRINT "-> System Ready... IDLE" at (3,3).
WAIT UNTIL ALTITUDE > 71000.

PRINT "-> Decoupling" at (3,3).
wait 3.
PRINT "-> Orienting" at (3,3).
wait 1.
lock STEERING to HEADING(90,0).
wait 3.

set GRAVITY to (constant():G * body:mass) / body:radius^2.
lock TWR to MAX( 0.001, MAXTHRUST / (MASS*GRAVITY)).
set gTgOrbit to 75000.

WHEN MAXTHRUST = 0 THEN {
    LOCK THROTTLE to 0.
    PRINT "Staging".
    STAGE.
    LOCK THROTTLE to TVAL.
}.

SAS off.
RCS off.
lights on.
SET TVAL TO 0.
lock throttle to TVAL.
gear off.
panels on.
STAGE.
UNTIL ETA:APOAPSIS < 20 {
	PRINT "-> Waiting Apoapsis in " + ROUND(ETA:APOAPSIS,2) +" sec"at (3,3).
	PRINT "+ Burn in " + ROUND(ETA:APOAPSIS-20,2) +" sec"at (5,4).
}
UNTIL SHIP:PERIAPSIS > gTgOrbit {
	PRINT "-> Burning...                                         "at (3,3).
	PRINT "+ HGH-AP: " + (SHIP:APOAPSIS) +" m."at (5,4).
	PRINT "+ HGH-PE: " + (SHIP:PERIAPSIS) +" m."at (5,5).
	set tDApo to gTgOrbit-SHIP:PERIAPSIS.
	if (tDApo < 500) {
		set TVAL to MAX(0,MIN(1,tDApo/500)).
	} else {
		set TVAL to 1.
	}
}
set TVAL to 0.
CLEARSCREEN.
TOGGLE AG10.
PRINT "-> ORBITING...                                         "at (3,3).
