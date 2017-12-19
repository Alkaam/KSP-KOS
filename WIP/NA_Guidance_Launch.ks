
// /////////// SETUP ////////////

set orb to 85000.
SET TVAL TO 0.
SET SVAL TO UP.
SAS off.
RCS off.
lights off.
gear off.
clearscreen.
set GRAVITY to (constant():G * body:mass) / (SHIP:ALTITUDE+body:radius)^2.
lock TWR to MAX( 0.001, MAXTHRUST / (MASS*GRAVITY)).
lock THROTTLE TO TVAL.
LOCK STEERING TO SVAL.
// ///////////////////////////////////

set mode to 2. if ALT:RADAR < 50 { set mode to 1. } if periapsis > 70000 { set mode to 4. }

until mode = 0 {
	SET VSI TO ROUND(VERTICALSPEED,2).
	SET HSI TO ROUND(GROUNDSPEED,2).
	SET SALT TO ROUND(SHIP:ALTITUDE,0).
	SET tSpacer TO "              ".
	print "Scola-Guidance - Ascension (RM:"+mode+")"+tSpacer AT (3,2).
	print "ApH: " + round(apoapsis/1000, 1) + " km"+tSpacer AT (3,4).
	print "PeH: " + round(periapsis/1000, 1) + " km"+tSpacer AT (18,4).
	print "ApE: " + round(ETA:apoapsis,0) + " s"+tSpacer AT (3,5).
	print "PeE: " + round(ETA:periapsis,0) + " s"+tSpacer AT (18,5).
	print "VSI: " + round(VSI,0)+ " m/s "+tSpacer AT (3,6).
	print "HSI: " + round(HSI,0)+ " m/s "+tSpacer AT (18,6).
	print "SpO: " + round(velocity:orbit:MAG, 2)+ " m/s "+tSpacer AT (3,7).

	if mode = 1 { // launch print "T-MINUS 10 seconds". lock steering to up. wait 1.
		SET TVAL TO 1.
		wait 2.
		SET SVAL TO UP.
		if (SALT > 500 AND VSI > 150) { set mode to 2.}
	}
	else if mode = 2{ // gravity turn
		set targetPitch to max( 5, 90 * (1 - ALT:RADAR / 25000)). 
		SET TVAL TO 1.30/TWR.
		SET SVAL TO heading (90, targetPitch).
		if (targetPitch <= 45) {SET mode TO 3.}
	}
	else if mode = 3{ // gravity turn
		set targetPitch to max( 5, 56 * (1 - ALT:RADAR / 60000)). 
		SET TgVel TO 2200*(ALT:RADAR/60000).
		SET DiffVelComp TO MIN(0.30,MAX(-0.30,(TgVel-velocity:orbit:MAG)/1000)).
		SET TVAL TO (1.35+DiffVelComp)/TWR.
		SET SVAL TO heading (90, targetPitch).
		if SHIP:APOAPSIS >= orb {
			set mode to 4.
		}
	}
	else if mode = 4{ // coast to orbit
		SET TVAL TO 0.
		if (SHIP:ALTITUDE > 70000) and (ETA:APOAPSIS > 60) and (VERTICALSPEED > 0) {
			if WARP = 0 {        
				wait 1.        
				SET WARP TO 3. 
				}
			}
		else if ETA:APOAPSIS < 70 {
			SET WARP to 0.
			SET SVAL TO heading(90,0).
			wait 2.
			set mode to 5.
			}

		if (periapsis > 70000) and mode = 4{
		 if WARP = 0 {        
				wait 1.         
				SET WARP TO 3. 
		  }
		}

	}

	else if mode = 5 {
		if ETA:APOAPSIS < 15 or VERTICALSPEED < 0 {
			SET TVAL TO 1.
			}

		if (ETA:APOAPSIS > 90) and (apoapsis > orb) { set mode to 4. }

		if ship:periapsis > orb {
			SET TVAL TO 0.
			set mode to 6.
		}
	}

	else if mode = 6 {
		SET TVAL TO 0.
		panels on.     //Deploy solar panels
		lights on.
		ag1 on.
		unlock steering.
		unlock throttle.
		set mode to 0.
		print "WELCOME TO A STABE SPACE ORBIT!".
		wait 2.
	}

	// this is the staging code to work with all rockets //

	if stage:number > 0 {
		if maxthrust = 0 {
			stage.
		}
		SET numOut to 0.
		LIST ENGINES IN engines. 
		FOR eng IN engines 
		{
			IF eng:FLAMEOUT 
			{
				SET numOut TO numOut + 1.
			}
		}
		if numOut > 0 { stage. }.
	}

}