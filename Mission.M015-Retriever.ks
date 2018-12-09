PRINT "Scola-Sys -> Mission... LOADED".

IF (ADDONS:RT:HASCONNECTION(SHIP) OR SHIP:STATUS = "PRELAUNCH" OR gDebug) {
	if (HAS_FILE("Ts.Docking.ks",1)) {DELETEPATH("1:/Ts.Docking.ks").}
	fDownLib("LibGens.ks",TRUE).
	fDownLib("LibMath.ks",TRUE).
	fDownLib("LibMan.ks",TRUE).
	fDownLib("LibRCS.ks",TRUE).
	fDownload("Sc.Asc.Rck2.ks").
	fDownload("Sc.Circ.ks").
	fDownload("Ts.Docking.ks").
}

FUNCTION fStaging {
	LOCK THROTTLE TO 0.
	WAIT 1.
	STAGE.
	WAIT 2.
	LOCK THROTTLE TO TVAL.
}

FUNCTION fMissStage {
	IF (SHIP:ALTITUDE >= 69000 AND STAGE:NUMBER >= 1) {
		PANELS ON.     //DEPLOY SOLAR PANELS
		LIGHTS ON.
		AG10 ON.
	}
}

IF (SHIP:STATUS = "PRELAUNCH") {
	RUNPATH("Sc.Asc.Rck2.ks",200000).
	RUNPATH("Sc.Circ.ks",200000).
}