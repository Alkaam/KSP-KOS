FUNCTION NOTIFY {
  PARAMETER message.
  HUDTEXT("kOS: " + message, 5, 2, 50, YELLOW, false).
}

FUNCTION HAS_FILE {
  PARAMETER name.
  PARAMETER vol.

  SWITCH TO vol.
  LIST FILES IN allFiles.
  FOR file IN allFiles {
    IF file:NAME = name {
      SWITCH TO 1.
      RETURN TRUE.
    }
  }

  SWITCH TO 1.
  RETURN FALSE.
}

FUNCTION RENAMETO {
  PARAMETER oldName.
  PARAMETER newName.
  PARAMETER drive.
  PRINT "[**] RENAMINING: "+oldName+" TO "+newName.
  IF HAS_FILE(oldName, drive) {
    COPYPATH(drive+":/"+oldName,drive+":/"+newName).
	DELETEPATH(drive+"/:"+oldName).
  }
}

FUNCTION DOWNLOAD {
  PARAMETER name.
  PRINT "[=>] DOWNLOADING: "+name.
  IF HAS_FILE(name, 1) {
    DELETEPATH("1:/"+name).
  }
  IF HAS_FILE(name, 0) {
    COPYPATH("0:/"+name,"1:/").
  }
  IF HAS_FILE(name, 1) {
	PRINT "[!!] DOWNLOAD DONE".
  }
}

FUNCTION UPLOAD {
  PARAMETER name.
  PRINT "[<=] UPLOADING: "+name.
  IF HAS_FILE(name, 0) {
    DELETEPATH("0:/"+name).
  }
  IF HAS_FILE(name, 1) {
    COPYPATH("1:/"+name,"0:/").
  }
}

FUNCTION REQUIRE {
  PARAMETER name.

  IF NOT HAS_FILE(name, 1) { DOWNLOAD(name). }
  MOVEPATH(name,"tmp.exec.ks").
  RUNPATH("tmp.exec.ks").
  MOVEPATH("tmp.exec.ks",name).
}

FUNCTION UPDATE_FILE {
	SET updateScript TO SHIP:NAME + ".update.ks".

	IF ADDONS:RT:HASCONNECTION(SHIP) {
	  IF HAS_FILE(updateScript, 0) {
		PRINT "[!!] FOUND UPDATE: "+updateScript.
		DOWNLOAD(updateScript).
		DELETEPATH("0:/"+updateScript).
		IF HAS_FILE("update.ks", 1) {
		  DELETEPATH("1:/update.ks").
		}
		MOVEPATH(updateScript,"update.ks").
		PRINT "[##] RUNNING UPDATE...".
		RUNPATH("update.ks").
		DELETEPATH("1:/update.ks").
	  }
	}
}

PRINT "[!!] BOOTING UP".
UPDATE_FILE().
PRINT "[!!] BOOT COMPLETE".
SET tTime TO TIME:SECONDS.
UNTIL FALSE {
	IF (tTIME+10 < TIME:SECONDS AND ADDONS:RT:HASCONNECTION(SHIP) AND ALT:RADAR > 70000) {
		SET tTime TO TIME:SECONDS.
		UPDATE_FILE().
	}
}