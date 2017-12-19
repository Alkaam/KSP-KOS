// SETUP VEICOLO

set gTgApo to 85000.
set gSwOrbit to 0.
set gSwAscOnly to 0.
set gSwClamps to 0.


SAS off.
RCS off.
lights off.
gear off.
panels off.

SET TVAL TO 0.
lock throttle to TVAL.

SET SVAL TO UP.
lock STEERING to SVAL.

lock gShipPos to SHIP:GEOPOSITION.
lock gSurfEl to gShipPos:TERRAINHEIGHT.
lock gAltRad to max( 0.1, ALTITUDE - gSurfEl).
lock impactTime to betterALTRADAR / -VERTICALSPEED.
set GRAVITY to (constant():G * body:mass) / body:radius^2.
lock TWR to MAX( 0.001, MAXTHRUST / (MASS*GRAVITY)).

// CONTO ALL ROVESCIA

CLEARSCREEN.
PRINT "Counting down:..." at (3,3).
FROM {local countdown is 10.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "Counting down:..." + countdown + "sec      " at (3,3).
    WAIT 1. // pauses the script here for 1 second.
    if (gSwClamps) {
	if (countdown = 3) {set TVAL to MAX(0.50,1.1/TWR).} 
	if (countdown = 2) {stage.} 
    }
}
SET TVAL to 1.
stage.
WAIT UNTIL VERTICALSPEED > 3.
PRINT "LIFT OFF!!!" at (3,4).
WAIT 1.
PRINT "Switch to Ascension Guidance" at (3,5).
WAIT 1.
CLEARSCREEN.

WHEN MAXTHRUST = 0 THEN {
    LOCK THROTTLE to 0.
    PRINT "Staging".
    STAGE.
    LOCK THROTTLE to TVAL.
}.

// ASCESA (LOOP)
SET tTextClear to "                          ".
SET tTextTitle to "*ScolaCorp* Ascension Program v0.12".
SET tTextAct1 to "Clearing Launch Pad.".
SET tTextAct2 to " ".
SET RUNMODE to 1.
UNTIL RUNMODE = 0 {
  set tDApo to gTgApo-SHIP:APOAPSIS.
  IF (RUNMODE = 1) { //   CABRATA E SPINTA
    SET tTBk to 2/TWR.
    SET tPitch to MAX( 5, 90*(1-ALT:RADAR/60000)).
    IF (SHIP:VELOCITY:SURFACE:MAG > 300) {
      SET SVAL to heading( 90, tPitch).
      SET TVAL to tTBk.
      SET tTextAct1 to "Gravity Turn".
    } // Slowly Throttle Back to TWR = 2
    IF (ABS(gTgApo-SHIP:APOAPSIS) < 500) {
      SET RUNMODE to 2.
    } // Slowly start Gravity Turn
  }
  ELSE IF (RUNMODE = 2) { //   SETUP APOASSE
    if (tDApo > 50 and SHIP:APOAPSIS < gTgApo) {
      set tPitch to 0.
      set TVAL to 1.5/TWR.
      SET tTextAct1 to "Closing to AP".
    } else if (tDApo < 50 and SHIP:APOAPSIS < gTgApo) {
      set TVAL to 1.3/TWR.
      SET tTextAct1 to "Tuning AP".
      SET tTextAct2 to " ".
    } else if (SHIP:APOAPSIS > gTgApo and ALTITUDE > 70000) {
      IF (ETA:APOAPSIS > 60) {
        SET SVAL to heading( 90, 0).
        SET tTextAct1 to "SET PITCH to RISE PE".
        SET tTextAct2 to "WAITING to BURN".
      } else if (ETA:APOAPSIS < 60) {
        set TVAL to 1.
        SET tTextAct2 to "BURNING....    ".
        SET RUNMODE to 3.
      }
    } else {
      SET tTextAct1 to "Stand-By".
      SET tTextAct2 to "Stand-By".
      set TVAL to 0.
    }
    SET SVAL to heading( 90, tPitch).
  }
  ELSE IF (RUNMODE = 3) { // USCITA ATMOSFERA
    IF (SHIP:APOAPSIS < gTgApo) {
      set tPitch to 0.
      set TVAL to 1.1/TWR.
      SET tTextAct1 to "Tuning AP".
    } ELSE IF (SHIP:APOAPSIS > gTgApo) {
      set tPitch to -15.
      set TVAL to 1.3/TWR.
      SET tTextAct1 to "Tuning PE".
      SET tTextAct2 to " ".
    }
    SET SVAL to heading( 90, tPitch).
  }
//   USCITA ATMOSFERA
//   SOLLEVAMENTO PERIASSE
// PRINT SCHERMO
  PRINT tTextTitle + tTextClear at (3,3).
  PRINT "-> " + tTextAct1 + tTextClear at (3,4).
  PRINT "-> " + tTextAct2 + tTextClear at (3,5).
  PRINT "####### FLY DATA #######" at (5,6).
  PRINT "-Throttle: " + round(THROTTLE,2) + tTextClear at (5,7).
  PRINT "-Pitch:    " + round(tPitch,2) + tTextClear at (5,8).
  PRINT "-Fuel:     " + round(stage:Liquidfuel,2) + tTextClear at (5,9).
  PRINT "-Hgh-Ap:   " + round(SHIP:APOAPSIS,2) + "[" + round(tDApo,2) + "]" + tTextClear at (5,10).
}