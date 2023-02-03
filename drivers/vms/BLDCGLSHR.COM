$!
$! BUILDSHR.COM - Command procedure to build the sharable library.
$!
$!Note:  To use this command file, SET DEFAULT VSTA$BUILD:.
$!
$!   This command file first deletes the module CGLSHR from the system
$! sharable library, to prevent multiply defined globals when the new
$! one is linked. Then it builds a new CGLSHR.EXE and .MAP and puts
$! them on VSTA$EXE:. The sharable image will consist of the object
$! library (from VSTACGL.OLB), transfer vectors, and error message file.
$!   Then the old CGLSHR.EXE (the one in SYS$SHARE) is put back into the
$! system sharable library.
$!   To actually install the new CGLSHR.EXE now on VSTA$EXE, you must
$! execute the command file VSTA$COM:CGLINSTAL.COM.
$!
$ ON ERROR THEN GOTO DONE
$ ON CONTROL_Y THEN GOTO DONE
$ LINK/MAP=CGLSHR/notrace/nodebug/FULL/SHARE=CGLSHR VSTACGLTV, VSTACGL/LIB, -
			 VSTA$SCAFF:IDENT.OPT/OPT,-
			 VSTA$BUILD:VSTAMSG, SYS$INPUT/OPTIONS
!
! Options for shareable image CGLSHR
!
GSMATCH = LEQUAL,1,0
CLUSTER = CGL$LIB_TRANSFER_VECTORS
COLLECT = CGL$LIB_TRANSFER_VECTORS,CGL$LIB_TRANSFER_VECTORS
$ LINK/NOSYSSHR/MAP=CGLSTUB/notrace/nodebug/FULL/SHARE=CGLSHR CGLTVSTUB,-
			 VSTASTUB, -
			 VSTA$SCAFF:IDENT.OPT/OPT,-
			 VSTA$BUILD:VSSTUBERR, SYS$INPUT/OPTIONS
!
! Options for shareable image CGLSTUB
!
GSMATCH = LEQUAL,1,0
CLUSTER = CGL$LIB_TRANSFER_VECTORS
COLLECT = CGL$LIB_TRANSFER_VECTORS,CGL$LIB_TRANSFER_VECTORS
$ RENA CGLSHR.EXE CGLSTUB.EXE
$ COPY CGLSHR.EXE,.MAP VSTA$EXE:
$ COPY CGLSTUB.EXE,.MAP VSTA$EXE:
$!
$DONE:
$ EXIT
