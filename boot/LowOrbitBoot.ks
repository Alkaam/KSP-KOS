set gSwPayload to 0.

Wait 5.
PRINT "Booting Systems...".
Wait 1.
PRINT "Copy File from KSC...".
Wait 0.1.
copypath("0:/Stage_Asc.ks","").
Wait 0.1.
copypath("0:/Stage_Land.ks","").
Wait 0.1.
if (gSwPayload) {
	PRINT "Initialize Payload...".
	processor("Payload"):deactivate.
	copypath("0:/TestSat_Guide.ks","Payload:/ToOrbit.ks").
	set processor("Payload"):bootfilename to "ToOrbit.ks".
	processor("Payload"):activate.
}
PRINT "Initialize Self...".
set processor("Main"):bootfilename to "Stage_Asc.ks".
wait 0.3.
PRINT "rebooting...".
wait 2.
Reboot.