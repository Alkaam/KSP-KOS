SET gDebug TO TRUE.
SET gKerVers TO 1.1.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
CLEARSCREEN.
PRINT "ScolaCorp Kernel v"+gKerVers .
WAIT 1.
SET SHIP:CONTROL:MAINTHROTTLE TO 0.
COPYPATH("0:/libs/LibFile.ks","").
RUNONCEPATH("LibFile.ks").
SET gUpdFile TO SHIPNAME+".Update.ks".
SET gMissFile TO SHIPNAME+".Mission.ks".
DELETEPATH(gMissFile).
SET gUpdate TO FALSE.
SET gMission TO HAS_FILE(gMissFile,1).
WAIT 1.


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

IF (ADDONS:RT:HASCONNECTION(SHIP) OR SHIP:STATUS = "PREFLIGHT" OR gDebug) {
	fPrKer("Ship on "+SHIP:STATUS+" Status").
	fPrKer("KSC Connection: "+ADDONS:RT:HASKSCCONNECTION(SHIP)).
	fPrKer("RELAY Connection: "+ADDONS:RT:HASCONNECTION(SHIP)).
	fDebug("Debug Mode ENABLED!").
	SET gUpdate TO fDownload(gUpdFile).
	if (NOT gUpdate AND NOT gMission) {
		SET gMission TO fDownload(gMissFile).
	}
	IF (gUpdate) {
		fPrKer("Update Found... RUNNING!").
		DELETEPATH("0:/"+gUpdFile).
		WAIT 2.
		RUNONCEPATH(gUpdFile).		
		DELETEPATH(gUpdFile).
		fPrKer("Rebooting System in 5 Seconds.").
		WAIT 5.
		REBOOT.
	} ELSE IF (gMission) {
		fPrKer("Mission File Found... RUNNING").
		WAIT 2.
		RUNONCEPATH(gMissFile).
	} ELSE {
		fPrKer("STATUS IDLE: No Instructions... Waiting 120 Seconds").
	}
} ELSE {
	IF (SHIP:STATUS = "ORBITING" OR SHIP:STATUS = "ESCAPING") {
		LOCK STEERING TO SUN:POSITION.
		fPrKer("STATUS IDLE: Orienting to Sun Position").
	}
	fPrKer("No Connection... Waiting 120 Seconds").
}
	WAIT 120.
	REBOOT.