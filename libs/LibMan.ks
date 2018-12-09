FUNCTION MAN_ISP { //calculates the average isp of all of the active engines on the ship
    LOCAL engineList IS LIST().
    LOCAL totalFlow IS 0.
    LOCAL totalThrust IS 0.
    LIST ENGINES IN engineList.
    FOR engine IN engineList {
        IF engine:IGNITION AND NOT engine:FLAMEOUT {
            SET totalFlow TO totalFlow + (engine:AVAILABLETHRUST / engine:ISP).
            SET totalThrust TO totalThrust + engine:AVAILABLETHRUST.
        }
    }
    IF totalThrust = 0 {
        RETURN 1.
    }
    RETURN (totalThrust / totalFlow).
}

FUNCTION MAN_OrbT {
	PARAMETER SMA.
	LOCAL tPi IS CONSTANT:PI.
	LOCAL u IS SHIP:OBT:BODY:MU.
	RETURN 2*tPi*SQRT((SMA^3)/u).
}

FUNCTION MAN_BTime {    //from isp and dv calculates the amount of time needed for the burn
    PARAMETER ISPs, DV. 
    LOCAL wMass IS SHIP:MASS.
    LOCAL dMass IS wMass / (CONSTANT:E^ (DV / (ISPs * 9.80665))).
    LOCAL flowRate IS SHIP:AVAILABLETHRUST / (ISPs * 9.80665).
    RETURN (wMass - dMass) / flowRate.
}

FUNCTION MAN_OrbV {
	PARAMETER fApH, fPeH.
	SET u TO SHIP:OBT:BODY:MU.
	SET Rad TO SHIP:OBT:BODY:RADIUS+fApH.
	SET SMA TO (fApH+fPeH+(SHIP:OBT:BODY:RADIUS*2))/2.
	RETURN SQRT(u*(2/Rad - 1/SMA)).
}

FUNCTION MAN_DV {
	PARAMETER fDestAP.
	PARAMETER fDestPE.
	PARAMETER fActAP IS 0.
	PARAMETER fActPE IS 0.
	SET V1 TO MAN_OrbV(fDestAP,fDestPE).
	if (fActAP > 0 AND fActPE > 0) {
		SET V2 TO MAN_OrbV(fActAP,fActPE).
	} ELSE {
		SET V2 TO MAN_OrbV(SHIP:APOAPSIS,SHIP:PERIAPSIS).
	}
	RETURN V1-V2.
}

// Delta v requirements for Hohmann Transfer
FUNCTION MNV_HOHMANN_DV {
  PARAMETER desiredAltitude.

  SET u  TO SHIP:OBT:BODY:MU.
  SET r1 TO SHIP:OBT:SEMIMAJORAXIS.
  SET r2 TO desiredAltitude + SHIP:OBT:BODY:RADIUS.

  // v1
  SET v1 TO SQRT(u / r1) * (SQRT((2 * r2) / (r1 + r2)) - 1).

  // v2
  SET v2 TO SQRT(u / r2) * (1 - SQRT((2 * r1) / (r1 + r2))).

  RETURN LIST(v1, v2).
}

// Execute the next node
FUNCTION MAN_ExeNode {
	CLEARSCREEN.
	LOCAL tNode TO NEXTNODE.
	LOCAL tBurnETA TO tNode:ETA.
	LOCAL tBurnDeV TO tNode:DELTAV:MAG.
	LOCAL tBurnDur TO MAN_BTime(MAN_ISP(),tBurnDeV).
	LOCAL tBurnVec TO tNode:DELTAV.
	LOCAL tBurnPrd TO tNode:OBT:PERIOD.
	LOCAL tBurn TO 1.
	SAS OFF.
	RCS ON.
	SET TVAL TO 0.
	LOCK THROTTLE TO TVAL.
	SET SVAL TO tBurnVec.
	LOCK STEERING TO SVAL.
	LOCAL tSpacer TO "              ".
	UNTIL tBurn = 0 {
		SET tBurnETA TO tNode:ETA.
		IF (THROTTLE > 0) {PRINT "#>> BURNING AT "+ROUND(THROTTLE*100,0)+"% <<#"+tSpacer AT (3,0).}
		ELSE {PRINT tSpacer+tSpacer AT (3,0).}
		PRINT "Scola-Sys - Node Execution (RM:"+tBurn+")"+tSpacer AT (3,2).
		print "ApH: " + ROUND(apoapsis/1000, 1) + " km"+tSpacer AT (3,4).
		print "PeH: " + ROUND(periapsis/1000, 1) + " km"+tSpacer AT (18,4).
		print "ApE: " + ROUND(ETA:apoapsis,0) + " s"+tSpacer AT (3,5).
		print "PeE: " + ROUND(ETA:periapsis,0) + " s"+tSpacer AT (18,5).
		PRINT "BrE: " + ROUND(tBurnETA-(tBurnDur*0.50),1) + " s" +tSpacer AT (3,7).
		PRINT "DeV: " + ROUND(tBurnDeV,1) + " m/s" +tSpacer AT (18,7).
		IF (tBurn = 1 AND tBurnETA-(tBurnDur*0.50) <=0) {SET tBurn TO 2.}
		ELSE IF (tBurn = 2) {
			IF (tBurnPrd*0.99 <= SHIP:OBT:PERIOD AND SHIP:OBT:PERIOD <= tBurnPrd*1.01) {SET TVAL TO 0. SET tBurn TO 3. PRINT "B1S".}
			ELSE IF (tNode:DELTAV:MAG <= 0.10) {SET TVAL TO 0. SET tBurn TO 3. PRINT "B2S".}
			ELSE IF (tNode:DELTAV:MAG <= tBurnDeV*0.10) {SET TVAL TO MAX(0.01,tNode:DELTAV:MAG/(tBurnDeV*0.10)).}
			ELSE {SET TVAL TO 1.}
			SET tBurnPrd TO tNode:DELTAV:MAG.
		} ELSE IF (tBurn = 3) {
			PRINT "<< NODE EXECUTION TERMINATED >>"+tSpacer AT (3,9).
			SET tBurn TO 0.
			REMOVE tNode.
		}
	}
}
