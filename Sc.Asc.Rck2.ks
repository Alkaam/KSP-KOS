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

SET mode TO 1.
IF SHIP:STATUS = "PREFLIGHT" { SET MODE TO 1. }
IF SHIP:STATUS = "FLYING" { SET MODE TO 3. }
IF SHIP:STATUS = "SUB_ORBITAL" { SET MODE TO 20. }

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

	if mode = 1 { // ### FINAL SET UP AND LAUNCH
		SET TVAL TO 1.
		SET SVAL TO SHIP:FACING.
		WAIT 2.
		STAGE.
		SET MODE TO 2.
	}
	else if mode = 2{ // ### FLY UP TO SAFETY
		SET TVAL TO 1.
		SET SVAL TO SHIP:FACING.
		if (SALT > 300 AND VSI > 50) { set mode to 3.}
	}
	else if mode = 3{ // ### G-Turn UNTIL APOAPSIS IS 35 SEC AHEAD
		IF (SALT < 5000 AND VELOCITY:ORBIT:MAG < 300) {SET TVAL TO 1.}
		ELSE { SET TVAL TO GEN_TWR2Th(1.60). }
		SET tPtc TO 90*(1-(SHIP:APOAPSIS/gOrbit)^1.15).
		SET SVAL TO heading (gHeading, tPtc).
		if ETA:APOAPSIS > 35 AND SHIP:APOAPSIS >= gOrbit*0.85 { set mode to 5. }
	}
	else if mode = 5{ // G-Turn UNTIL APOAPSIS REACH ORBIT HEIGHT
		SET DiffVelComp TO MIN(0.50,MAX(-0.95,(40-ETA:APOAPSIS)/50)).
		SET tPtcCorr TO 8*(1-(ETA:APOAPSIS-20)/20).
		print "Corr: " + round(tPtcCorr, 2)+ " "+tSpacer AT (3,8).
		SET tPtcCorr TO MAX(0,MIN(8,tPtcCorr)).
//		IF (ETA:APOAPSIS < 20) {SET tPtc TO GEN_AngPro(2).}
//		ELSE {SET tPtc TO GEN_AngPro(-6).}
		SET tPtc TO GEN_AngPro(-7)+tPtcCorr.
		SET SVAL TO heading (gHeading, tPtc).
		SET TVAL TO GEN_TWR2Th(1.4+DiffVelComp).
		IF (WARP > 0 AND SHIP:APOAPSIS >= gOrbit-5000) {SET WARP TO 0.}
		IF (SHIP:APOAPSIS >= gOrbit) {
			IF (gAtm) {SET mode TO 6.}
			ELSE {SET mode TO 20.}
		}
	}
	else if mode = 6{ // IF ATMO COAST TO EDGE OF ATMO
		IF ((70000-SALT)/VSI > 70 AND WARP = 0) {SET WARP TO 3.}
		ELSE IF ((70000-SALT)/VSI < 45 AND WARP > 0) {SET WARP TO 0.}
		IF (SHIP:APOAPSIS >= gOrbit) {
			SET TVAL TO 0.
			SET SVAL TO HEADING(gHeading,GEN_AngPro()).
		} ELSE {
			SET TVAL TO 0.20.
		}
		IF (SALT >= 70000) {SET MODE TO 20.}
	} ELSE IF mode = 20 { // SCRIPT END, RELEASE CONTROLS
		SET TVAL TO 0.
		UNLOCK STEERING.
		UNLOCK THROTTLE.
		SET mode TO 0.
		PRINT "Ascent Phase Complete"+tSpacer AT (3,9).
		WAIT 5.
	}
if stage:number > 0 {
    if maxthrust = 0 {
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
//	if stage:number > gStageLimit AND maxthrust = 0 {
//		LOCK THROTTLE TO 0.
//		WAIT 1.
//		STAGE.
//		WAIT 2.
//		LOCK THROTTLE TO TVAL.
//	}

}
