PRINT "Scola-Sys -> Mission... LOADED".

IF (ADDONS:RT:HASCONNECTION(SHIP) OR SHIP:STATUS = "PREFLIGHT" OR gDebug) {
	IF (HAS_FILE("Ts.Intercept.ks",1)) {DELETEPATH("1:/Ts.Intercept.ks").}
	fDownLib("LibGens.ks",TRUE).
	fDownLib("LibMan.ks",TRUE).
	fDownload("Ts.Asc.Rck.ks").
	fDownload("Sc.Circ.ks").
	fDownload("Ts.Intercept.ks").
}
SET LASTUPD TO 0.
LOG "Alt,ApH,PeH,THR,TWR" TO FlyLog.csv.
FUNCTION fMissStage {
	IF (TIME:SECONDS >= LASTUPD) {
		LOG ROUND(SHIP:ALTITUDE,2)+","+round(APOAPSIS, 1)+","+round(PERIAPSIS, 1)+","+ROUND(THROTTLE,5)+","+ROUND(fTWR(),5) TO FlyLog.csv.
		SET LASTUPD TO TIME:SECONDS+1.
	}
	IF (SHIP:ALTITUDE >= 69000 AND STAGE:NUMBER <= 1) {
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
	RUNPATH("Ts.Asc.Rck.ks",200000).
}
IF (SHIP:STATUS = "SUB_ORBITAL") {
//	RUNPATH("Sc.Circ.ks",85000).
	COPYPATH("FlyLog.csv","0:/").
	CLEARSCREEN.
	PRINT "LOG File Uploaded!".
	UNTIL VERTICALSPEED < 0 {SET STEERING TO UP.}
	LOCk STEERING TO RETROGRADE.
	WAIT UNTIL SHIP:ALTITUDE < 80000.
}