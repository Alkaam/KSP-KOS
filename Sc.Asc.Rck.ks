PARAMETER gOrbit IS 85000. //Orbit to Reach, DEFAULT = 85km.
PARAMETER gHeading IS 90. //Direction to Orbit, DEFAULT = 90 (EAST).
PARAMETER gStaging IS FALSE. //Call for Staging Events in Mission File.
SET TVAL TO 0.
SET SVAL TO UP.
LOCK THROTTLE TO TVAL.
LOCK STEERING TO SVAL.
LOCK GRAVITY TO (CONSTANT():G * BODY:MASS) / (SHIP:ALTITUDE+BODY:RADIUS)^2.
LOCK TWR TO MAX( 0.001, MAXTHRUST / (MASS*GRAVITY)).
SET gAtm TO BODY:ATM:EXISTS.
SET gAtmH TO BODY:ATM:HEIGHT.
SET gEndGravTurn TO gAtmH * 0.87.
SAS OFF.
RCS OFF.
LIGHTS OFF.
GEAR OFF.
CLEARSCREEN.

SET mode TO 1.
IF SHIP:STATUS = "PREFLIGHT" { SET MODE TO 1. }
IF SHIP:STATUS = "FLYING" { SET MODE TO 3. }
IF SHIP:STATUS = "SUBORBITAL" { SET MODE TO 5. }

until mode = 0 {
	IF (gStaging) { fMissStage(). }
	SET VSI TO ROUND(VERTICALSPEED,2).
	SET HSI TO ROUND(GROUNDSPEED,2).
	SET SALT TO ROUND(SHIP:ALTITUDE,0).
	SET tSpacer TO "              ".
	print "Scola-Sys - Ascension (RM:"+mode+") "+SHIP:STATUS+tSpacer AT (3,2).
	print "Target Orbit: "+ROUND(gOrbit/1000,0)+" km [Atm:"+gAtm+"]"+tSpacer AT (3,3).
	print "ApH: " + round(APOAPSIS/1000, 1) + " km"+tSpacer AT (3,4).
	print "PeH: " + round(PERIAPSIS/1000, 1) + " km"+tSpacer AT (18,4).
	print "ApE: " + round(ETA:APOAPSIS,0) + " s"+tSpacer AT (3,5).
	print "PeE: " + round(ETA:PERIAPSIS,0) + " s"+tSpacer AT (18,5).
	print "VSI: " + round(VSI,0)+ " m/s "+tSpacer AT (3,6).
	print "HSI: " + round(HSI,0)+ " m/s "+tSpacer AT (18,6).
	print "SpO: " + round(VELOCITY:ORBIT:MAG, 2)+ " m/s "+tSpacer AT (3,7).
	IF (mode = 6) {
		print "Exit Atmosphere in: "+ROUND((70000-SALT)/VSI,1)+" s"+tSpacer AT (3,9).
	}
	IF (mode = 7) {
		SET tDeltaV TO MAN_DV(gOrbit,gOrbit).
		SET tBTime TO MAN_BTime(MAN_ISP(),tDeltaV).
		SET tT2B TO tBTime*0.50.
		print "DeV: "+ROUND(tDeltaV,1)+" m/s2 in T "+-1*ROUND(ETA:APOAPSIS-tT2B)+" s"+tSpacer AT (3,9).
	}

	if mode = 1 { // launch print "T-MINUS 10 seconds". lock steering to up. wait 1.
		SET TVAL TO 1.
		SET SVAL TO SHIP:FACING.
		WAIT 2.
		STAGE.
		SET MODE TO 2.
	}
	else if mode = 2{ // gravity turn
		SET TVAL TO 1.
		SET SVAL TO SHIP:FACING.
		if (SALT > 500 AND VSI > 150) { set mode to 3.}
	}
	else if mode = 3{ // Gravity Turn Step 1/2
		SET TVAL TO GEN_TWR2Th(1.50).
		SET tPtc TO GEN_TgPitch2(5,gOrbit).
		SET SVAL TO heading (90, tPtc).
		if ETA:APOAPSIS > 35 { set mode to 5. }
		ELSE if SHIP:APOAPSIS >= gOrbit { set mode to 6. }
	}
	else if mode = 5{ // Gravity Turn Step 2/2
		SET DiffVelComp TO MIN(0.50,MAX(-0.95,(40-ETA:APOAPSIS)/50)).
		SET SVAL TO HEADING(90,GEN_TgPitch2(GEN_AngPro(8),gOrbit)).
		SET TVAL TO GEN_TWR2Th(1.1+DiffVelComp).
		IF (SHIP:APOAPSIS >= gOrbit) {
			IF (gAtm) {SET mode TO 6.}
			ELSE {SET mode TO 7.}
		}
	}
	else if mode = 6{ // Coast to Edge of Atmosphere
		IF (SHIP:APOAPSIS >= gOrbit) {
			SET TVAL TO 0.
			SET SVAL TO HEADING(90,GEN_AngPro()).
		} ELSE {
			SET TVAL TO 0.20.
		}
		IF (SALT >= 70000) {SET MODE TO 20.}
	}
	else if mode = 7{ // Circularization
		SET TempTime TO ETA:APOAPSIS-tT2B.
		IF (WARP = 0 AND TempTime > 70) {SET WARP TO 3.}
		IF (WARP > 0 AND TempTime <= 70) {SET WARP TO 0.}
		IF (TempTime  <= 50) {SET SVAL TO HEADING(90,-1).}
		IF (SHIP:PERIAPSIS >= gOrbit) {SET TVAL TO 0. SET mode TO 20.}
		ELSE IF (TempTime  < 0 AND TVAL = 0) {SET TVAL TO 1.}
	}

	else if mode = 20 {
		SET TVAL TO 0.
		unlock steering.
		unlock throttle.
		set mode to 0.
		print "Ascent Phase Complete"+tSpacer AT (3,9).
		wait 5.
	}

	// this is the staging code to work with all rockets //

	if stage:number > 0 AND maxthrust = 0 {
		LOCK THROTTLE TO 0.
		WAIT 1.
		STAGE.
		WAIT 2.
		LOCK THROTTLE TO TVAL.
	}

}