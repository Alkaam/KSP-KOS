PRINT "Scola-Sys -> Mission... LOADED".

IF (ADDONS:RT:HASCONNECTION(SHIP) OR SHIP:STATUS = "PRELAUNCH" OR gDebug) {
	fDownLib("LibGens.ks",TRUE).
	fDownLib("LibMan.ks",TRUE).
	fDownload("Sc.Asc.Rck.ks").
}

FUNCTION fMissStage {
	IF (SHIP:ALTITUDE >= 68000 AND STAGE:NUMBER > 0) {
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

IF (SHIP:STATUS = "PRELAUNCH") {
	RUNPATH("Sc.Asc.Rck.ks",85000).
}