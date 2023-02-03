$!
$! Take the message source file and generate the object, executable, and
$! pointer files. Then generate the multi-language files as well.
$!
$  HOME_DEV := 'F$LOGICAL("SYS$DISK")
$  HOME_DIR := 'F$DIRECTORY()
$  HOME := "''HOME_DEV'''HOME_DIR'"
$!  SET DEF VSTA$BUILD
$  WRITE SYS$OUTPUT "You are temporarily connected to VSTA$BUILD"
$  MESS/SDL=VSTA$SOURCE:VSTAMSG VSTA$SOURCE:VSTAERRS.MSG
$  LINK/MAP/SHARE VSTAERRS,VSTA$SCAFF:IDENT.OPT/OPT
$  MESS/FILE=VSTAERRS/OBJ=VSTAMSG VSTA$SOURCE:VSTAERRS
$!
$! Now copy the newly generated files into the appropriate directories
$!
$  COPY VSTAERRS.EXE,VSTAERRS.MAP VSTA$EXE
$!  COPY VSTAERRS.EXE SYS$MESSAGE
$!  SET PROT=(S:RWED,O:RWED,G:RE,W:RE) SYS$MESSAGE:VSTAERRS.EXE
$!  PURGE SYS$MESSAGE:VSTAERRS.*
$  COPY VSTAERRS.* VSTA$LIBRARY
$  SET DEF 'HOME'
$  WRITE SYS$OUTPUT "You are now connected to ''HOME'"
$DONE:
$  EXIT
