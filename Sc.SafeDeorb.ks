// Circularization Script
// If no Argument supplied will automatically circularize at Closest Apsis

// ###### CHECK ATMOSPHERE ######
SET gAtm TO BODY:ATM:EXISTS.
SET gAtmH TO BODY:ATM:HEIGHT.

// ###### SET UP VESSEL ######
SAS OFF.
RCS OFF.
CLEARSCREEN.
LOCK RALT TO ALT:RADAR.
SET tSpacer TO "                    ".
UNTIL RALT < 500 {
	IF (RALT >= 60000) {PANELS ON.} ELSE {PANELS OFF.}
	IF (RALT >= 32500) {SET STEERING TO RETROGRADE.} ELSE {SET STEERING TO SRFRETROGRADE.}
	PRINT "Scola-Sys - Deorbit "+SHIP:STATUS+tSpacer AT (3,2).
	PRINT "ApH: " + ROUND(APOAPSIS/1000, 1) + " km"+tSpacer AT (3,5).
	PRINT "PeH: " + ROUND(PERIAPSIS/1000, 1) + " km"+tSpacer AT (18,5).
	PRINT "ApE: " + ROUND(ETA:APOAPSIS,0) + " s"+tSpacer AT (3,6).
	PRINT "PeE: " + ROUND(ETA:PERIAPSIS,0) + " s"+tSpacer AT (18,6).
	PRINT "VSI: " + ROUND(VERTICALSPEED,2) + " m/s"+tSpacer AT (3,7).
	PRINT "HSI: " + ROUND(GROUNDSPEED,2)+" m/s"+tSpacer AT (18,7).
	PRINT "ALT: " + ROUND(ALT:RADAR,0)+" m"+tSpacer AT (3,8).
}