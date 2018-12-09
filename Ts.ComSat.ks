PARAMETER gOrbit IS 2863330.
PARAMETER gSatNum IS 0. //the Number of the Satellite like in a row of 6 satellite, this is the 3
PARAMETER gSatTot IS 1. //total number of satellite to calculate angle separation.
PARAMETER gTgName IS "NONE".

RCS OFF.
SAS OFF.
SET TVAL TO 0.
SET SVAL TO PROGRADE.
LOCK THROTTLE TO TVAL.
LOCK STEERING TO SVAL.

SET mode TO 0.
// Calculate Ejection Burn Angle.
IF (gTgName = "NONE" AND gSatTot <= 1) {
} ELSE {
	SET TARGET TO gTgName.				// Target the Mun.
	SET gActPhase TO MATH_PhaseAng().	// Current Phase Angle
}
LOCAL T2 IS MUN:OBT:PERIOD.
LOCAL A2 IS MUN:OBT:SEMIMAJORAXIS.
LOCAL A1 IS KERBIN:RADIUS + (SHIP:ALTITUDE + MUN:ALTITUDE)/2.
LOCAL T1 IS T2 * (A1/A2)^(2/3).
LOCAL Alpha IS ((T1*0.50)/T2)*360.
SET gTgPhase TO 360 - Alpha.
