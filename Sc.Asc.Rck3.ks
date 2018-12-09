PARAMETER gOrbit IS 85000. //Orbit to Reach, DEFAULT = 85km.
PARAMETER gStageLimit IS 0. //Limit to Autostage.
PARAMETER gHeading IS 90. //Direction to Orbit, DEFAULT = 90 (EAST).
PARAMETER gStaging IS TRUE. //Call for Staging Events in Mission File.
// ######### OBSOLETE TO BE REMOVED ##########
LOCK GRAVITY TO (CONSTANT():G * BODY:MASS) / (SHIP:ALTITUDE+BODY:RADIUS)^2.
LOCK TWR TO MAX( 0.001, MAXTHRUST / (MASS*GRAVITY)).
// ###### CHECK ATMOSPHERE ######
SET gAtm TO BODY:ATM:EXISTS.
SET gAtmH TO BODY:ATM:HEIGHT.
// ###### SET UP THROTTLE AND STEERING ######
SET TVAL TO 0.
SET SVAL TO UP.
LOCK THROTTLE TO TVAL.
LOCK STEERING TO SVAL.
// ###### SET UP VESSEL ######
SAS OFF.
RCS OFF.
LIGHTS OFF.
GEAR OFF.
CLEARSCREEN.

SET mode TO 2.
SET ModeName TO list("---","Ascension Complete","Pre-Flight","Launch","Ascension","Rising PE","Coasting").
IF SHIP:STATUS = "PREFLIGHT" { SET MODE TO 2. }
IF SHIP:STATUS = "FLYING" { SET MODE TO 4. }
IF SHIP:STATUS = "SUB_ORBITAL" { SET MODE TO 1. }

FUNCTION MATH_AngNorm2 {
	PARAMETER fAng.
	RETURN fAng - 180*FLOOR(fAng/360).
}

until mode = 0 {
	IF (gStaging) { fMissStage(). }  // ### STAGING CHECK ###
	SET VSI TO ROUND(VERTICALSPEED,2).
	SET HSI TO ROUND(GROUNDSPEED,2).
	SET SALT TO ROUND(SHIP:ALTITUDE,0).
	SET tSpacer TO "              ".
	print "Scola-Sys - "+ModeName[mode]+" ("+SHIP:STATUS+")"+tSpacer AT (3,2).
	print "Target Orbit: "+ROUND(gOrbit/1000,0)+" km [Atm:"+gAtm+"]"+tSpacer AT (3,3).
	print "ApH: " + round(APOAPSIS/1000, 1) + " km"+tSpacer AT (3,4).
	print "PeH: " + round(PERIAPSIS/1000, 1) + " km"+tSpacer AT (18,4).
	print "ApE: " + round(ETA:APOAPSIS,0) + " s"+tSpacer AT (3,5).
	print "PeE: " + round(ETA:PERIAPSIS,0) + " s"+tSpacer AT (18,5).
	print "VSI: " + round(VSI,0)+ " m/s "+tSpacer AT (3,6).
	print "HSI: " + round(HSI,0)+ " m/s "+tSpacer AT (18,6).
	print "SpO: " + round(VELOCITY:ORBIT:MAG, 0)+ " m/s "+tSpacer AT (3,7).
	print "  Q: " + round(SHIP:Q, 5)+ " atm "+tSpacer AT (18,7).
	IF mode = 1 { // SCRIPT END, RELEASE CONTROLS
		SET TVAL TO 0.
		UNLOCK STEERING.
		UNLOCK THROTTLE.
		SET mode TO 0.
		PRINT "Ascent Phase Complete"+tSpacer AT (3,9).
		WAIT 5.
	} ELSE IF mode = 2 { // ### FINAL SET UP AND LAUNCH
		SET TVAL TO 1.
		SET SVAL TO SHIP:FACING.
		WAIT 2.
		STAGE.
		SET MODE TO 3.
	} else if mode = 3{ // ### FLY UP TO SAFETY
		SET TVAL TO 1.
		if (SALT > 300 AND VSI > 50) { set mode to 4.}
	} else if mode = 4{ // ### Start Turn and Follow it untill AP is at 85%
		SET tCorr TO MAX(0,MIN(3,(3*(SALT/(gAtmH*0.66))^3))).
		print "TWR Corr: " + round(tCorr, 2)+ " "+tSpacer AT (3,9).
		IF (SALT < 5000 AND VELOCITY:ORBIT:MAG < 300) {SET TVAL TO 1.}
		ELSE { SET TVAL TO GEN_TWR2Th(2.00+tCorr). }
		SET tPtc TO 90*(1-(SHIP:APOAPSIS/gOrbit)^0.92).
		SET SVAL TO heading (gHeading, tPtc).
		if ETA:APOAPSIS > 35 AND SHIP:APOAPSIS >= gOrbit*0.85 { set mode to 5. }
	} else if mode = 5{ // Rise PE faster than AP for a less cost circularization
		SET DiffVelComp TO MIN(0.50,MAX(-0.95,(40-ETA:APOAPSIS)/50)).
		SET tPtcCorr TO 8*(1-(ETA:APOAPSIS-20)/20).
		print "Ptc Corr: " + round(tPtcCorr, 2)+ " "+tSpacer AT (3,9).
		SET tPtcCorr TO MAX(-15,MIN(5,tPtcCorr)).
		SET tPtc TO GEN_AngPro(0)+tPtcCorr.
		SET SVAL TO heading (gHeading, tPtc).
		SET TVAL TO GEN_TWR2Th(1.4+DiffVelComp).
		IF (WARP > 0 AND SHIP:APOAPSIS >= gOrbit-5000) {SET WARP TO 0.}
		IF (SHIP:APOAPSIS >= gOrbit) {
			IF (gAtm) {SET mode TO 6.}
			ELSE {SET mode TO 1.}
		}
	}
	else if mode = 6{ // in case it is needed, cost to edge of atmo
		print "Exit Atmosphere in: "+ROUND((70000-SALT)/VSI,1)+" s"+tSpacer AT (3,9).
		IF ((70000-SALT)/VSI > 70 AND WARP = 0) {SET WARP TO 3.}
		ELSE IF ((70000-SALT)/VSI < 45 AND WARP > 0) {SET WARP TO 0.}
		IF (SHIP:APOAPSIS >= gOrbit) {
			SET TVAL TO 0.
			SET SVAL TO HEADING(gHeading,GEN_AngPro()).
		} ELSE {
			SET TVAL TO 0.20.
		}
		IF (SALT >= 70000) {SET MODE TO 1.}
	}
	IF STAGE:NUMBER > 0 {
		IF MAXTHRUST = 0 {
			LOCK THROTTLE TO 0.
			WAIT 1.
			STAGE.
			WAIT 2.
			LOCK THROTTLE TO TVAL.
		}
		SET numOut to 0.
		LIST ENGINES IN engines. 
		FOR eng IN engines 
		{
			IF eng:FLAMEOUT 
			{
				SET numOut TO numOut + 1.
			}
		}
		if numOut > 0 { STAGE. }.
	}
}
