PRINT "Scola-Sys -> Mission... LOADED".

fDownLib("LibGens.ks",TRUE).
fDownLib("LibMan.ks",TRUE).
fDownload("Sc.Asc.Rck3.ks").

FUNCTION fMissStage {
	IF (SHIP:ALTITUDE >= 68000 AND STAGE:NUMBER > 2) {
		STAGE.
	}
	IF (SHIP:ALTITUDE >= 69000 AND STAGE:NUMBER = 0) {
		PANELS ON.     //DEPLOY SOLAR PANELS
		LIGHTS ON.
		AG1 ON.
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
	RUNPATH("Sc.Asc.Rck3.ks").
}
IF (SHIP:STATUS = "SUB_ORBITAL") {
	CLEARSCREEN.
}
