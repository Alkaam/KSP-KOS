Wait 5.
PRINT "Booting Systems...".
Wait 1.
PRINT "Copy File from KSC...".
Wait 0.1.
copypath("0:/test1.ks","").
PRINT "Initialize Self...".
RUNPATH("test1.ks").