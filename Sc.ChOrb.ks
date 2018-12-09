// Circularization Script
// If no Argument supplied will automatically circularize at Closest Apsis

PARAMETER gOrbit IS 200000.

RCS ON.
SET TVAL TO 0.
SET SVAL TO PROGRADE.
LOCK THROTTLE TO TVAL.
LOCK STEERING TO SVAL.
SET T2Node TO 0.
LOCK T2Node TO ETA:APOAPSIS.
SET mode TO 1.
CLEARSCREEN.
SET tSpacer TO "              ".
  SET tDeltaV TO MAN_DV(gOrbit,gOrbit).
  SET tBTime TO MAN_BTime(MAN_ISP(),ABS(tDeltaV)).
  SET tT2B TO tBTime*0.50.
    IF tDeltaV < 0 { LOCK SVAL TO RETROGRADE. LOCK TgApsis TO SHIP:PERIAPSIS.}
    ELSE { LOCK SVAL TO PROGRADE. LOCK TgApsis TO SHIP:APOAPSIS.}
UNTIL mode = 0 {
	IF mode = 1 {  // Warpo to Position
		LOCK TempTime TO T2Node-tT2B.
		IF (WARP = 0 AND TempTime > 50+tBTime) {SET WARP TO 3.}
		ELSE IF (WARP > 0 AND TempTime <= 50+tBTime) {SET WARP TO 0.}
		IF (TempTime  <= 30+tBTime) {
			SET WARP TO 0.
			SET mode TO 2.
		}
	}
	IF mode = 2 {
		IF (TVAL = 0 AND TempTime <= 0) {SET TVAL TO 1.}
		ELSE IF (TVAL > 0) {
		  IF (tDeltaV < 0) {
		    IF (TgApsis >= gOrbit*0.98) {
		      SET TVAL TO MAX(0.01,1-(TgApsis/gOrbit)).
		    } ELSE IF (TgApsis >= gOrbit) {
		      SET TVAL TO 0.
		      SET mode TO 3.
		    } ELSE {
			SET TVAL TO 1.
		    }
		  } ELSE {
		    IF (TgApsis <= gOrbit*1.02) {
		      SET TVAL TO MAX(0.01,(TgApsis-gOrbit)/gOrbit).
		    } ELSE IF (TgApsis <= gOrbit) {
		      SET TVAL TO 0.
		      SET mode TO 3.
		    } ELSE {
			SET TVAL TO 1.
		    }
		  }
		}
	} ELSE IF mode = 3 { // Circularization at Apoapsis
		IF (SHIP:PERIAPSIS >= gOrbit) {
			SET TVAL TO 0.
			SET mode TO 20.
		} ELSE IF (TempTime <= 0 AND TVAL = 0) {
			SET TVAL TO 1.
		} ELSE IF (ETA:APOAPSIS > 100 AND ETA:APOAPSIS < SHIP:OBT:PERIOD - 100) {
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
	print "Scola-Sys - Change Orbit (RM:"+mode+") "+SHIP:STATUS+tSpacer AT (3,2).
	print "Target Orbit: "+ROUND(gOrbit/1000,0)+" km"+tSpacer AT (3,3).
	print "ApH: " + ROUND(APOAPSIS/1000, 1) + " km"+tSpacer AT (3,4).
	print "PeH: " + ROUND(PERIAPSIS/1000, 1) + " km"+tSpacer AT (18,4).
	print "ApE: " + ROUND(ETA:APOAPSIS,0) + " s"+tSpacer AT (3,5).
	print "PeE: " + ROUND(ETA:PERIAPSIS,0) + " s"+tSpacer AT (18,5).
	print "DeV: " + ROUND(tDeltaV,1) + " m/s2"+tSpacer AT (3,7).
	print "BrE: " + -1*ROUND(T2Node-tT2B)+" s"+tSpacer AT (18,7).
}
