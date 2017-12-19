SET gSwLaunch TO 0.
SET gG TO (CONSTANT():G * BODY:MASS) / BODY:RADIUS^2.
LOCK TWR TO MAX( 0.001, MAXTHRUST / (MASS*gG)).

SET gHDG TO 90.
SET gPTC TO 85.
SET TVAL TO 0.00.

LOCK STEERING TO HEADING(gHDG,gPTC).
LOCK THROTTLE TO TVAL.

ON AG10 {
	SET gSwLaunch TO 1.
}.

PRINT "SYSTEM READY".
PRINT "Press 0 to Launch".

SAS OFF.
RCS OFF.
lights on.
gear off.
panels off.

WAIT UNTIL gSwLaunch = 1.

STAGE.
CLEARSCREEN.
SET tSpd TO 0.
UNTIL ALT:RADAR > 70000 {
	SET tDelta TO VERTICALSPEED - tSpd.
	SET tSpd TO VERTICALSPEED.
	IF STAGE:SOLIDFUEL < 1 AND STAGE:NUMBER = 4 {
		IF (ALT:RADAR > 8000 OR tDelta < 0 OR VERTICALSPEED < 310) {
			PRINT "Staging".
			STAGE.
		}
	}
	IF (ALT:RADAR > 8000) {
		SET gPTC TO MAX( 5, 90 * (1 - ALT:RADAR / 50000)).
	}
	PRINT "Pitch: "+round(gPTC,2) at (7,4).
	PRINT "Fuel: "+round(STAGE:SOLIDFUEL,2)+" AT STAGE: "+STAGE:NUMBER at (7,5).
	PRINT "ETA-Ap: "+round(ETA:APOAPSIS,2) at (7,6).
	PRINT "HGH-Ap: "+round(SHIP:APOAPSIS,2) at (7,7).
	PRINT "THR-Pw: "+ROUND(TVAL,2) at (7,8).
	PRINT "SPD-Dt: "+ROUND(tDelta,2) at (7,9).
}
CLEARSCREEN.
SET gPTC TO 0.
UNTIL ETA:APOAPSIS < 1 {
	PRINT "Pitch: "+round(gPTC,2) at (7,4).
	PRINT "WAITING TO START DESCENT in "+round(ETA:APOAPSIS,2)+" sec" at (7,5).
}
CLEARSCREEN.
PRINT "DESCENT INITIATED...".
WAIT 2.
PRINT "RELEASING CLAMPSHELL".
STAGE.
WAIT 2.
PRINT "SEPARATION FROM ENGINE...".
STAGE.
WAIT 2.
PRINT "ORIENTING FOR DESCENT...".
LOCK STEERING TO VELOCITY:SURFACE * -1.
UNTIL ALT:RADAR / -VERTICALSPEED < 2 {
	PRINT "VSI: "+round(VERTICALSPEED,2) at (7,4).
	PRINT "TTI: "+round(ALT:RADAR / -VERTICALSPEED,2) at (7,5).
}
STAGE.