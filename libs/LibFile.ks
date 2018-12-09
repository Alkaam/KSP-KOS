PRINT "Scola-Lib -> FileLib... LOADED".

FUNCTION fPrLib {
	PARAMETER fMsg.
	PRINT "Scola-Lib -> "+fMsg.
	WAIT 0.15.
}

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
FUNCTION fDownload {
  PARAMETER fName.
  PARAMETER fRun is FALSE.
  PARAMETER fUpd is FALSE.
  LOCAL fRet TO FALSE.
  LOCAL fLocal TO HAS_FILE(fName, 1).
  LOCAL fRemote TO HAS_FILE(fName, 0).
  IF (fUpd AND fLocal AND fRemote) {
	DELETEPATH("1:/"+fName).
	COPYPATH("0:/"+fName,"").
	SET fRet TO TRUE.
	fPrLib("Updating "+fName+" File").
  } ELSE IF (fRemote AND NOT fLocal) {
	COPYPATH("0:/"+fName,"").
	SET fRet TO TRUE.
	fPrLib("Downloading "+fName+" File").
  } ELSE {
	fPrLib("Not Found "+fName+" File").
  }
  IF (fRun AND fRet) {
	fPrLib("RUNNING "+fName+" File").
	RUNONCEPATH("1:/"+fName).
  }
  RETURN fRet.
}

FUNCTION fDownLib {
  PARAMETER fName.
  PARAMETER fRun is FALSE.
  LOCAL fRet TO FALSE.
  IF HAS_FILE(fName, 1) {
    DELETEPATH("1:/"+fName).
  }
  IF HAS_FILE(fName, "0:/libs/") {
    COPYPATH("0:/libs/"+fName,"").
	SET fRet TO TRUE.
	fPrLib("Downloading "+fName+" Library").
  }
  IF (fRun AND fRet) {
	RUNONCEPATH(fName).
	fPrLib("RUNNING "+fName+" Library").
  }
}
