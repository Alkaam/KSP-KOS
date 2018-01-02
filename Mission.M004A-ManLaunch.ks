PRINT "Scola-Sys -> Mission... LOADED".

IF (ADDONS:RT:HASCONNECTION(SHIP) OR SHIP:STATUS = "PRELAUNCH" OR gDebug) {
	IF (HAS_FILE("Ts.KSC-Deorb.ks",1)) {DELETEPATH("1:/Ts.KSC-Deorb.ks").}
	fDownLib("LibGens.ks",TRUE).
	fDownLib("LibMan.ks",TRUE).
	fDownload("Sc.Asc.Rck.ks").
	fDownload("Sc.Circ.ks").
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

IF (SHIP:STATUS = "PRELAUNCH") {
	RUNPATH("Sc.Asc.Rck.ks",85000).
}
IF (SHIP:STATUS = "SUB_ORBITAL") {
	RUNPATH("Sc.Circ.ks",85000).
}
IF (SHIP:STATUS = "ORBITING") {
	RUNPATH("Ts.KSC-Deorb.ks",TRUE,TRUE).
}