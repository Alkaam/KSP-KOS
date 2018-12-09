// Deorbit Script to Deorbit Vehicles

PARAMETER gKSCSync IS FALSE. //set TRUE if you want Try Descent on KSC
PARAMETER gPwrLnd IS FALSE. //set TRUE perform Power Descent

set gKSC to latlng(-0.0972092543643722, -74.557706433623).
// ###### CHECK ATMOSPHERE ######
SET gAtm TO BODY:ATM:EXISTS.
SET gAtmH TO BODY:ATM:HEIGHT.

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
// ###### SET UP THROTTLE AND STEERING ######
SET TVAL TO 0.
SET SVAL TO RETROGRADE.
LOCK THROTTLE TO TVAL.
LOCK STEERING TO SVAL.
SET T2Node TO 0.
// ###### SET UP VESSEL ######
SAS OFF.
RCS ON.
LIGHTS ON.
GEAR OFF.

//Maneuver Planning
SET mode TO 4.
IF SHIP:STATUS = "SUB_ORBITAL" { SET MODE TO 4. }
IF SHIP:STATUS = "FLYING" { SET MODE TO 5. }

CLEARSCREEN.

SET stopDist TO 0.
SET tSpacer TO "              ".
UNTIL mode = 0 {
	IF mode = 4 { // POWER Descent Brakes.
		RCS ON.
//		IF (WARP = 0 AND ALTITUDE > 50000) { SET WARP TO 3.}
//		ELSE IF (WARP > 0 AND ALTITUDE <= 30000) {SET WARP TO 0.}
		IF (ALTITUDE <= 45000) {
			LOCK STEERING TO SHIP:SRFRETROGRADE.
			IF (ALTITUDE <= 40000 AND AIRSPEED > 1500) {SET TVAL TO 1.}
			ELSE IF (ALTITUDE <= 20000 AND AIRSPEED > 1000) {SET TVAL TO 1.}
			ELSE IF (ALTITUDE <= 15000 AND AIRSPEED > 750) {SET TVAL TO 1.}
			ELSE {SET TVAL TO 0.}
		}
		IF (ALT:RADAR <= 10000) {
			IF (BODY:ATM:EXISTS) {SET mode TO 5.}
			ELSE {SET mode TO 6.}
		}
	} ELSE IF (mode = 5) { //POWER Descent Landing
		SET GEAR TO ALT:RADAR <= 200.
		IF (ALT:RADAR < 50) {
			SET STEERING TO HEADING(90,90).
		} ELSE {
			SET STEERING TO SRFRETROGRADE.
		}
		SET aNeed TO ABS(VERTICALSPEED)/((ALT:RADAR-2)/ABS(VERTICALSPEED)).
		SET aGive TO fTWR()*fGrav().
		PRINT "a-Need: " + ROUND(aNeed,2)+" "+tSpacer AT (3,9).
		PRINT "a-Give: " + ROUND(aGive,2)+" "+tSpacer AT (3,10).
		IF (aNeed/aGive > 1.30 AND THROTTLE = 0) {SET TVAL TO 1. WAIT 1.}
		ELSE IF (THROTTLE > 0) {SET TVAL TO GEN_TWR2Th((aNeed*1.05)/fGrav).}
		IF (ABS(SHIP:VERTICALSPEED) < 0.2) {SET TVAL TO 0. SET mode TO 20.}
	} ELSE IF (mode = 6) { //POWER Descent Landing
		IF (ALT:RADAR > 7000) {
			IF (THROTTLE = 0 AND GROUNDSPEED > 300) { SET TVAL TO 1. }
			ELSE IF (GROUNDSPEED < 150) {SET TVAL TO 0.}
		} ELSE {SET mode TO 7. SET TVAL TO 0.}
	} ELSE IF (mode = 7) { //POWER Descent Landing
		SET GEAR TO ALT:RADAR <= 200.
		IF (ALT:RADAR < 50) {
			SET STEERING TO HEADING(90,90).
		} ELSE {
			SET STEERING TO SRFRETROGRADE.
		}
		SET aNeed TO ABS(VELOCITY:SURFACE:MAG)/((ALT:RADAR-2)/ABS(VELOCITY:SURFACE:MAG)).
		SET aGive TO fTWR()*fGrav().
		PRINT "a-Need: " + ROUND(aNeed,2)+" "+tSpacer AT (3,9).
		PRINT "a-Give: " + ROUND(aGive,2)+" "+tSpacer AT (3,10).
		IF ((aNeed/aGive) > 1.60 AND THROTTLE = 0) {SET TVAL TO 1. WAIT 1.}
//		IF (aNeed/aGive < 0.30 AND ALT:RADAR > 1000 AND THROTTLE > 0) {SET TVAL TO 0. WAIT 1.}
		ELSE IF (THROTTLE > 0) {SET TVAL TO GEN_TWR2Th((aNeed*1.05)/fGrav).}
		IF (ABS(SHIP:VERTICALSPEED) < 0.2) {SET TVAL TO 0. SET mode TO 20.}
	} ELSE IF (mode = 19) { // Descent
		IF (ALT:RADAR < 500) {
			SET mode TO 20.
		} ELSE IF (ALT:RADAR < 32500) {
			SET STEERING TO SRFRETROGRADE.
		} ELSE {
			SET STEERING TO RETROGRADE.
		}
	} ELSE IF (mode = 20) { // SCRIPT END, RELEASE CONTROLS
		SET TVAL TO 0.
		UNLOCK STEERING.
		UNLOCK THROTTLE.
		SET mode to 0.
		PRINT "Deorbit and Land Complete"+tSpacer AT (3,9).
		WAIT 5.
	}
	SET PANELS TO ALT:RADAR > 65000.
	IF (THROTTLE > 0) {PRINT "#>> BURNING AT "+ROUND(THROTTLE*100,0)+"% <<#"+tSpacer AT (3,0).}
	ELSE {PRINT tSpacer+tSpacer AT (3,0).}
	PRINT "Scola-Sys - Deorbit (RM:"+mode+") "+SHIP:STATUS+tSpacer AT (3,2).
	PRINT "[KSC:"+gKSCSync+"]"+tSpacer AT (3,3).
	PRINT "ApH: " + ROUND(APOAPSIS/1000, 1) + " km"+tSpacer AT (3,5).
	PRINT "PeH: " + ROUND(PERIAPSIS/1000, 1) + " km"+tSpacer AT (18,5).
	PRINT "ApE: " + ROUND(ETA:APOAPSIS,0) + " s"+tSpacer AT (3,6).
	PRINT "PeE: " + ROUND(ETA:PERIAPSIS,0) + " s"+tSpacer AT (18,6).
	IF (mode > 0 AND mode <= 3) {
		IF (gKSCSync) { PRINT "BrA: " + ROUND(PhaseAngle,0) + " deg"+tSpacer AT (3,7). }
		PRINT "BrE: " + ROUND(TIME:SECONDS-T2Node)+" s"+tSpacer AT (18,7).
	} ELSE IF (mode >= 4) {
		PRINT "VSI: " + ROUND(VERTICALSPEED,2) + " m/s"+tSpacer AT (3,7).
		PRINT "HSI: " + ROUND(GROUNDSPEED,2)+" m/s"+tSpacer AT (18,7).
		PRINT "ALT: " + ROUND(ALT:RADAR,0)+" m"+tSpacer AT (3,8).
	}
}
