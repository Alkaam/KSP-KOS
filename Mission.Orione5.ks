PRINT "Scola-Sys -> Mission... LOADED".
fDownLib("LibGens.ks",TRUE).
fDownLib("LibMan.ks",TRUE).
fDownload("Sc.Asc.Rck3.ks").
fDownload("Sc.Circ.ks").
fDownload("Sc.SafeDeorb.ks").

PRINT "Scola-Sys -> System Ready.".

FUNCTION fStaging {
	LOCK THROTTLE TO 0.
	WAIT 1.
	STAGE.
	WAIT 2.
	LOCK THROTTLE TO TVAL.
}
FUNCTION fMissStage {
	IF (SHIP:ALTITUDE >= 60000 AND STAGE:NUMBER = 3) {
		STAGE.
		Wait 1.
	}
	ELSE IF (SHIP:PERIAPSIS >= 25000 AND STAGE:NUMBER = 2) {
		fStaging().
	}
}
	WHEN SHIP:ALTITUDE >= 60000 THEN {
		PANELS ON.     //DEPLOY SOLAR PANELS
		LIGHTS ON.
		AG10 ON.
	}

IF (SHIP:STATUS = "PRELAUNCH") {
	RUNPATH("Sc.Asc.Rck3.ks",110000,0,90).
	RUNPATH("Sc.Circ.ks",110000).
}
IF (SHIP:STATUS = "ORBITING") {
	WAIT UNTIL ALTITUDE < 60000.
	RUNPATH("Sc.SafeDeorb.ks").
}
