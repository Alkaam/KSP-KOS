PRINT "Scola-Sys -> Mission... LOADED".

IF (ADDONS:RT:HASCONNECTION(SHIP) OR SHIP:STATUS = "PRELAUNCH" OR gDebug) {
	fDownLib("LibGens.ks",TRUE).
	fDownLib("LibMan.ks",TRUE).
	fDownload("Sc.SafeDeorb.ks").
	fDownload("Sc.Asc.Rck3.ks").
	fDownload("Sc.Circ.ks").
	fDownload("Ts.KSC-Deorb.ks").
}

FUNCTION fStaging {
	LOCK THROTTLE TO 0.
	WAIT 1.
	STAGE.
	WAIT 2.
	LOCK THROTTLE TO TVAL.
}

FUNCTION fMissStage {
	IF (STAGE:NUMBER > 1 AND PERIAPSIS >= -25000) {fStaging().}
	IF (SHIP:ALTITUDE >= 69000 AND STAGE:NUMBER >= 1) {
		PANELS ON.     //DEPLOY SOLAR PANELS
		LIGHTS ON.
		AG10 ON.
	}
}

IF (SHIP:STATUS = "PRELAUNCH") {
	RUNPATH("Sc.Asc.Rck3.ks",300000,1,-6).
}
IF (SHIP:STATUS = "SUB_ORBITAL") {
	RUNPATH("Sc.Circ.ks",300000).
}
RUNPATH("Sc.SafeDeorb.ks").
