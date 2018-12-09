PRINT "Scola-Sys -> Mission... LOADED".

IF (ADDONS:RT:HASCONNECTION(SHIP) OR SHIP:STATUS = "PRELAUNCH" OR gDebug) {
	IF (HAS_FILE("Ts.KSC-Deorb.ks",1)) {DELETEPATH("1:/Ts.KSC-Deorb.ks").}
	fDownLib("LibGens.ks",TRUE).
	fDownLib("LibMan.ks",TRUE).
	fDownload("Ts.KSC-Deorb.ks").
}

FUNCTION fMissStage {
	IF (SHIP:ALTITUDE >= 68000 AND STAGE:NUMBER > 1) {
		STAGE.
	}
	IF (SHIP:ALTITUDE >= 69000 AND STAGE:NUMBER = 0) {
		PANELS ON.     //DEPLOY SOLAR PANELS
		LIGHTS ON.
		AG10 ON.
	}
}
FUNCTION fStaging {
	LOCK THROTTLE TO 0.
	WAIT 1.
	STAGE.
	WAIT 2.
	LOCK THROTTLE TO TVAL.
}
SET tHdg TO 0.
IF (SHIP:STATUS = "PRELAUNCH") {
	LOCK STEERING TO HEADING(tHdg,90).
	SET THROTTLE TO 0.70.
	STAGE.
	WAIT UNTIL ALT:RADAR > 200.
	LOCK STEERING TO HEADING(tHdg,75).
	WAIT UNTIL ALT:RADAR > 500.
	LOCK STEERING TO HEADING(tHdg,55).
	WAIT UNTIL ALT:RADAR > 800.
	LOCK STEERING TO HEADING(tHdg,40).
	WAIT UNTIL ALT:RADAR > 1200.
	SET THROTTLE TO 1.00.
	WAIT UNTIL ALT:RADAR > 20000.
	SET THROTTLE TO 0.
}