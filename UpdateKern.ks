FUNCTION fPrKer {
	PARAMETER fMsg.
	PRINT "Scola-Sys -> "+fMsg.
	WAIT 0.10.
}

WAIT 2.
CLEARSCREEN.
fPrKer("Prepating to Update Kernel...").
COPYPATH("0:/libs/LibFile.ks","").
RUNONCEPATH("LibFile.ks").
fPrKer("Deleting Old Kernel...").
DELETEPATH("1:/boot").
COPYPATH("0:/boot/SC.Kernel.ks","1:/boot/SC.Kernel.ks").
SET kOSProcessor():BOOTFILENAME TO "1:/boot/SC.Kernel.ks".
fFormat(TRUE).
