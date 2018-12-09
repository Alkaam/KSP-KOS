PRINT "Scola-Sys -> Mission... LOADED".
fDownLib("LibGens.ks",TRUE).
fDownLib("LibMan.ks",TRUE).
fDownload("Sc.Asc.Rck3.ks").
fDownload("Sc.Circ.ks").

PRINT "Scola-Sys -> System Ready.".

FUNCTION fStaging {
	LOCK THROTTLE TO 0.
	WAIT 1.
	STAGE.
	WAIT 2.
	LOCK THROTTLE TO TVAL.
}
FUNCTION fMissStage {
	IF (SHIP:ALTITUDE >= 60000 AND STAGE:NUMBER = 2) {
		STAGE.
		Wait 1.
		PANELS ON.     //DEPLOY SOLAR PANELS
		LIGHTS ON.
		AG10 ON.
	}
	ELSE IF (SHIP:PERIAPSIS >= 25000 AND STAGE:NUMBER = 1) {
		fStaging().
	}
}
IF (SHIP:STATUS = "PRELAUNCH") {
	RUNPATH("Sc.Asc.Rck3.ks",85000).
}
IF (SHIP:STATUS = "SUB_ORBITAL") {
	RUNPATH("Sc.Circ.ks",85000).
}