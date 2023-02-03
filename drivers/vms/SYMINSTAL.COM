$! Create libraries with VSTA symbol definitions
$!
$  set noon
$!
$! Move all the appropriate language files to their destination directories
$!
$! Create a VSTA library for MACRO
$!
$  lib/cre/mac sys$library:vstamac.mlb vstamsg.mar,vstagbl.mar
$!
$! Do the fortran files
$!
$  copy/nolog vstamsg.for,vstagbl.for sys$library:
$!
$! Do the pascal environments (if possible) and copy pascal sources
$!
$dopas:
$  if "''f$search("sys$system:pascal.exe")'" .eqs. "" then goto jpas
$  pas/noobj/envir=sys$library:vstagbl.pen vstagbl.pas
$  pas/noobj/envir=sys$library:vstamsg.pen vstamsg.pas
$jpas:
$  copy/nolog vstamsg.pas,vstagbl.pas sys$library:
$!
$! Do the PL1 library (our own for VAXstation software)
$!
$dopli:
$  lib/cre/text sys$library:vstapli.tlb-
 vstamsg.pli/mod=$vstamsg,vstagbl.pli/mod=$vstagbl
$!
$! Do the bliss library files (our own for VAXstation software)
$!
$dobli:
$  if "''f$search("sys$system:bliss32.exe")'" .eqs. "" then goto jr32
$  bli/nolis/lib=sys$library:vstagbl.l32 vstagbl.r32
$  bli/nolis/lib=sys$library:vstamsg.l32 vstamsg.r32
$jr32:
$  copy/nolog vstamsg.r32,vstagbl.r32 sys$library:
$!
$! Copy the VAX-11 C library files (our own for VAXstation software)
$!
$docc:
$  copy/nolog vstamsg.h,vstagbl.h sys$library:
$!
$done:
$  exit
