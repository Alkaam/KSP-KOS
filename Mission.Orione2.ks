PRINT "Scola-Sys -> Mission... LOADED".
fDownLib("LibGens.ks",TRUE).
fDownLib("LibMan.ks",TRUE).
fDownload("Sc.Asc.Rck2.ks").
fDownload("Sc.Circ.ks").
fDownload("Ts.KSC-Deorb.ks").

PRINT "Scola-Sys -> System Ready.".

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
	RUNPATH("Ts.KSC-Deorb.ks",TRUE).
}