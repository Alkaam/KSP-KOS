PRINT "Scola-Sys -> Mission... LOADED".
fDownLib("LibGens.ks",TRUE).
fDownLib("LibMan.ks",TRUE).
fDownload("Sc.Asc.Rck2.ks").
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
	IF (SHIP:ALTITUDE >= 69000 AND STAGE:NUMBER > 1) {
		PANELS ON.     //DEPLOY SOLAR PANELS
		LIGHTS ON.
		AG10 ON.
	}
}

IF (SHIP:STATUS = "PRELAUNCH") {
	RUNPATH("Sc.Asc.Rck2.ks",85000).
	RUNPATH("Sc.Circ.ks",85000).
}