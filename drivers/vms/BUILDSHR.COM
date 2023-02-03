$!
$! BUILDSHR.COM - Command procedure to build the sharable library.
$!
$!   This command file first deletes the module VSTASHR from the system
$! sharable library, to prevent multiply defined globals when the new
$! one is linked. Then it builds a new VSTASHR.EXE and .MAP and puts
$! them on VSTA$EXE:. The sharable image will consist of the object
$! library (from VSTALIB.OLB), transfer vectors, and error message file.
$!   Then the old VSTASHR.EXE (the one in SYS$SHARE) is put back into the
$! system sharable library.
$!   To actually install the new VSTASHR.EXE now on VSTA$EXE, you must
$! execute the command file VSTA$COM:IMGINSTAL.COM.
$!
$ ON ERROR THEN GOTO DONE
$ ON CONTROL_Y THEN GOTO DONE
$ LINK/MAP=VSTASHR/notraceback/nodebug/FULL/SHARE=VSTASHR -
	VSTA$SCAFF:IDENT.OPT/OPT,-
	VSTA$BUILD:VSTALIBTV, -
	VSTA$BUILD:VSTALIB/LIB,-
	SYS$SYSTEM:SYS.STB/SEL, -
	SYS$INPUT:/OPTIONS
!
! Options for shareable image VSTASHR
!
GSMATCH = LEQUAL,1,0
CLUSTER = VSTA$TRANSFER_VECTORS
COLLECT = VSTA$TRANSFER_VECTORS,VSTA$TRANSFER_VECTORS
UNIVERSAL = VSTA$GL_LOCAL_ERROR,VSTA$$QIOW
$ LINK/NOSYSSHR/notraceback/nodebug/MAP=VSTASTUB/FULL/SHARE=VSTASHR -
	VSTA$SCAFF:IDENT.OPT/OPT,-
	VSTA$BUILD:VSTVSTUB, -
	VSTA$BUILD:VSTASTUB,-
	VSTA$BUILD:VSSTUBERR,-
	SYS$INPUT:/OPTIONS
!
! Options for shareable image VSTASTUB
!
GSMATCH = LEQUAL,1,0
CLUSTER = VSTA$TRANSFER_VECTORS
COLLECT = VSTA$TRANSFER_VECTORS,VSTA$TRANSFER_VECTORS
$
$ RENA VSTASHR.EXE VSTASTUB.EXE
$ COPY VSTASHR.EXE,.MAP VSTA$EXE:
$ COPY VSTASTUB.EXE,.MAP VSTA$EXE:
$!
$DONE:
$! To actually install the image libraries, @VSTA$COM:IMGINSTAL
$ EXIT
