PRINT "Scola-Sys -> Mission... LOADED".

FUNCTION fStaging {}

IF (SHIP:STATUS = "PRELAUNCH") {
  fDownload("ScC.Ascension.ks",TRUE).
}