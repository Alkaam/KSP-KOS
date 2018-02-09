FUNCTION fTgPort {
  LIST TARGETS IN targets.
  FOR target IN targets {
    IF target:DOCKINGPORTS:LENGTH <> 0 {
		return target:DOCKINGPORTS[0].
    }
  }
}
FUNCTION fContRCS {
	PARAMETER fTgVec.
	IF fTgVec:MAG > 1 SET fTgVec TO fTgVec:normalized.
	SET SHIP:CONTROL:FORE TO fTgVec * SHIP:FACING:FOREVECTOR.
	SET SHIP:CONTROL:STARBOARD TO fTgVec * SHIP:FACING:STARVECTOR.
	SET SHIP:CONTROL:TOP TO fTgVec * SHIP:FACING:TOPVECTOR.
}
FUNCTION approach_port {
	PARAMETER targetPort, dockingPort, distance, speed.
	dockingPort:CONTROLFROM().
	LOCK distanceOffset TO targetPort:PORTFACING:VECTOR * distance.
	LOCK approachVector TO targetPort:NODEPOSITION - dockingPort:NODEPOSITION + distanceOffset.
	LOCK relativeVelocity TO SHIP:VELOCITY:ORBIT - targetPort:SHIP:VELOCITY:ORBIT.
	LOCK STEERING TO -1 * targetPort:PORTFACING:VECTOR.
	UNTIL dockingPort:STATE <> "Ready" {
		translate((approachVector:normalized * speed) - relativeVelocity).
		LOCAL distanceVector IS (targetPort:NODEPOSITION - dockingPort:NODEPOSITION).
		IF VANG(dockingPort:PORTFACING:VECTOR, distanceVector) < 2 AND abs(distance - distanceVector:MAG) < 0.1 {
			BREAK.
		}
		WAIT 0.01.
	}
	translate(V(0,0,0)).
}