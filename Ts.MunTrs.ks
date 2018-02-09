// Deorbit Script to Deorbit Vehicles
//"Ts.MunTrs.ks","Mun",FALSE,1997330,TRUE
PARAMETER gTarget IS FALSE. //set TRUE if you want Try Descent on KSC
PARAMETER gFreeRet IS FALSE. //set TRUE perform Power Descent
PARAMETER gOrbit IS 0. //set TRUE perform Power Descent
// ###### CHECK ATMOSPHERE ######
SET gAtm TO BODY:ATM:EXISTS.
SET gAtmH TO BODY:ATM:HEIGHT.

// ###### SET UP THROTTLE AND STEERING ######
SET TVAL TO 0.
SET SVAL TO RETROGRADE.
LOCK THROTTLE TO TVAL.
LOCK STEERING TO SVAL.
SET T2Node TO 0.

// ###### SET UP VESSEL ######
SAS OFF.
RCS OFF.
LIGHTS OFF.
GEAR OFF.

//Maneuver Planning
SET mode TO 1.
SET TARGET TO gTarget.
IF (gOrbit = 0) {
	IF (TARGET:ATM:HEIGHT > 0) { SET gOrbit TO TARGET:ATM:HEIGHT*1.1. }
	ELSE { SET gOrbit TO TARGET:RADIUS*0.1. }
}
SET gOrbMin TO gOrbit*0.80.
SET gOrbMax TO gOrbit*1.20.
CLEARSCREEN.
SET tStartVel TO 0.
SET tSpacer TO "              ".
UNTIL mode = 0 {
	IF mode = 1 { // CALCULATION FOR MUN TRANSFER
		IF (WARP > 0) {SET WARP TO 0.}
		IF (HASNODE) {REMOVE NEXTNODE.}
		SET gOrbit TO TARGET:OBT:APOAPSIS.
		SET BrAngPhase TO 122.5. //Angular Distance Between My and Tg at the BurnPoint (122.37)
		SET PhaseAngle TO MATH_PhaseAng(). //[0...360].
		SET BrTime TO (MATH_AngNorm(PhaseAngle-BrAngPhase))/((360/SHIP:OBT:PERIOD)-(360/TARGET:OBT:PERIOD)). //Calculate How much time needed to Wait Before the Burn.
		SET T2Node TO TIME:SECONDS + BrTime.
		//SPACER
		SET tDeltaV TO MAN_DV(SHIP:APOAPSIS,gOrbit).
		SET tDeltaV TO 920.
		SET tBTime TO MAN_BTime(MAN_ISP(),tDeltaV).
		SET tT2B TO tBTime*0.50.
		//SPACER
		LOCK TempTime TO -1*(TIME:SECONDS-T2Node-tT2B).
		SET tStartVel TO VELOCITY:ORBIT:MAG.
		SET Mode TO 2.
	} ELSE IF (mode = 2) {
		fWarp(TempTime).
		IF (TempTime <= 30) {
			SET mode TO 3.
			LOCK SVAL TO PROGRADE.
		}
	} ELSE IF (mode = 3) { // SCRIPT END, RELEASE CONTROLS
		IF (TempTime <= 0 AND THROTTLE = 0) {SET TVAL TO 1.}
		ELSE IF (SHIP:OBT:HASNEXTPATCH AND SHIP:OBT:NEXTPATCH:PERIAPSIS < -50000) {
			SET tBTime TO TIME:SECONDS+(ETA:TRANSITION*0.25).
			LOCK TempTime TO tBTime-TIME:SECONDS.
			SET TVAL TO 0.
			SET mode TO 4.
		}
	} ELSE IF (mode = 4) { // SCRIPT END, RELEASE CONTROLS
		IF (TempTime <= 0 AND THROTTLE = 0) {SET TVAL TO 1.}
		IF (SHIP:OBT:NEXTPATCH:BODY:NAME = gTarget) {
			IF (SHIP:OBT:NEXTPATCH:PERIAPSIS < gOrbMin) {
				SET TVAL TO MAX(0.02,MIN(0.30,1-(SHIP:OBT:NEXTPATCH:PERIAPSIS/gOrbMin))).
			} ELSE { SET TVAL TO 0. SET MODE TO 5.}
		}
	} ELSE IF (mode = 5) { // SCRIPT END, RELEASE CONTROLS
		SET STEERING TO SHIP:FACING.
		fWarp(TempTime).
		IF (TempTime <= 2) {
			SET mode TO 6.
		}
	} ELSE IF (mode = 6) { // SCRIPT END, RELEASE CONTROLS
		IF (SHIP:OBT:NEXTPATCH:BODY:NAME = gTarget) {
			SET tNPe TO SHIP:OBT:NEXTPATCH:PERIAPSIS.
			SET tSec TO 0.
			SET tV TO 0.
			IF (tNPe > gOrbMax) {
				SET STEERING TO RETROGRADE.
				SET tV TO 1-(gOrbMax/tNPe).
			} ELSE IF (tNPe < gOrbMin) {
				SET STEERING TO PROGRADE.
				SET tV TO 1-(tNPe/gOrbMin).
			} ELSE IF (tNPe > gOrbMin AND tNPe <= gOrbMax) { SET TVAL TO 0. SET MODE TO 7.}
			IF (GEN_AngSteer()) {SET tSec TO 1.}
			SET TVAL TO MAX(0.02,MIN(0.30,tV))*tSec.
		}
	} ELSE IF (mode = 7) { // SCRIPT END, RELEASE CONTROLS
		fWarp(ETA:PERIAPSIS).
		IF (ETA:PERIAPSIS <= 30) {
			SET mode TO 8.
			LOCK SVAL TO PROGRADE.
		}
	} ELSE IF (mode = 8) { // SCRIPT END, RELEASE CONTROLS
		IF (SHIP:OBT:BODY:NAME = gTarget AND ETA:PERIAPSIS <= 20) {
			IF (ETA:PERIAPSIS <= 1 AND THROTTLE = 0 AND SHIP:OBT:NEXTPATCH:PERIAPSIS > 45000) {SET TVAL TO 1.}
			IF (SHIP:OBT:NEXTPATCH:PERIAPSIS > 45000 AND THROTTLE > 0) {
				SET TVAL TO MAX(0.02,MIN(1.00,1-(45000/SHIP:OBT:NEXTPATCH:PERIAPSIS))).
			} ELSE IF (SHIP:OBT:NEXTPATCH:PERIAPSIS <= 45000) {
				SET TVAL TO 0.
				WAIT 3.
				SET WARP TO 4.
			}
		} ELSE IF (PERIAPSIS < 50000 AND SHIP:OBT:BODY:NAME = "Kerbin") { SET mode TO 9.}
		SET STEERING TO PROGRADE.
	} ELSE IF (mode = 9) { // SCRIPT END, RELEASE CONTROLS
		fWarp(ETA:PERIAPSIS).
		IF (ALT:RADAR > 32500) { SET STEERING TO RETROGRADE. }
		IF (ALT:RADAR <= 32500) { SET STEERING TO SRFRETROGRADE. }
		IF (ALT:RADAR < 500) { SET mode TO 20. }
		SET PANELS TO ALT:RADAR > 65000.
		SET GEAR TO ALT:RADAR < 1000.
		IF (STAGE:NUMBER = 1 AND ALT:RADAR < 100000) {STAGE.}
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
	PRINT "Scola-Sys - Deorbit (RM:"+mode+") "+SHIP:STATUS+tSpacer AT (3,2).
	PRINT "[Tg:"+gTarget+"]"+tSpacer AT (3,3).
	print "BrA: " + ROUND(BrAngPhase,0) + " deg"+tSpacer AT (3,4).
	IF (mode >= 2 AND mode < 20) {
		PRINT "DeV: "+ROUND(VELOCITY:ORBIT:MAG-tStartVel,1)+"/"+ROUND(tDeltaV*0.95,1)+tSpacer AT (3,5).
	}
	print "DeV: " + ROUND(tDeltaV,1) + " m/s2"+tSpacer AT (3,6).
	print "BrE: " + ROUND(TIME:SECONDS-T2Node-tT2B)+" s"+tSpacer AT (18,6).
	print "NEXT STEP IN: " + ROUND(TempTime,1) + " s"+tSpacer AT (3,8).
}
