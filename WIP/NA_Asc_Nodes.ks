
// /////////// SETUP ////////////

set orb to 85000.
SAS off.
RCS off.
lights off.
gear off.
lock throttle to 0.
clearscreen.
set GRAVITY to (constant():G * body:mass) / (SHIP:ALTITUDE+body:radius)^2.
lock TWR to MAX( 0.001, MAXTHRUST / (MASS*GRAVITY)).
// ///////////////////////////////////

set mode to 2. if ALT:RADAR < 50 { set mode to 1. } if periapsis > 70000 { set mode to 4. }

until mode = 0 {
	SET VSI TO ROUND(VERTICALSPEED,2).
	SET HSI TO ROUND(GROUNDSPEED,2).
	SET SALT TO ROUND(SHIP:ALTITUDE,0).
	SET TgVel TO 2200*(ALT:RADAR/60000).
	SET DiffVelComp TO MIN(0.30,MAX(-0.30,(TgVel-velocity:orbit:MAG)/1000)).
	SET tSpacer TO "              ".
	print "Scola-Guidance - Ascension (RM:"+mode+")"+tSpacer AT (3,2).
	print "ApH: " + round(apoapsis/1000, 1) + " km"+tSpacer AT (3,4).
	print "PeH: " + round(periapsis/1000, 1) + " km"+tSpacer AT (18,4).
	print "ApE: " + round(ETA:apoapsis,0) + " s"+tSpacer AT (3,5).
	print "PeE: " + round(ETA:periapsis,0) + " s"+tSpacer AT (18,5).
	print "VSI: " + round(VSI,0)+ " m/s "+tSpacer AT (3,6).
	print "HSI: " + round(HSI,0)+ " m/s "+tSpacer AT (18,6).
	print "SpO: " + round(velocity:orbit:MAG, 2)+ " m/s "+tSpacer AT (3,7).

	if (STAGE:NUMBER >= 1 AND SALT >= 60000) {stage.}
	
	if mode = 1 { // launch print "T-MINUS 10 seconds". lock steering to up. wait 1.

		print "T-MINUS  9 seconds".
		lock throttle to 1.

		print "......and here we GO, i guess".
		wait 2.

		clearscreen.
		set mode to 2.
	} else if mode = 2 { // fly up
		lock steering to up.
		if (SALT > 500 AND VSI > 150) { set mode to 3.}
	}
	else if mode = 3{ // gravity turn
		set targetPitch to max( 5, 90 * (1 - ALT:RADAR / 25000)). 
		if (targetPitch <= 45) {
			set targetPitch to max( 5, 56 * (1 - ALT:RADAR / 60000)). 
			lock throttle to (1.35+DiffVelComp)/TWR.
		} else {
			lock throttle to 1.30/TWR.
		}
		lock steering to heading (90, targetPitch).
		if SHIP:APOAPSIS >= orb {
			set mode to 4.
		}
	}
	else if mode = 4{ // coast to orbit
		lock throttle to 0.
		if (SHIP:ALTITUDE > 70000) and (VERTICALSPEED > 0) {
			set targetV to sqrt(ship:body:mu/(ship:orbit:body:radius + ship:orbit:apoapsis)). //this is the velocity that we need to be going at AP to be circular
			set apVel to sqrt(((1 - ship:orbit:ECCENTRICITY) * ship:orbit:body:mu) / ((1 + ship:orbit:ECCENTRICITY) * ship:orbit:SEMIMAJORAXIS)). //this is how fast we will be going
			set dv to targetV - apVel. // this is the deltaV
			set mynode to node(time:seconds + eta:apoapsis, 0, 0, dv). // create a new maneuver node
			add mynode. // add the node to our trajectory 
 		}
	}
	else if mode = 6 {
		lock throttle to 0.
		panels on.     //Deploy solar panels
		lights on.
		ag1 on.
		unlock steering.
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