PRINT "Scola-Sys -> Mission... LOADED".
fDownLib("LibGens.ks",TRUE).
fDownLib("LibMan.ks",TRUE).
fDownLib("LibMath.ks",TRUE).
fDownload("Sc.Asc.Rck3.ks").
fDownload("Sc.Circ.ks").
fDownload("Ts.MunTrs.ks").
fDownload("Ts.PowerLand.ks").

PRINT "Scola-Sys -> System Ready.".



FUNCTION fStaging {
	LOCK THROTTLE TO 0.
	WAIT 1.
	STAGE.
	WAIT 2.
	LOCK THROTTLE TO TVAL.
}
FUNCTION fMissStage {
	SET K TO FALSE.
}
	WHEN SHIP:ALTITUDE >= 70000 AND STAGE:NUMBER = 2 THEN {
		PANELS ON.     //DEPLOY SOLAR PANELS
		LIGHTS ON.
		AG10 ON.
	}
IF (SHIP:STATUS = "PRELAUNCH") {
	RUNPATH("Sc.Asc.Rck3.ks",90000,0,90).
	RUNPATH("Sc.Circ.ks",90000).
}
RUNPATH("Ts.MunTrs.ks","D").
WAIT UNTIL SHIP:BODY:NAME = "Mun".
RUNPATH("Ts.PowerLand.ks").
