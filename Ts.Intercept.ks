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

SET TARGET TO ORBITABLE(gTarget).
if () {}

local A1 is Kerbin:radius + (ship:altitude + Mun:altitude)/2.
local A2 is Mun:obt:semimajoraxis.
local T1 is T2 * (A1/A2)^1.5.
local T2 is Mun:obt:period.
local alpha is mod(180*(T1/T2), 360).

// the angle we are looking for is 180-alpha
// or 360-alpha if you are using angles in range [0..360]
local transferAngle is 360 - alpha.