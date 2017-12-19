set orb to 69000.
SAS off.
RCS off.
lights off.
gear off.
lock throttle to 0.
clearscreen.
set GRAVITY to (constant():G * body:mass) / (SHIP:ALTITUDE+body:radius)^2.
