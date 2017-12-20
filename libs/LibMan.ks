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
FUNCTION MNV_EXEC_NODE {
  PARAMETER autoWarp.

  LOCAL n IS NEXTNODE.
  LOCAL v IS n:BURNVECTOR.

  LOCAL startTime IS TIME:SECONDS + n:ETA - MNV_TIME(v:MAG)/2.
  LOCK STEERING TO n:BURNVECTOR.

  IF autoWarp { WARPTO(startTime - 30). }

  WAIT UNTIL TIME:SECONDS >= startTime.
  LOCK THROTTLE TO MIN(MNV_TIME(n:BURNVECTOR:MAG), 1).
  WAIT UNTIL VDOT(n:BURNVECTOR, v) < 0.
  LOCK THROTTLE TO 0.
  UNLOCK STEERING.
}