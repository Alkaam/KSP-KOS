//Intercept Script, can be Used to Intercept another Vehicle
// or to set up an equidistant satellite network.

PARAMETER gOrbit IS 90000.
PARAMETER gTarget IS "None".
PARAMETER gDock IS FALSE.
PARAMETER gTgPort IS "None".

SET TVAL TO 0.
SET SVAL TO PROGRADE.
LOCK THROTTLE TO TVAL.
LOCK STEERING TO SVAL.
SET T2Node TO 100.

//Maneuver Planning
	SET TARGET TO gTarget.
	SET A1 TO SHIP:OBT:BODY:RADIUS + (SHIP:ALTITUDE + TARGET:ALTITUDE)/2.
	SET A2 TO TARGET:OBT:SEMIMAJORAXIS.
	SET T2 TO TARGET:OBT:PERIOD.
	SET gOrbit TO TARGET:OBT:APOAPSIS.
	SET TrObtPhase TO 1/(2*sqrt(A2^3/A1^3)). //Phasing Orbit % of the Target Orbit.
	SET BrAngPhase TO 180-(360*TrObtPhase). //Angular Distance Between My and Tg at the BurnPoint
	SET PhaseAngle TO MATH_PhaseAng(). //[0...360].
	SET BrTime TO (MATH_AngNorm(PhaseAngle-BrAngPhase))/((360/SHIP:OBT:PERIOD)-(360/TARGET:OBT:PERIOD)). //Calculate How much time needed to Wait Before the Burn.
	SET T2Node TO TIME:SECONDS + BrTime.
	SET T1 TO T2 * (A1/A2)^1.5.


SET mode TO 1.
CLEARSCREEN.
SET tSpacer TO "              ".
SET tDistDelta TO 0.
UNTIL mode = 0 {
	IF mode = 1 {
	  SET mode TO 2.
	  SET tDeltaV TO MAN_DV(SHIP:APOAPSIS,gOrbit).
	  SET tBTime TO MAN_BTime(MAN_ISP(),tDeltaV).
	  SET tT2B TO tBTime*0.50.
	  LOCK TempTime TO -1*(TIME:SECONDS-T2Node-tT2B).
	}
	IF mode = 2 { // Warpo to Position
		IF (WARP = 0 AND TempTime >= 70) {SET WARP TO 3.}
		ELSE IF (WARP > 0 AND TempTime <= 50) {SET WARP TO 0.}
		IF (TempTime <= 30) {
			SET mode TO 3.
			LOCK SVAL TO PROGRADE.
		}
	} ELSE IF mode = 3 { // Circularization at Apoapsis
		IF (SHIP:APOAPSIS >= gOrbit) {
			SET TVAL TO 0.
			SET mode TO 4.
		} ELSE IF (SHIP:APOAPSIS >= gOrbit*0.95) {
			SET SVAL TO TARGET:POSITION:DIRECTION.
			SET TVAL TO (1-(SHIP:APOAPSIS/(gOrbit+5000)))*2.
		} ELSE IF (TempTime < 0 AND TVAL = 0) {
			SET TVAL TO 1.
		}
		SET tDist TO POSITIONAT(SHIP,TIME+ETA:APOAPSIS)-POSITIONAT(TARGET,TIME+ETA:APOAPSIS).
		PRINT "DIST: "+ROUND(tDist:MAG/1000,0)+"km"+tSpacer AT (3,16).
		IF (tDist:MAG <= 10000 AND tDist:MAG-tDistDelta > 0) {
			SET tDistDelta TO 0.
			SET TVAL TO 0.
			SET mode TO 4.
		} ELSE {
			SET tDistDelta TO tDist:MAG.
		}
	} ELSE IF mode = 4 { // Wait Closer Approach
		SET tDist TO TARGET:DISTANCE.
		SET rVelVec TO TARGET:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT.
		SET SVAL TO rVelVec:DIRECTION.
		PRINT "DIST: "+ROUND(tDist/1000,1)+"km"+tSpacer AT (3,16).
		IF (tDist <= 10000 AND tDist-tDistDelta > 0) {
			SET tDistDelta TO 0.
			SET TVAL TO 0.
			SET mode TO 5.
		} ELSE IF (tDist < 150) {
			SET mode TO 5.
		} ELSE {
			SET tDistDelta TO tDist.
		}
	} ELSE IF mode = 5 { // Cancel Relative Velocity
		SET tDist TO TARGET:DISTANCE.
		SET rVelVec TO TARGET:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT.
		SET tPrec TO MAX(0.10,tDist*0.00075).
		PRINT "RVEL: "+ROUND(rVelVec:MAG,1)+" ["+ROUND(tPrec,1)+"]"+tSpacer AT (3,16).
		SET SVAL TO rVelVec:DIRECTION.
		IF (tDist < 150 AND rVelVec:MAG < 0.1) {
			SET TVAL TO 0.
			SET mode TO 7.
			RCS ON.
			SET dockingPort TO SHIP:DOCKINGPORTS[0].
			SET tTgPort TO fTgPort().
		}
		IF (GEN_AngSteer(0.50)) {
			IF (rVelVec:MAG > tPrec OR tDist < 150) { SET TVAL TO MAX(0.05,rVelVec:MAG/20). }
			ELSE { SET TVAL TO 0. SET mode TO 6. }
		} ELSE { SET TVAL TO 0. }
	} ELSE IF mode = 6 { // Burn to Close to Target
		SET SVAL TO TARGET:POSITION:DIRECTION.
		SET rVelVec TO TARGET:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT.
		SET tDist TO TARGET:DISTANCE.
		SET tPrec TO MAX(0.50,tDist*0.01).
		IF (GEN_AngSteer()) {
			IF (rVelVec:MAG < tPrec) { SET TVAL TO 1. }
			ELSE { SET tDistDelta TO tDist. SET TVAL TO 0. SET mode TO 4. }
		} ELSE { SET TVAL TO 0. }
	} ELSE IF mode = 7 { // Burn to Close to Target
		dockingPort:CONTROLFROM().
		SET tDistOff TO tTgPort:PORTFACING:VECTOR * 200.
		
	} ELSE IF (mode = 20) { // SCRIPT END, RELEASE CONTROLS
		SET TVAL TO 0.
		unlock steering.
		unlock throttle.
		set mode to 0.
		print "Circularization Complete"+tSpacer AT (3,9).
		wait 5.
	}

	print "Scola-Sys - Intercept (RM:"+mode+") "+SHIP:STATUS+tSpacer AT (3,2).
	print "ApH: " + ROUND(APOAPSIS/1000, 1) + " km"+tSpacer AT (3,5).
	print "PeH: " + ROUND(PERIAPSIS/1000, 1) + " km"+tSpacer AT (18,5).
	print "ApE: " + ROUND(ETA:APOAPSIS,0) + " s"+tSpacer AT (3,6).
	print "PeE: " + ROUND(ETA:PERIAPSIS,0) + " s"+tSpacer AT (18,6).
	print "oA1: " + ROUND(A1/1000,1) + " km"+tSpacer AT (3,7).
	print "oT1: " + ROUND(T1,0) + " s"+tSpacer AT (18,7).
	print "oA2: " + ROUND(A2/1000,1) + " km"+tSpacer AT (3,8).
	print "oT2: " + ROUND(T2,0) + " s"+tSpacer AT (18,8).
	print "BrA: " + ROUND(BrAngPhase,0) + " deg"+tSpacer AT (3,9).

	print "DeV: " + ROUND(tDeltaV,1) + " m/s2"+tSpacer AT (3,15).
	print "BrE: " + ROUND(TIME:SECONDS-T2Node-tT2B)+" s"+tSpacer AT (18,15).
}
