PRINT "Scola-Sys -> Mission... LOADED".
fDownLib("LibGens.ks",TRUE).
fDownLib("LibMan.ks",TRUE).
fDownload("Ts.PowerLand.ks").
PRINT "Scola-Sys -> System Ready.".

FUNCTION fStaging {
	LOCK THROTTLE TO 0.
	WAIT 1.
	STAGE.
	WAIT 2.
	LOCK THROTTLE TO TVAL.
}

WAIT 1.0.
SET tHdg TO 116.8.
LOCK THROTTLE TO 0.5.
LOCK STEERING TO heading (tHdg, 85).
STAGE.
WAIT 5.
LOCK STEERING TO heading (tHdg, 75).
WAIT 5.
LOCK STEERING TO heading (tHdg, 60).
WAIT UNTIL SHIP:APOAPSIS > 23200.
LOCK THROTTLE TO 0.
WAIT UNTIL VERTICALSPEED < 0.
STAGE.
WAIT 2.
RUNPATH("Ts.PowerLand.ks").