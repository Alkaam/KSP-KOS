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
RCS off.
lights on.
gear on.
panels on.

SET TVAL TO 0.
SET SVAL TO UP.
SET FVAL To 1/TWR.

SET gSwLaunch TO 0.
SET gDist TO 2000.
SET gSpeed TO 58.
SET gHdg TO 0.
SET gMult TO 1.

ON AG1 {
  SET gSwLaunch to 1.
}.
ON AG2 {
  SET gSpeed to gSpeed-gMult.
  RETURN true.
}.
ON AG3 {
  SET gSpeed to gSpeed+gMult.
  RETURN true.
}.
ON AG4 {
  IF (gMult = 1) { SET gMult TO 2. }
  ELSE IF (gMult = 2) { SET gMult TO 5. }
  ELSE IF (gMult = 5) { SET gMult TO 10. }
  ELSE IF (gMult = 10) { SET gMult TO 1. }
  RETURN true.
}.

WHEN MAXTHRUST = 0 THEN {
  LOCK THROTTLE to 0.
  PRINT "Staging".
  WAIT 1.
  STAGE.
  WAIT 1.
  LOCK THROTTLE to TVAL.
}.

UNTIL gSwLaunch = 1 {
  SET Phi TO 0.50 * ARCSIN((GRAVITY*gDist)/gSpeed^2).
  PRINT "Dist:  " + ROUND(gDist) + " m." at (3,3).
  PRINT "Speed: " + ROUND(gSpeed) + " m/s" at (3,4).
  PRINT "Phi:   " + ROUND(Phi,2) + " deg" at (3,5).
  PRINT "Mult:  " + gMult + "  " at (3,7).
}

lock throttle to TVAL.
lock steering to SVAL.

SET TVAL TO 1.55/TWR.
WAIT UNTIL gAltRad > 10.
SET SVAL TO HEADING(gHdg,Phi).
WAIT 2.
SET TVAL TO 1.
WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG > gSpeed.
SET TVAL TO 0.
WAIT UNTIL ETA:APOAPSIS < 1.
SET SVAL to velocity:surface * -1.
lock steering to SVAL.
WAIT UNTIL VERTICALSPEED < 0 and gAltRad < 100.
lock gLandAlt to MIN(ALT:RADAR,gAltRad).

CLEARSCREEN.
UNTIL VERTICALSPEED > -1 and gLandAlt < 5 {

	SET tSrfSpd TO VELOCITY:SURFACE.
	SET tLft TO tSrfSpd * FACING:STARVECTOR.
	SET tFwd TO tSrfSpd * FACING:UPVECTOR.

	set tPitch to 10*(tFwd/10).
	set tYaw To 10*(tLft/-10).

	if (gLandAlt > 50) {
		set tVSpd to gLandAlt.
		SET SVAL to velocity:surface * -1.
	} else if (gLandAlt > 30 and gLandAlt < 50) {
		set tVSpd to (gLandAlt*0.10).
	        SET SVAL TO UP + R(tPitch,tYaw,0).
	} else {
		set tVSpd to 2.0.
	        SET SVAL TO UP + R(tPitch,tYaw,0).
	}

	set tDVNow to (VERTICALSPEED*-1)-tVSpd.
	set tTWRErr to tDVNow/20.
	set tTWR to (1/TWR)+tTWRErr*1.50.
	set TVAL to MAX(0,MIN(1,tTWR)).

	print "TSPD: " + round(tVSpd,2) + "     " at (7,2).
	print "THR:  " + ROUND(TVAL,4) at (7,3).
	print "ALT: " + round(gLandAlt) + " m." at (7,4).
	print "VSI: " + round(VERTICALSPEED) + " m/sec" at (7,5).
	print "PTC: " + ROUND(tPitch,2) + " m/sec ["+ROUND(upways,2)+"]     " at (7,6).
	print "YAW: " + ROUND(tYaw,2) + " m/sec ["+ROUND(sideways,2)+"]     " at (7,7).
}
SET TVAL to 1/TWR.
WAIT VERTICALSPEED < 1.
SET TVAL to 0.