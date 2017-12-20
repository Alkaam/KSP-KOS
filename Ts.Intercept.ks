//Intercept Script, can be Used to Intercept another Vehicle
// or to set up an equidistant satellite network.

PARAMETER gTarget.
PARAMETER gSatNum IS 0. //the Number of the Satellite like in a row of 6 satellite, this is the 3
PARAMETER gSatTot IS 0. //total number of satellite to calculate angle separation.
PARAMETER gKSCSync IS FALSE. //set true to have this satellite sit above KSC

FUNCTION TARGET_ANGLE {
  PARAMETER target.
  RETURN MOD(LNG_TO_DEGREES(ORBITABLE(target):LONGITUDE),- LNG_TO_DEGREES(SHIP:LONGITUDE) + 360,360).
}

//Maneuver Planning

SET TARGET TO gTarget.

//TODO: Add Satellite Network Positioning, can just do Beta = (360/gSatTot)*gSatNum
//TODO: Add Satellite Virtual Position, to fine tune the orbit (Similar to Docking)
LOCAL A1 IS BODY:RADIUS + (SHIP:ALTITUDE + TARGET:ALTITUDE)/2.
LOCAL A2 IS TARGET:OBT:SEMIMAJORAXIS.
LOCAL T1 IS T2 * (A1/A2)^1.5.
LOCAL T2 IS TARGET:OBT:PERIOD.
LOCAL alpha IS MOD(180*(T1/T2), 360).
LOCAL transferAngle IS 360-alpha.
