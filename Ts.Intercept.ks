//Intercept Script, can be Used to Intercept another Vehicle
// or to set up an equidistant satellite network.

PARAMETER gTarget.
PARAMETER gSatNum IS 0. //the Number of the Satellite like in a row of 6 satellite, this is the 3
PARAMETER gSatTot IS 0. //total number of satellite to calculate angle separation.
PARAMETER gKSCSync IS FALSE. //set true to have this satellite sit above KSC

FUNCTION TARGET_ANGLE {
  PARAMETER target.
  RETURN MOD(LNG_TO_DEGREES(ORBITABLE(target):LONGITUDE),- LNG_TO_DEGREES(SHIP:LONGITUDE) + 360,360).
}

SET TVAL TO 0.
SET SVAL TO PROGRADE.
LOCK THROTTLE TO TVAL.
LOCK STEERING TO SVAL.
SET T2Node TO 0.

//Maneuver Planning

SET TARGET TO gTarget.

//TODO: Add Satellite Network Positioning, can just do Beta = (360/gSatTot)*gSatNum
//TODO: Add Satellite Virtual Position, to fine tune the orbit (Similar to Docking)

SET mode TO 1.
CLEARSCREEN.
SET tSpacer TO "              ".
UNTIL mode = 0 {
	IF mode = 1 {
		SET mode TO 2.
      LOCAL A1 IS BODY:RADIUS + (SHIP:ALTITUDE + TARGET:ALTITUDE)/2.
      LOCAL A2 IS TARGET:OBT:SEMIMAJORAXIS.
      LOCAL T1 IS T2 * (A1/A2)^1.5.
      LOCAL T2 IS TARGET:OBT:PERIOD.
      LOCAL alpha IS MOD(180*(T1/T2), 360).
      LOCAL transferAngle IS 360-alpha.
	}
	IF mode = 2 { // Warpo to Position
		SET TempTime TO T2Node-tT2B.
		IF (WARP = 0 AND TempTime > 50+tBTime) {SET WARP TO 3.}
		ELSE IF (WARP > 0 AND TempTime <= 50+tBTime) {SET WARP TO 0.}
		IF (TempTime  <= 30+tBTime) {
			IF (gCircPe) {
				SET mode TO 4.
				LOCK SVAL TO RETROGRADE.
			} ELSE {
				SET mode TO 3.
				LOCK SVAL TO PROGRADE.
			}
		}
	} ELSE IF mode = 3 { // Circularization at Apoapsis
		IF (SHIP:PERIAPSIS >= gOrbit) {
			SET TVAL TO 0.
			SET mode TO 20.
		} ELSE IF (TempTime  < 0 AND TVAL = 0) {
			SET TVAL TO 1.
		} ELSE IF (ETA:APOAPSIS > 100) {
			SET TVAL TO 0.
			SET mode TO 1.
		}
	} ELSE IF mode = 4 { // Circularization at Periapsis
		IF (SHIP:APOAPSIS >= gOrbit) {
			SET TVAL TO 0.
			SET mode TO 20.
		} ELSE IF (TempTime  < 0 AND TVAL = 0) {
			SET TVAL TO 1.
		} ELSE IF (ETA:PERIAPSIS > 100) {
			SET TVAL TO 0.
			SET mode TO 1.
		}
	} ELSE IF (mode = 20) { // SCRIPT END, RELEASE CONTROLS
		SET TVAL TO 0.
		unlock steering.
		unlock throttle.
		set mode to 0.
		print "Circularization Complete"+tSpacer AT (3,9).
		wait 5.
	}

	print "Scola-Sys - Circularization (RM:"+mode+") "+SHIP:STATUS+tSpacer AT (3,2).
	print "Target Orbit: "+ROUND(gOrbit/1000,0)+" km [Pe:"+gCircPe+"]"+tSpacer AT (3,3).
	print "ApH: " + ROUND(APOAPSIS/1000, 1) + " km"+tSpacer AT (3,4).
	print "PeH: " + ROUND(PERIAPSIS/1000, 1) + " km"+tSpacer AT (18,4).
	print "ApE: " + ROUND(ETA:APOAPSIS,0) + " s"+tSpacer AT (3,5).
	print "PeE: " + ROUND(ETA:PERIAPSIS,0) + " s"+tSpacer AT (18,5).
	print "DeV: " + ROUND(tDeltaV,1) + " m/s2"+tSpacer AT (3,7).
	print "BrE: " + -1*ROUND(T2Node-tT2B)+" s"+tSpacer AT (18,7).
}
