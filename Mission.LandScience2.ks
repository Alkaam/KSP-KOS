fFormat(FALSE).
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
Stage.
RUNPATH("Ts.MunTrs.ks",FALSE).
