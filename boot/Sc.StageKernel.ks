SET gDebug TO FALSE.
SET gKerVers TO 0.1.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET SHIP:CONTROL:MAINTHROTTLE TO 0.
SET gMissFile TO "Stage.ks".

FUNCTION HAS_FILE {
  PARAMETER fName.
  PARAMETER vol.
  IF (vol = "0" OR vol = "1") { SET vol TO vol+":/". }
  CD(vol).
  LIST FILES IN allFiles.
  FOR file IN allFiles {
    IF file:NAME = fName {
      CD("1:/").
      RETURN TRUE.
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
CLEARSCREEN.
PRINT "ScolaCorp Kernel v"+gKerVers.
SET fLib TO HAS_FILE("LibFile.ks",1).
SET fMis TO HAS_FILE(gMissFile,1).
SET fCon TO ADDONS:RT:HASCONNECTION(SHIP) = TRUE OR SHIP:STATUS = "PRELAUNCH" OR gDebug = TRUE.
IF (fLib) {RUNONCEPATH("LibFile.ks").}
IF (fCon) {
	IF (NOT fLib) {COPYPATH("0:/libs/LibFile.ks",""). RUNONCEPATH("LibFile.ks").}
	IF (NOT fMis) {SET fMis TO fDownload(gMissFile).}
	IF (NOT fUpd) {SET fUpd TO fDownload(gUpdFile). DELETEPATH("0:/"+gUpdFile). }
}
IF (NOT fCon) {
	IF (NOT fLib) {fStandBy().}
	ELSE IF (NOT fMis) {fStandBy().}
}
IF (fMis) {
	fPrKer("Stage File Found... RUNNING").
	WAIT 2.
	RUNONCEPATH(gMissFile).
} ELSE {fStandBy().}