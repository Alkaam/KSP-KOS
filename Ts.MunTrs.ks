// Transfer to Mun / Optional DI, FRT
//"Ts.MunTrs.ks",FALSE,5000,0.20.
PARAMETER gOpt IS FALSE. //set DI for Direct Impact or FRT for Free Return Trajectory
PARAMETER gOrbit IS 30000. //Set Desired PE at Encounter
PARAMETER gPrec IS 0.20. //Set Precition of Peripasis

// ###### SET UP THROTTLE AND STEERING ######
CLEARSCREEN.
SET TARGET TO "MUN".
SET gOrbMin TO gOrbit*(1-gPrec).
SET gOrbMax TO gOrbit*(1+gPrec).
SET T2Node TO 0.
SET TVAL TO 0.
SET SVAL TO PROGRADE.
LOCK THROTTLE TO TVAL.
LOCK STEERING TO SVAL.

// ###### SET UP VESSEL ######
SAS OFF.
RCS ON.
LIGHTS ON.
GEAR OFF.

FUNCTION MATH_EjAng {
	LOCAL fActPhase TO MATH_PhaseAng().	// Current Phase Angle
	LOCAL T2 IS TARGET:OBT:PERIOD.
	LOCAL A2 IS TARGET:OBT:SEMIMAJORAXIS.
	LOCAL A1 IS BODY:RADIUS + (SHIP:ALTITUDE + TARGET:ALTITUDE)/2.
	LOCAL T1 IS T2 * (A1/A2)^(2/3).
	LOCAL Alpha IS ((T1*0.50)/T2)*360.
	SET fTgPhase TO 360 - Alpha.
	SET fPhaseETA TO (MATH_AngNorm(fTgPhase-fActPhase) / MATH_AngSpeed(SHIP:OBT:PERIOD)).
	SET fTrsDV TO MAN_DV(SHIP:APOAPSIS,TARGET:OBT:APOAPSIS).
	SET fBurnTime TO MAN_BTime(MAN_ISP(),fTrsDV).
	RETURN list(fTgPhase,fPhaseETA,fTrsDV,fBurnTime).
}

//Maneuver Planning
SET mode TO 1.
SET tStartVel TO 0.
SET tSpacer TO "              ".
UNTIL mode = 0 {
	IF mode = 1 { // CALCULATION FOR MUN TRANSFER
		IF (WARP > 0) {SET WARP TO 0.}
		SET tEjData TO MATH_EjAng().
		SET tManArg TO tEjData[0].
		SET tManETA TO tEjData[1].
		SET tManDV TO tEjData[2].
		SET tManDur TO tEjData[3].
		SET tManTime TO TIME:SECONDS+tManETA-(tManDur*0.50).
		SET Mode TO 2.
	} ELSE IF (mode = 2) {
		kuniverse:timewarp:warpto(tManTime-40).
		IF (TIME:SECONDS-tManTime <= 30) {
			SET mode TO 3.
			LOCK SVAL TO PROGRADE.
		}
	} ELSE IF (mode = 3) { // SCRIPT END, RELEASE CONTROLS
		IF (TIME:SECONDS-tManTime <= 0 AND THROTTLE = 0) {SET TVAL TO 1.}
		ELSE IF (SHIP:OBT:HASNEXTPATCH) {
			SET tBTime TO TIME:SECONDS+(ETA:TRANSITION*0.25).
			LOCK TempTime TO tBTime-TIME:SECONDS.
			SET TVAL TO 0.
			SET mode TO 20.
		}
	} ELSE IF (mode = 20) { // SCRIPT END, RELEASE CONTROLS
		SET TVAL TO 0.
		UNLOCK STEERING.
		UNLOCK THROTTLE.
		SET mode to 0.
		PRINT "Deorbit and Land Complete"+tSpacer AT (3,9).
		WAIT 100.
	}

	IF (THROTTLE > 0) {PRINT "#>> BURNING AT "+ROUND(THROTTLE*100,0)+"% <<#"+tSpacer AT (3,0).}
	ELSE IF (WARP > 0) {PRINT "#>> WARPING AT "+WARP+" <<#"+tSpacer AT (3,0).}
	ELSE {PRINT tSpacer+tSpacer AT (3,0).}
	PRINT "Scola-Sys - Mun Transfer (RM:"+mode+") "+SHIP:STATUS+tSpacer AT (3,2).
	PRINT "Man-Arg: "+ROUND(tManArg,2)+" ("+ROUND(MATH_PhaseAng(),2)+")"+tSpacer AT (3,3).
	PRINT "Man-ETA: "+ROUND(tManTime-TIME:SECONDS,2)+tSpacer AT (3,4).
	PRINT "Man-DeV: "+ROUND(tManDV,2)+tSpacer AT (3,5).
	PRINT "Man-Dur: "+ROUND(tManDur,2)+tSpacer AT (3,6).
}
