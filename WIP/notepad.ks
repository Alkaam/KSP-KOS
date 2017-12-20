//### FROM G_Space ## Code to calc Distance of 2 point ###

set position1 to latlng(lat1,lng1):position.
set position2 to latlng(lat2,lng2):position.

set distance to (position1-position2):mag.


set north_vector to heading(0,0):vector.
set east_vector to heading(90,0):vector.

set vel_lat to VDOT(north_vector,SHIP:velocity:surface):mag.
set vel_lng to VDOT(east_vector,SHIP:velocity:surface):mag.

//### FROM Supernovy on KSP Forum ##  ###

Alpha_phase=h[1-(r1/2r2+1/2)3/2]

//Where Alpha-phase is the phase angle for rendezvous
//r1 is the radius of the initial lower orbit
//r2 is the radius of the higher target orbit
//Assuming that both orbits are circular and a single Hohmann transfer between them.
//'h' is 180 degrees or pi radians, so that everything inside the bracket is unitless
//or in terms of halves of a revolution
//Note that it is entirely independent of what body you're orbiting, and only
//depends on the ratio of the radii of the two orbits.

//### FROM EtherDragon on KSP Forum ## Formula For Phase Angle ###

p = 1 / (2*sqrt (d^3 / h^3))

set Angle1 to OBT:LAN+OBT:ARGUMENTOFPERIAPSIS+OBT:TRUEANOMALY. //the ships angle to universal reference direction.

set Angle2 to TARGET:OBT:LAN+TARGET:OBT:ARGUMENTOFPERIAPSIS+TARGET:OBT:TRUEANOMALY. //target angle

set Angle3 to Angle2-Angle1.

set Angle3 to Angle3 - 360*floor(Angle3/360). //normalization

