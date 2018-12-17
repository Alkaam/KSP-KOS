// Transfer to Mun / Optional DI, FRT
//"Ts.MunTrs.ks",FALSE,5000,0.20.
PARAMETER gOpt IS D. //set P to Prograde,R to Retrograde,D to Direct,F To Free Return
PARAMETER gOrbit IS 30000. //Set Desired PE at Encounter
PARAMETER gPrec IS 0.20. //Set Precition of Peripasis
SET gOperation TO LEXICON("D","Direct Impact","R","Retrograde","P","Prograde").
// ###### SET UP THROTTLE AND STEERING ######
CLEARSCREEN.
SET TARGET TO "MUN".
SET gOrbMin TO MAX(8000,gOrbit*(1-gPrec)).
SET gOrbMax TO gOrbit*(1+gPrec).
SET T2Node TO 0.
SET TVAL TO 0.
SET SVAL TO PROGRADE.
LOCK THROTTLE TO TVAL.
LOCK STEERING TO SVAL.
SET ModeName TO list("---","Tranfer Complete","Calculation","Rising AP","Rising AP","Adjusting PE","Adjusting PE").
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
SET mode TO 2.
SET tStartVel TO 0.
SET tSpacer TO "              ".
UNTIL mode = 0 {
	IF mode = 2 { // CALCULATION FOR MUN TRANSFER
		IF (WARP > 0) {SET WARP TO 0.}
		SET tEjData TO MATH_EjAng().
		SET tManArg TO tEjData[0].
		SET tManETA TO tEjData[1].
		SET tManDV TO tEjData[2].
		SET tManDur TO tEjData[3].
		SET tManTime TO TIME:SECONDS+tManETA-(tManDur*0.50).
		SET Mode TO 3.
	} ELSE IF (mode = 3) {
		IF (WARP = 0 AND tManTime-TIME:SECONDS > 150) {
			kuniverse:timewarp:warpto(tManTime-40).
		}
		IF (tManTime-TIME:SECONDS <= 30) {
			SET tTgSpeed TO VELOCITY:ORBIT:MAG+tManDV.
			LOCK SVAL TO PROGRADE.
			IF (gOpt = "D" OR gOpt = "R") {SET mode TO 4.}
			ELSE IF (gOpt = "P") {SET mode TO 5.}
		}
	} ELSE IF (mode = 4) { // Transmunar Injection Burn
		IF (tManTime-TIME:SECONDS <= 0 AND THROTTLE = 0) {SET TVAL TO 1.}
		ELSE IF (SHIP:OBT:HASNEXTPATCH AND VELOCITY:ORBIT:MAG >= tTgSpeed) {
			SET TVAL TO 0.
			IF (gOpt = "R") {
				SET tManTime TO TIME:SECONDS+(ETA:TRANSITION*0.25).
				SET mode TO 6.

			} ELSE {SET mode TO 1.}
		}
	} ELSE IF (mode = 5) { // Prograde
		IF (tManTime-TIME:SECONDS <= 0 AND THROTTLE = 0) {SET TVAL TO 1.}
		ELSE IF (SHIP:OBT:HASNEXTPATCH) {
			SET tManTime TO TIME:SECONDS+(ETA:TRANSITION*0.25).
			SET TVAL TO 0.
			SET mode TO 7.
		}
	} ELSE IF (mode = 6) { // Adjust
		IF (WARP = 0 AND tManTime-TIME:SECONDS > 150) {
			kuniverse:timewarp:warpto(tManTime-40).
		} ELSE IF (WARP = 0 AND tManTime-TIME:SECONDS <= 0) {
			SET tNpValPe TO SHIP:OBT:NEXTPATCH:PERIAPSIS.
			SET tNpValIn TO SHIP:OBT:NEXTPATCH:INCLINATION.
			SET tNpPe TO (tNpValPe > gOrbMin AND tNpValPe < gOrbMax).
			SET tNpIn TO (tNpValIn < 220 AND tNpValIn > 140).
			IF (GEN_AngSteer() = FALSE) {
				SET TVAL TO 0.
			} ELSE IF (tNpIn AND tNpPe) {
				SET TVAL TO 0.
				SET mode TO 1.
			} ELSE IF (tNpIn) {
				IF (tNpValPe > gOrbMax) {
					SET TVAL TO 0.3*MIN(1.0,ABS(1-(tNpValPe/gOrbit))).
					SET SVAL TO RETROGRADE.
				} ELSE IF (tNpValPe < gOrbMin) {
					SET TVAL TO 0.3*MIN(1.0,ABS(1-(tNpValPe/gOrbit))).
					SET SVAL TO PROGRADE.
				}
			}
		}
	} ELSE IF (mode = 7) { // Adjust
		IF (WARP = 0 AND tManTime-TIME:SECONDS > 150) {
			kuniverse:timewarp:warpto(tManTime-40).
		} ELSE IF (WARP = 0 AND tManTime-TIME:SECONDS <= 0) {
			SET tNpValPe TO SHIP:OBT:NEXTPATCH:PERIAPSIS.
			SET tNpValIn TO SHIP:OBT:NEXTPATCH:INCLINATION.
			SET tNpPe TO (tNpValPe > gOrbMin AND tNpValPe < gOrbMax).
			SET tNpIn TO (tNpValIn > 350 OR tNpValIn < 10).
			IF (GEN_AngSteer() = FALSE) {
				SET TVAL TO 0.
			} ELSE IF (tNpIn AND tNpPe) {
				SET TVAL TO 0.
				SET mode TO 1.
			} ELSE IF (tNpIn) {
				IF (tNpValPe > gOrbMax) {
					SET TVAL TO 0.3*MIN(1.0,ABS(1-(tNpValPe/gOrbit))).
					SET SVAL TO PROGRADE.
				} ELSE IF (tNpValPe < gOrbMin) {
					SET TVAL TO 0.3*MIN(1.0,ABS(1-(tNpValPe/gOrbit))).
					SET SVAL TO RETROGRADE.
				}
			}
		}
	} ELSE IF (mode = 1) { // SCRIPT END, RELEASE CONTROLS
		CLEARSCREEN.
		SET TVAL TO 0.
		UNLOCK STEERING.
		UNLOCK THROTTLE.
		SET mode to 0.
		PRINT "Deorbit and Land Complete"+tSpacer AT (3,15).
		WAIT 100.
	}

	IF (THROTTLE > 0) {PRINT "#>> BURNING AT "+ROUND(THROTTLE*100,0)+"% <<#"+tSpacer AT (3,0).}
	ELSE IF (WARP > 0) {PRINT "#>> WARPING AT "+WARP+" <<#"+tSpacer AT (3,0).}
	ELSE {PRINT tSpacer+tSpacer AT (3,0).}
	PRINT "Scola-Sys - Mun Transfer ("+ModeName[mode]+")"+tSpacer AT (3,2).
	PRINT "Type Orbit   : "+gOperation[gOpt]+tSpacer AT (3,4).
	PRINT "Target Orbit : "+ROUND(gOrbit/1000,0)+" Km"+tSpacer AT (3,5).
	PRINT "Precision    : "+ROUND(gPrec*100,2)+" %"+tSpacer AT (3,6).
	IF (mode = 4 OR mode = 5) {
		PRINT "### Transmunar Injection Burn ###"+tSpacer AT (3,8).
		PRINT "Argument: "+ROUND(tManArg,0)+" ("+ROUND(MATH_PhaseAng(),0)+")"+tSpacer AT (3,9).
		PRINT "ETA: "+ROUND(tManTime-TIME:SECONDS,0)+"s DeV: "+ROUND(tManDV,2)+"m/s ("+ROUND(tManDur,2)+"s)"+tSpacer AT (3,10).
	} ELSE IF (mode = 6 OR mode = 7) {
		PRINT "### Orbit Tuning Burn ###"+tSpacer AT (3,8).
		PRINT "NxP-PE :"+ROUND(SHIP:OBT:NEXTPATCH:PERIAPSIS/1000,2)+"Km"+tSpacer AT (3,9).
		PRINT "NxP-In :"+ROUND(SHIP:OBT:NEXTPATCH:INCLINATION,2)+"°"+tSpacer AT (3,10).
	}
}
