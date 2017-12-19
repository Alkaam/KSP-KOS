// Circularization Script
// If no Argument supplied will automatically circularize at Closest Apsis

PARAMETER gOrbit IS 0. //Orbit to Reach, DEFAULT IS 0km
PARAMETER gCircPe IS FALSE. //Circularize at Periapasis, if False Circularize at Apoapsis.

IF (gOrbit = "0") { //in case no argument supplied, select best option
	IF (SHIP:STATUS = "ESCAPING") {SET gOrbit TO SHIP:PERIAPSIS. SET gCircPe TO TRUE.}
	ELSE IF (ETA:PERIAPSIS < ETA:APOAPSIS) {SET gOrbit TO SHIP:PERIAPSIS. SET gCircPe TO TRUE.}
	ELSE IF (ETA:APOAPSIS < ETA:PERIAPSIS) {SET gOrbit TO SHIP:APOAPSIS. SET gCircPe TO FALSE.}
}
SET TVAL TO 0.
SET SVAL TO PROGRADE.
LOCK THROTTLE TO TVAL.
LOCK STEERING TO SVAL.
SET T2Node TO 0.
IF (gCircPe) { LOCK T2Node TO ETA:PERIAPSIS. }
ELSE { LOCK T2Node TO ETA:APOAPSIS. }
SET mode TO 1.
CLEARSCREEN.
SET tSpacer TO "              ".
UNTIL mode = 0 {
	IF mode = 1 {
		SET tDeltaV TO MAN_DV(gOrbit,gOrbit).
		SET tBTime TO MAN_BTime(MAN_ISP(),tDeltaV).
		SET tT2B TO tBTime*0.50.
		SET mode TO 2.
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

	//TODO: Add part when Trajectory is Escaping to perform Planet Capture
	print "Scola-Sys - Circularization (RM:"+mode+") "+SHIP:STATUS+tSpacer AT (3,2).
	print "Target Orbit: "+ROUND(gOrbit/1000,0)+" km [Pe:"+gCircPe+"]"+tSpacer AT (3,3).
	print "ApH: " + ROUND(APOAPSIS/1000, 1) + " km"+tSpacer AT (3,4).
	print "PeH: " + ROUND(PERIAPSIS/1000, 1) + " km"+tSpacer AT (18,4).
	print "ApE: " + ROUND(ETA:APOAPSIS,0) + " s"+tSpacer AT (3,5).
	print "PeE: " + ROUND(ETA:PERIAPSIS,0) + " s"+tSpacer AT (18,5).
	print "DeV: " + ROUND(tDeltaV,1) + " m/s2"+tSpacer AT (3,7).
	print "BrE: " + -1*ROUND(T2Node-tT2B)+" s"+tSpacer AT (18,7).
}
