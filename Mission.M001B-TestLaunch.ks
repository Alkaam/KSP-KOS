PRINT "Scola-Sys -> Mission... LOADED".

IF (ADDONS:RT:HASCONNECTION(SHIP) OR SHIP:STATUS = "PREFLIGHT" OR gDebug) {
	fDownLib("LibGens.ks",TRUE).
	fDownLib("LibMan.ks",TRUE).
	fDownload("Sc.Asc.Rck2.ks").
	fDownload("Sc.Circ.ks").
	fDownload("Ts.MunTrs.ks").
	fDownload("Sc.Intercept.ks").
}

FUNCTION fMissStage {
	IF (PERIAPSIS > -10000 AND STAGE:NUMBER > 1) {
		fStaging().
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
	RUNPATH("Sc.Asc.Rck2.ks",85000).
}
IF (SHIP:STATUS = "SUB_ORBITAL") {
	RUNPATH("Sc.Circ.ks",85000).
}
IF (SHIP:STATUS = "ORBITING") {
	RUNPATH("Ts.MunTrs.ks","Mun",FALSE,1997330).
	RUNPATH("Sc.Intercept.ks",1997330,"NONE",0,0,TRUE).
}