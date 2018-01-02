// Deorbit Script to Deorbit Vehicles

PARAMETER gKSCSync IS FALSE. //set TRUE if you want Try Descent on KSC
PARAMETER gPwrLnd IS FALSE. //set TRUE perform Power Descent

set gKSC to latlng(-0.0972092543643722, -74.557706433623).

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
SET SVAL TO RETROGRADE.
LOCK THROTTLE TO TVAL.
LOCK STEERING TO SVAL.
SET T2Node TO 100.

//Maneuver Planning

SET mode TO 1.
CLEARSCREEN.
SET tSpacer TO "              ".
UNTIL mode = 0 {
	IF mode = 1 {
		IF (gKSCSync) {
			SET PhaseAngle TO MATH_PhaseAng(BODY:ROTATIONANGLE-74)+277. //[0...360].
			SET BrTime TO PhaseAngle/((360/SHIP:OBT:PERIOD)-(360/BODY:ROTATIONPERIOD)). //Calculate How much time needed to Wait Before the Burn.
			SET T2Node TO TIME:SECONDS + BrTime.
		}
		SET mode TO 2.
		LOCK TempTime TO -1*(TIME:SECONDS-T2Node).
	}
	IF mode = 2 { // Warpo to Position
		IF (WARP = 0 AND TempTime >= 70) {SET WARP TO 3.}
		ELSE IF (WARP > 0 AND TempTime <= 50) {SET WARP TO 0.}
		IF (TempTime <= 30) {
			SET mode TO 3.
			LOCK SVAL TO RETROGRADE.
		}
	} ELSE IF mode = 3 { // Deorbit
		IF (SHIP:PERIAPSIS <= -20000) {
			IF (gKSCSync) {SET mode TO 4.}
			SET TVAL TO 0.
			WAIT 2.
			STAGE.
			WAIT 2.
		} ELSE IF (TempTime < 0 AND TVAL = 0) {
			SET TVAL TO 1.
		}
	} ELSE IF mode = 4 { // POWER Descent Brakes.
		IF (WARP = 0 AND ALTITUDE > 50000) {SET WARP TO 3.}
		ELSE IF (WARP > 0 AND ALTITUDE <= 30000) {SET WARP TO 0.}
		IF (ALTITUDE <= 45000) {
			LOCK STEERING TO SHIP:SRFRETROGRADE.
			IF (ALTITUDE <= 40000 AND AIRSPEED > 1500) {SET TVAL TO 1.}
			ELSE IF (ALTITUDE <= 20000 AND AIRSPEED > 1000) {SET TVAL TO 1.}
			ELSE IF (ALTITUDE <= 10000 AND AIRSPEED > 500) {SET TVAL TO 1.}
			ELSE {SET TVAL TO 0.}
		}
		IF (ALT:RADAR <= 5000) {SET mode TO 5.}
	} ELSE IF mode = 5 { //POWER Descent Landing
		SET GEAR TO ALT:RADAR <= 500.
		IF (ALT:RADAR > 200) {
			SET tVSpd TO (ALT:RADAR*0.10).
		} ELSE {
			SET tVSpd TO 1.0.
			SET STEERING TO UP.
		}
		SET tDVNow TO (VERTICALSPEED*-1)-tVSpd.
		SET tTWRErr TO tDVNow/200.
		SET tTWR TO (1/fTWR())+tTWRErr*1.80.
		SET TVAL TO MAX(0,MIN(1,tTWR)).
	} ELSE IF (mode = 6) {
		SET GEAR TO ALT:RADAR <= 500.
		SET SALT TO ALT:RADAR-10.
		SET maxDecel to (SHIP:AVAILABLETHRUST / SHIP:MASS) - fGrav().	// Maximum deceleration possible (m/s^2)
		SET stopDist to SHIP:VERTICALSPEED^2 / (2 * maxDecel).		// The distance the burn will require
		SET idealThrottle to stopDist / SALT.			// Throttle required for perfect hoverslam
		SET impactTime to SALT / ABS(SHIP:VERTICALSPEED).		// Time until impact, used for landing gear
		IF (SALT < stopDist) {SET TVAL TO idealThrottle.}
		ELSE {SET TVAL TO 0.}
		IF (ABS(SHIP:VERTICALSPEED) < 0.1) {SET TVAL TO 0. SET mode TO 20.}
	} ELSE IF (mode = 20) { // SCRIPT END, RELEASE CONTROLS
		SET TVAL TO 0.
		UNLOCK STEERING.
		UNLOCK THROTTLE.
		SET mode to 0.
		PRINT "Deorbit and Land Complete"+tSpacer AT (3,9).
		WAIT 5.
	}

	IF (THROTTLE > 0) {PRINT "#>> BURNING AT "+ROUND(THROTTLE*100,0)+"% <<#"+tSpacer AT (3,0).}
	ELSE {PRINT tSpacer AT (3,0).}
	PRINT "Scola-Sys - Deorbit (RM:"+mode+") "+SHIP:STATUS+tSpacer AT (3,2).
	PRINT "[KSC:"+gKSCSync+"]"+tSpacer AT (3,3).
	PRINT "ApH: " + ROUND(APOAPSIS/1000, 1) + " km"+tSpacer AT (3,5).
	PRINT "PeH: " + ROUND(PERIAPSIS/1000, 1) + " km"+tSpacer AT (18,5).
	PRINT "ApE: " + ROUND(ETA:APOAPSIS,0) + " s"+tSpacer AT (3,6).
	PRINT "PeE: " + ROUND(ETA:PERIAPSIS,0) + " s"+tSpacer AT (18,6).
	IF (mode <= 3) {
		PRINT "BrA: " + ROUND(PhaseAngle,0) + " deg"+tSpacer AT (3,7).
		PRINT "BrE: " + ROUND(TIME:SECONDS-T2Node)+" s"+tSpacer AT (18,7).
	} ELSE IF (mode >= 4) {
		PRINT "VSI: " + ROUND(VERTICALSPEED,0) + " m/s"+tSpacer AT (3,7).
		PRINT "HSI: " + ROUND(GROUNDSPEED,0)+" m/s"+tSpacer AT (18,7).
		PRINT "ALT: " + ROUND(ALT:RADAR,0)+" m"+tSpacer AT (3,8).
	}
	IF (mode = 6) {
		PRINT "DeM: " + ROUND(maxDecel,0) + " m/s2"+tSpacer AT (18,8).
	}
}
