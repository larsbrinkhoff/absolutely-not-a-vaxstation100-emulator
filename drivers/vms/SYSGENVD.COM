$ A:
$	isa = F$GETDVI("_VBA0:","EXISTS")
$	if isa .ne. 1 then exit(%x908)
$ vddriver_log = f$logical ("VDDRIVER$EXE")
$ if vddriver_log .eqs. "" then goto standard_vddriver
$ write sys$output "[Loading private  VDDRIVER.EXE from ", vddriver_log, "]"
$ goto load_vddriver
$standard_vddriver: define vddriver$exe vsta$exe:
$load_vddriver: mcr sysgen
load	vddriver$exe:vddriver
connect VDA0	/noadapter -
		/vector=%O770 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ B:
$	isb = F$GETDVI("_VBB0:","EXISTS")
$	if isb .ne. 1 then goto done
$	mcr sysgen
connect VDB0	/noadapter -
		/vector=%O764 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ C:
$	isc = F$GETDVI("_VBC0:","EXISTS")
$	if isc .ne. 1 then goto done
$	mcr sysgen
connect VDC0	/noadapter -
		/vector=%O760 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ D:
$	isd = F$GETDVI("_VBD0:","EXISTS")
$	if isd .ne. 1 then goto done
$	mcr sysgen
connect VDD0	/noadapter -
		/vector=%O754 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ E:
$	ise = F$GETDVI("_VBE0:","EXISTS")
$	if ise .ne. 1 then goto done
$	mcr sysgen
connect VDE0	/noadapter -
		/vector=%O750 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ F:
$	isf = F$GETDVI("_VBF0:","EXISTS")
$	if isf .ne. 1 then goto done
$	mcr sysgen
connect VDF0	/noadapter -
		/vector=%O744 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ G:
$	isg = F$GETDVI("_VBG0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDG0	/noadapter -
		/vector=%O740 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ H:
$	ish = F$GETDVI("_VBH0:","EXISTS")
$	if ish .ne. 1 then goto done
$	mcr sysgen
connect VDH0	/noadapter -
		/vector=%O734 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ I:
$	isg = F$GETDVI("_VBI0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDI0	/noadapter -
		/vector=%O730 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ J:
$	isg = F$GETDVI("_VBJ0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDJ0	/noadapter -
		/vector=%O724 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ K:
$	isg = F$GETDVI("_VBK0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDK0	/noadapter -
		/vector=%O720 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ L:
$	isg = F$GETDVI("_VBL0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDL0	/noadapter -
		/vector=%O714 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ M:
$	isg = F$GETDVI("_VBM0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDM0	/noadapter -
		/vector=%O710 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ N:
$	isg = F$GETDVI("_VBN0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDN0	/noadapter -
		/vector=%O704 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ O:
$	isg = F$GETDVI("_VBO0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDO0	/noadapter -
		/vector=%O700 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ P:
$	isg = F$GETDVI("_VBP0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDP0	/noadapter -
		/vector=%O670 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ Q:
$	isg = F$GETDVI("_VBQ0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDQ0	/noadapter -
		/vector=%O664 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ R:
$	isg = F$GETDVI("_VBR0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDR0	/noadapter -
		/vector=%O660 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ S:
$	isg = F$GETDVI("_VBS0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDS0	/noadapter -
		/vector=%O654 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ T:
$	isg = F$GETDVI("_VBT0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDT0	/noadapter -
		/vector=%O650 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ U:
$	isg = F$GETDVI("_VBU0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDU0	/noadapter -
		/vector=%O644 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ V:
$	isg = F$GETDVI("_VBV0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDV0	/noadapter -
		/vector=%O640 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ W:
$	isg = F$GETDVI("_VBW0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDW0	/noadapter -
		/vector=%O634 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ X:
$	isg = F$GETDVI("_VBX0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDX0	/noadapter -
		/vector=%O630 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ Y:
$	isg = F$GETDVI("_VBY0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDY0	/noadapter -
		/vector=%O624 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$ Z:
$	isg = F$GETDVI("_VBZ0:","EXISTS")
$	if isg .ne. 1 then goto done
$	mcr sysgen
connect VDZ0	/noadapter -
		/vector=%O620 -
		/numvec=1 -
		/csr=0 -
		/drivername=VDDRIVER -
		/maxunits=128
exit
$!
$DONE:
$	write sys$output ""
$	write sys$output "The following VAXstation devices now exist:"
$	write sys$output ""
$	mcr sysgen
show/devices=VB
show/devices=VD
exit
$ 	exit
