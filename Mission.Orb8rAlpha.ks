PRINT "Scola-Sys -> Mission... LOADED".
fDownLib("LibGens.ks",TRUE).
fDownLib("LibMan.ks",TRUE).
fDownLib("LibMath.ks",TRUE).
fDownload("Ts.MunTrs.ks").

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
		fStaging().
		Wait 1.
	}
	IF (SHIP:ALTITUDE >= 68000 AND STAGE:NUMBER = 2) {
		Stage.
		Wait 1.
	}
	ELSE IF (SHIP:PERIAPSIS >= 25000 AND STAGE:NUMBER = 2) {
		fStaging().
	}
}
	WHEN SHIP:ALTITUDE >= 75000 THEN {
		PANELS ON.     //DEPLOY SOLAR PANELS
		LIGHTS ON.
		AG10 ON.
	}

RUNPATH("Ts.MunTrs.ks",FALSE).
