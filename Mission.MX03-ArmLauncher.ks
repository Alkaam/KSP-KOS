PRINT "Scola-Sys -> Mission... LOADED".

IF (ADDONS:RT:HASCONNECTION(SHIP) OR SHIP:STATUS = "PRELAUNCH" OR gDebug) {
	fDownLib("LibGens.ks",TRUE).
	fDownLib("LibMath.ks",TRUE).
	fDownLib("LibMan.ks",TRUE).
	fDownLib("LibRCS.ks",TRUE).
	fDownload("Sc.Asc.Rck2.ks").
	fDownload("Sc.Circ.ks").
	fDownload("Ts.Docking.ks").
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
	IF (SHIP:PERIAPSIS > -10000 AND STAGE:NUMBER > 1) {
		IF (THROTTLE > 0) { fStaging(). } ELSE { STAGE. }
	}
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
IF (SHIP:STATUS = "ORBITING") {
	RUNPATH("Ts.Docking.ks",400000,"KSS-Saphyra").
}
