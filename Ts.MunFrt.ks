CLEARSCREEN.
PARAMETER gTgPe IS 35000.
PARAMETER gAerobrake IS 40000.
PRINT "Mun-Trs -> Calculation".
SET TARGET TO "Mun".				// Target the Mun.
SET mode TO 0.
SET gActPhase TO MATH_PhaseAng().	// Current Phase Angle
// Calculate Ejection Burn Angle.
LOCAL T2 IS MUN:OBT:PERIOD.
LOCAL A2 IS MUN:OBT:SEMIMAJORAXIS.
LOCAL A1 IS KERBIN:RADIUS + (SHIP:ALTITUDE + MUN:ALTITUDE)/2.
LOCAL T1 IS T2 * (A1/A2)^(2/3).
LOCAL Alpha IS ((T1*0.50)/T2)*360.
SET gTgPhase TO 360 - Alpha.
// Calculate Ejection Burn Time.
SET gPhaseETA TO (MATH_AngNorm(gTgPhase-gActPhase) / MATH_AngSpeed(SHIP:OBT:PERIOD)).
// Calculate Ejection Burn Duration.
SET gTrsDV TO MAN_DV(SHIP:APOAPSIS,MUN:OBT:APOAPSIS).

PRINT "Mun-Trs -> Creating Node".
SET gMunTrs to NODE( ROUND(TIME:SECONDS+gPhaseETA,1), 0, 0, ROUND(gTrsDV,1)).
ADD gMunTrs.

PRINT "Mun-Trs -> Adjusting Node".
SET Adjust TO 1.
SET tN TO 0.
UNTIL Adjust = 0 {
	SET tInc TO MAX(MIN((gTgPe-gMunTrs:OBT:NEXTPATCH:PERIAPSIS)/gTgPe,1),-1)*0.10.
	PRINT "Inc: " + tInc + "                 " AT (3,7).
	IF (Adjust = 1 AND gMunTrs:OBT:HASNEXTPATCH) {
		SET tN TO tN+1.
		SET gMunTrs:PROGRADE TO gMunTrs:PROGRADE+tInc. WAIT 0.1.
		IF ((gTgPe*0.90) < gMunTrs:OBT:NEXTPATCH:PERIAPSIS AND gMunTrs:OBT:NEXTPATCH:PERIAPSIS < (gTgPe*1.10)) { SET tN TO -1000. SET Adjust to 2.}
		ELSE IF (tN >= 50) {SET tN TO 0. SET Adjust TO 2.}
	} ELSE IF (Adjust = 2 AND gMunTrs:OBT:HASNEXTPATCH) {
		SET tN TO tN+1.
		SET gMunTrs:ETA TO gMunTrs:ETA+tInc. WAIT 0.01.
		IF ((gTgPe*0.99) < gMunTrs:OBT:NEXTPATCH:PERIAPSIS AND gMunTrs:OBT:NEXTPATCH:PERIAPSIS < (gTgPe*1.01)) {SET Adjust to 3.}
		ELSE IF (tN >= 10) {SET tN TO 0. SET Adjust TO 1.}
	} ELSE IF (Adjust = 3) {PRINT "Mun-Trs -> Complete!". SET Adjust TO 0.}
	IF (gMunTrs:DELTAV:MAG >= 950) {PRINT "Mun-Trs -> Overshoot!". REMOVE gMunTrs. SET Adjust TO 1. WAIT 5.}
}
MAN_ExeNode().
WAIT UNTIL ETA:PERIAPSIS < 180.
SET gKerTrs to NODE( ETA:PERIAPSIS, 0, 0, 0).
ADD gKerTrs.
SET Adjust TO 1.
SET Adjust TO 1.
UNTIL Adjust = 0 {
	SET tInc TO MAX(MIN((gAerobrake-gKerTrs:OBT:NEXTPATCH:PERIAPSIS)/gAerobrake,1),-1)*0.10.
	PRINT "Inc: " + tInc + "                 " AT (3,7).
	IF (Adjust = 1 AND gKerTrs:OBT:HASNEXTPATCH) {
		SET gKerTrs:PROGRADE TO gKerTrs:PROGRADE+tInc. WAIT 0.1.
		IF ((gAerobrake*0.99) < gKerTrs:OBT:NEXTPATCH:PERIAPSIS AND gKerTrs:OBT:NEXTPATCH:PERIAPSIS < (gAerobrake*1.01)) { SET tN TO -1000. SET Adjust to 2.}
	} ELSE IF (Adjust = 2) {PRINT "Mun-Trs -> Complete!". SET Adjust TO 0.}
	IF (gKerTrs:DELTAV:MAG >= 950) {PRINT "Mun-Trs -> Overshoot!". REMOVE gKerTrs. SET Adjust TO 1. WAIT 5.}
}
