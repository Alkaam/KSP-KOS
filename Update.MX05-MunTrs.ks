PRINT "Scola-Sys -> Update... LOADED".
LIST FILES IN tFileList.
FOR tItem IN tFileList {
	if (tItem <> "boot") {DELETEPATH(tItem).}
}