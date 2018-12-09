//Intercept Script, can be Used to Intercept another Vehicle
// or to set up an equidistant satellite network.

PARAMETER gOrbit IS 2863330.
PARAMETER gSatNum IS 0. //the Number of the Satellite like in a row of 6 satellite, this is the 3
PARAMETER gSatTot IS 1. //total number of satellite to calculate angle separation.
PARAMETER gKSCSync IS FALSE. //set true to have this satellite sit above KSC

set gKSC to latlng(-0.0972092543643722, -74.557706433623).

FUNCTION TARGET_ANGLE {
  PARAMETER target.
  RETURN MOD(LNG_TO_DEGREES(ORBITABLE(target):LONGITUDE),- LNG_TO_DEGREES(SHIP:LONGITUDE) + 360,360).
}

FUNCTION MATH_PhaseAng {
	PARAMETER fAng2 IS TARGET:OBT:LAN+TARGET:OBT:ARGUMENTOFPERIAPSIS+TARGET:OBT:TRUEANOMALY. //target angle
	PARAMETER fAng1 IS OBT:LAN+OBT:ARGUMENTOFPERIAPSIS+OBT:TRUEANOMALY. //the ships angle to universal reference direction.
	SET fRet TO fAng2-fAng1.
	SET fRet TO MATH_AngNorm(fRet). //normalization
	RETURN fRet.
}

FUNCTION MATH_AngNorm {
	PARAMETER fAng.
	RETURN fAng - 360*FLOOR(fAng/360).
}

RCS OFF.
SAS OFF.
SET TVAL TO 0.
SET SVAL TO PROGRADE.
LOCK THROTTLE TO TVAL.
LOCK STEERING TO SVAL.
SET T2Node TO 100.

//Maneuver Planning
	IF (gTarget <> "None") {
		SET TARGET TO gTarget.
		SET A1 TO SHIP:OBT:BODY:RADIUS + (SHIP:ALTITUDE + TARGET:ALTITUDE)/2.
		SET A2 TO TARGET:OBT:SEMIMAJORAXIS.
		SET T2 TO TARGET:OBT:PERIOD.
		SET gOrbit TO TARGET:OBT:APOAPSIS.
		SET TrObtPhase TO 1/(2*sqrt(A2^3/A1^3)). //Phasing Orbit % of the Target Orbit.
		SET BrAngPhase TO 180-(360*TrObtPhase). //Angular Distance Between My and Tg at the BurnPoint
		SET PhaseAngle TO MATH_PhaseAng()+((360/gSatTot)*gSatNum). //[0...360].
		SET BrTime TO (MATH_AngNorm(PhaseAngle-BrAngPhase))/((360/SHIP:OBT:PERIOD)-(360/TARGET:OBT:PERIOD)). //Calculate How much time needed to Wait Before the Burn.
	} ELSE {
		SET A1 TO SHIP:OBT:BODY:RADIUS + (SHIP:ALTITUDE + gOrbit)/2.
		SET A2 TO SHIP:OBT:BODY:RADIUS + gOrbit.
		SET T2 TO MAN_OrbT(A2).
		SET TrObtPhase TO 1/(2*sqrt(A2^3/A1^3)). //Phasing Orbit % of the Target Orbit.
		SET BrAngPhase TO 180-(360*TrObtPhase). //Angular Distance Between My and Tg at the BurnPoint
		IF (gKSCSync) {
			SET PhaseAngle TO MATH_PhaseAng(BODY:ROTATIONANGLE-74). //[0...360].
		} ELSE {
			SET PhaseAngle TO MATH_PhaseAng(0). //[0...360].
		}
		SET BrTime TO (MATH_AngNorm(PhaseAngle-BrAngPhase))/((360/SHIP:OBT:PERIOD)-(360/T2)). //Calculate How much time needed to Wait Before the Burn.
	}
	SET T2Node TO TIME:SECONDS + BrTime.
	SET T1 TO T2 * (A1/A2)^1.5.




FUNCTION Trans_Calc {
}
//TODO: Add Satellite Network Positioning, can just do Beta = (360/gSatTot)*gSatNum
//TODO: Add Satellite Virtual Position, to fine tune the orbit (Similar to Docking)

SET mode TO 1.
CLEARSCREEN.
SET tSpacer TO "              ".
UNTIL mode = 0 {
	IF mode = 1 {
	  SET mode TO 2.
	  Trans_Calc().
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
			SET TVAL TO (1-(SHIP:APOAPSIS/gOrbit))*2.
		} ELSE IF (TempTime < 0 AND TVAL = 0) {
			SET TVAL TO 1.
		}
	} ELSE IF mode = 4 { // Circularization at Periapsis
		IF (WARP = 0 AND ETA:APOAPSIS >= 70) {SET WARP TO 3.}
		ELSE IF (WARP > 0 AND ETA:APOAPSIS <= 50) {SET WARP TO 0.}
		IF (ETA:APOAPSIS <= 45) {
			SET mode TO 5.
			LOCK SVAL TO PROGRADE.
			SET tDeltaV TO MAN_DV(gOrbit,gOrbit).
			SET tBTime TO MAN_BTime(MAN_ISP(),tDeltaV).
			SET tT2B TO tBTime*0.50.
			LOCK TempTime TO ETA:APOAPSIS-tT2B.
		}
	} ELSE IF mode = 5 { // Circularization at Apoapsis
		IF (SHIP:OBT:PERIOD >= T2) {
			SET TVAL TO 0.
			SET mode TO 20.
		} ELSE IF (SHIP:OBT:PERIOD >= T2*0.995) {
			SET TVAL TO (1-(SHIP:OBT:PERIOD/T2))*3.
		} ELSE IF (TempTime < 0 AND TVAL = 0) {
			SET TVAL TO 1.
		}
	} ELSE IF (mode = 20) { // SCRIPT END, RELEASE CONTROLS
		SET TVAL TO 0.
		unlock steering.
		unlock throttle.
		set mode to 0.
		print "Circularization Complete"+tSpacer AT (3,9).
		wait 5.
	}

	print "Scola-Sys - Intercept (RM:"+mode+") "+SHIP:STATUS+tSpacer AT (3,2).
	print "Target Orbit: "+ROUND(gOrbit/1000,0)+" km [KSC:"+gKSCSync+"]"+tSpacer AT (3,3).
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
