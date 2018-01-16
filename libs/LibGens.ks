set gKSC to latlng(-0.0972092543643722, -74.557706433623).

FUNCTION fGrav {
	RETURN (CONSTANT():G * BODY:MASS) / (SHIP:ALTITUDE+BODY:RADIUS)^2.
}
FUNCTION fTWR {
	RETURN MAX( 0.001, MAXTHRUST / (MASS*fGrav)).
}
FUNCTION GEN_AngPro{
	PARAMETER fCorr IS 0.
	RETURN (90 - VANG(UP:VECTOR, SHIP:PROGRADE:VECTOR))+fCorr.
}
FUNCTION GEN_AngSteer {
	PARAMETER fPrec IS 0.20.
	SET VSteer TO VANG(SHIP:FACING:FOREVECTOR, STEERING:FOREVECTOR). //vang(ship:facing:forevector,vector)
	IF (VSteer > 180) {SET VSteer TO VSteer-360.}
	IF (ABS(VSteer) <= fPrec) { RETURN TRUE. } ELSE { RETURN FALSE. }
}
FUNCTION GEN_TgPitch {
	PARAMETER fMinPitch.
	PARAMETER fStartAngle.
	PARAMETER fMaxHeight.
	RETURN MAX( fMinPitch, fStartAngle * (1 - ALT:RADAR / fMaxHeight)).
}
FUNCTION GEN_TgPitch2 {
	PARAMETER fMinPitch.
	PARAMETER fMaxHeight.
	SET PTC1 TO MAX( fMinPitch, 90 * (1 - ALT:RADAR / (fMaxHeight*0.30))).
	SET PTC2 TO MAX( fMinPitch, (90*0.62) * (1 - ALT:RADAR / (fMaxHeight*0.71))).
	RETURN MAX(PTC1,PTC2).
}
FUNCTION GEN_TWR2Th {
	PARAMETER fPower.
	RETURN MIN(1.0,MAX(0.0,fPower/fTWR)).
}

FUNCTION GEN_Log {
	PARAMETER fText.
	SET fFileName TO "Log."+SHIP:NAME+".txt".
	LOG fText TO fFileName.
}

FUNCTION fTelemetry {
	PARAMETER fText.
	SET fFileName TO "Tel."+SHIP:NAME+".CSV".
	LOG fText TO fFileName.
}