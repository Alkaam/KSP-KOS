SET gDebug TO FALSE.
SET gKerVers TO 2.6.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET SHIP:CONTROL:MAINTHROTTLE TO 0.
SET gUpdFile TO "Update."+SHIPNAME+".ks".
SET gMissFile TO "Mission."+SHIPNAME+".ks".
SET fCon TO ADDONS:RT:HASCONNECTION(SHIP) = TRUE OR SHIP:STATUS = "PRELAUNCH" OR gDebug = TRUE.

FUNCTION HAS_FILE {
  PARAMETER fName.
  PARAMETER vol.
  IF (vol = "0" OR vol = "1") { SET vol TO vol+":/". }
  IF (vol = "0:/" AND fCon) {
	  CD(vol).
	  LIST FILES IN allFiles.
	  FOR file IN allFiles {
		IF file:NAME = fName {
		  CD("1:/").
		  RETURN TRUE.
		}
	  }
  }
  CD("1:/").
  RETURN FALSE.
}
FUNCTION fPrKer {
	PARAMETER fMsg.
	PRINT "Scola-Sys -> "+fMsg.
	WAIT 0.10.
}
FUNCTION fDebug {
	PARAMETER fMsg.
	IF (gDebug) {
		PRINT "Scola-Dbg -> "+fMsg.
		WAIT 0.10.
	}
}
FUNCTION fStandBy {
	IF (SHIP:STATUS <> "LANDED" AND SHIP:STATUS <> "PRELAUNCH") {
		LOCK STEERING TO SUN:POSITION.
	}
	fPrKer("Standby 2 Minutes before Reboot.").
	WAIT 120.
	REBOOT.
}
