!-----------------------------------------------------------------------
!
!  MMS build procedure for VAXStation 100 VDS product
!
!  This module must have all VSTA$x logicals defined to point to
!  appropriate directories.  The environment intended for this
!  module is to have source files found in the default cms library, with 
!  the exception of a few command files and a few libraries, for
!  which source code is not available (ie - vms libraries) hence
!  the object code will not go in a cms library.
!
!	VSTA$x logicals required:
!
!		vsta$build		-used for scratch in build
!		vsta$com		-see below for files 
!		vsta$exe		-contains finalized code
!		vsta$library		-should contain object libraries
!		vsta$scaff		-scratch
!		vsta$source		-depository for cms pulls
!
!	Command files used by this module:
!
!		1) ACPLINK
!		2) BLDCGLSHR
!		3) BUILDMSG
!		4) BUILDSHR
!		5) LOGINLNK
!		6) SYMINSTAL
!		7) see opts macro definition
!
!
!	NOTE:
!	To remove dependency on SDL for building VSTA, the calls to SDL
!	have been commented out.  Instead, the appropriate files are 
!	fetched from the CMS library.
!
!	Also, many of the command files previously used have been included
!	into this procedure and therefore are no longer needed.
!------------------------------------------------------------------------
!
.IGNORE	:	!ignore all errors unless cmd line tells us otherwise
! Define macros
! These defs can be overridden by specifying
!	$ MMS/MACRO=MMSMACS.TXT
!	and put overriding defs into that file.
!


opts = vsta$com:acp.opt, -
	vsta$com:acp0.opt, -
	vsta$com:acpem.opt, -
	vsta$com:acptxt.opt, -
	vsta$com:acpgid.opt, -
	vsta$com:acphi.opt, -
	vsta$com:acpinp.opt, -
	vsta$com:acperr.opt, -
	vsta$com:acpdbg.opt, -
	vsta$com:acpmouse.opt, -
	vsta$scaff:ident.opt

inits = vsacp.obj, -
	track.obj, -
	vstaccess.obj, -
	pidaccess.obj, -
	vstaresrc.obj, -
	acpdspch.obj, -
	vsbrdcst.obj, -
	sobgtr.obj, -
	vstakrnl.obj, -
	vsvdsvd.obj, -
	vstaodrv.obj, -
	vsvdsvdc.obj, -
	vsvdsngi.obj, -
	vsvdspb.obj, -
	vspaste.obj, -
	vswindow.obj, -
	vsvssvp.obj, -
	vsvssvs.obj, -
	vsvssps.obj, -
	vstanativ.obj, -
	vstarects.obj, -
	vstaque.obj, -
	vstadrive.obj, -
	vbcontrol.obj, -
	vstadmm.obj, -
	vstamove.obj, -
	vsprint.obj

txts = txtalloc8.obj, -
	txtdelete.obj, -
	txtdiag.obj, -
	txtfields.obj, -
	txtfile.obj, -
	txtfont.obj, -
	txtinit.obj, -
	txtlines.obj, -
	txtlists.obj, -
	txtpublic.obj, -
	txtsetmod.obj, -
	txtstring.obj, -
	txtwrite.obj

mice = mouseast.obj, -
	mousebtns.obj, -
	mouseloc.obj, -
	mousertns.obj

ems = vsvtem100.obj, -
	vsvt100cu.obj, -
	vstekem.obj, -
	vstekfo.obj, -
	vstekcu.obj, -
	vsgenem.obj, -
	vsemul.obj

gids = vsgiod.obj, -
	vsgism.obj, -
	vsgias.obj, -
	vsgial.obj, -
	vsgipp.obj, -
	vsgipl.obj, -
	vsgipa.obj, -
	vsgilp.obj, -
	vsgisp.obj, -
	vsgicx.obj, -
	vsgicc.obj, -
	vsgirm.obj

his = vstacom.obj, -
	vscomdeb.obj, -
	vssrvann.obj, -
	vssrvauth.obj, -
	vssrvcmd.obj, -
	vssrvdeb.obj, -
	vssrvedit.obj, -
	vssrvform.obj, -
	vssrvts.obj, -
	vssrvfmio.obj, -
	vssrvhold.obj, -
	vssrvinit.obj, -
	vssrvintr.obj, -
	vssrvjob.obj, -
	vssrvmenu.obj, -
	vssrvprof.obj, -
	vssrvsel.obj, -
	vssrvsymb.obj, -
	vssrvfoot.obj, -
	vssrvvds.obj, -
	vssrvvss.obj, -
	vstahival.obj, -
	validate.obj, -
	hpwd.obj

errs = vserrargh.obj, -
	shostk.obj, -
	vserrors.obj, -
	termnl.obj, -
	vsusage.obj, -
	vstashr.exe

inps = vsvkb.obj, -
	vstakbrd.obj, -
	menus.obj, -
	mainmenu.obj, -
	hlpbutton.obj, -
	regions.obj, -
	vsvtb.obj, -
	vstairp.obj, -
	vstaptr.obj, -
	vsvtemgl.obj

help =	mfhlp.mf, mfeng.mf

pme =	npmeclock.obj, pmesetimr.obj

!
! To build VSACP.EXE and VSACPD.EXE, type "MMS" or "MMS VSACP.EXE"
!
vsacp.exe : $(opts), $(inits), $(txts), $(ems), $(mice), -
		$(gids), $(his), $(errs), $(inps), $(help), $(pme), -
		syminstal.com, acplink.com, -
		buildver.obj, sys$system:sys.stb

!****************************************************************
	$ purge vsta$build
	$ @VSTA$COM:SYMINSTAL
	$ @VSTA$COM:ACPLINK

!------------------------------------------------------------------------
!
! To build VSTADOC.EXE, which is the program that generates VAXstation
! on-line documents.
!
!------------------------------------------------------------------------

vstadoc.exe : doc.obj, doccmd.obj, docdcl.obj, docdeb.obj, -
	docdisp.obj, docedf.obj, docerr.obj, docerrs.obj, -
	docfile.obj, docfld.obj, docfont.obj, -
	docgen.obj, doctoc.obj, docidx.obj, dockwd.obj, -
	doclex.obj, doclib.obj, docovl.obj, -
	docrno.obj, docpagbrk.obj, docrvw.obj, -
	doctilda.obj, vt100.obj, ident.opt, ldoc.opt, -
	vstalib.olb

	$!---------------------------------------------------
	$! LDOC.COM - Command file to load VSTADOC
	$!
	$WRITE SYS$OUTPUT "[Creating VSTADOC.EXE]"
	$LINK /EXEC=VSTADOC -
		VT100, -
		LDOC.OPT/OPTION, -
		IDENT.OPT/OPTION, -
		SYS$LIBRARY:RECOG/LIB, -
		vsta$library:vstalib/lib
	$!
	$! And a debugging version..
	$!
	$WRITE SYS$OUTPUT "[Creating VSTADOCD.EXE]"
	$LINK /DEBUG/EXEC=VSTADOCD -
		VT100, -
		IDENT.OPT/OPT, -
		LDOC.OPT/OPTION, -
		SYS$LIBRARY:RECOG/LIB, -
		vsta$library:vstalib/lib
	$!
	$! ---------- [END OF LDOC.COM] ------------------

doc.obj : vsta$source:doc.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOC

doccmd.obj : vsta$source:doccmd.b32, docfile.l32, docdata.l32, docmacs.l32, -
	     txtsym.req
	$ BLISS/DEBUG vsta$source:DOCCMD

docdcl.obj : vsta$source:docdcl.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCDCL

docdeb.obj : vsta$source:docdeb.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCDEB

docdisp.obj : vsta$source:docdisp.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCDISP

docedf.obj : vsta$source:docedf.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCEDF

docerr.obj : vsta$source:docerr.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCERR

docerrs.obj : vsta$source:docerrs.msg
	$ MESSAGE vsta$source:DOCERRS

docfile.obj : vsta$source:docfile.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCFILE

docfld.obj : vsta$source:docfld.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCFLD

docfont.obj : vsta$source:docfont.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCFONT

docgen.obj : vsta$source:docgen.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCGEN

docidx.obj : vsta$source:docidx.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCIDX

dockwd.obj : vsta$source:dockwd.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCKWD

doclex.obj : vsta$source:doclex.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCLEX

doclib.obj : vsta$source:doclib.b32, docmacs.l32, vstagbl.l32
	$ BLISS/DEBUG vsta$source:DOCLIB

docovl.obj : vsta$source:docovl.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCOVL

docpagbrk.obj : vsta$source:docpagbrk.b32, docfile.l32, docdata.l32, -
		docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCPAGBRK

docrno.obj : vsta$source:docrno.b32, docfile.l32, docdata.l32, docmacs.l32, -
	     txtsym.req
	$ BLISS/DEBUG vsta$source:DOCRNO

docrvw.obj : vsta$source:docrvw.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCRVW

doctilda.obj : vsta$source:doctilda.b32, docfile.l32, docdata.l32, docmacs.l32
	$ BLISS/DEBUG vsta$source:DOCTILDA

doctoc.obj : vsta$source:doctoc.b32, docfile.l32, docdata.l32, docmacs.l32, -
	     txtsym.req
	$ BLISS/DEBUG vsta$source:DOCTOC

vt100.obj : vsta$source:vt100.b32
	$ BLISS/DEBUG vsta$source:vt100

!--------------------------------------------------------------------------
! 			Require files for on line doc
!--------------------------------------------------------------------------

docdata.l32 : vsta$source:docdata.sdl
!	$ SDL/LANG=BLISSF VSTA$SOURCE:DOCDATA
    	$ cms fetch docdata.r32 "test2 call"
	$ BLISS/LIBRARY DOCDATA.R32
	$ COPY DOCDATA.L32 VSTA$LIBRARY

docmacs.l32 : vsta$source:docmacs.r32
	$ BLISS/LIBRARY vsta$source:DOCMACS.R32
	$ COPY DOCMACS.L32 VSTA$LIBRARY


!--------------------------------------------------------------------------
! To build and install new sharable library, type MMS vstashr.exe
!
vstashr.exe :	vstalib.olb, vstalibtv.obj, vstaerrs.exe, vstamsg.r32, -
		vstastub.obj, vsstuberr.obj, vsta$com:buildshr.com, -
		buildshr.com, ident.opt
    	$ copy vstvstub.obj	vsta$build
    	$ copy vstastub.obj 	vsta$build
    	$ copy vsstuberr.obj	vsta$build 
	$ @VSTA$COM:BUILDSHR


cglshr.exe : vstacgl.olb, vstacgltv.obj, vstamsg.obj, vstastub.obj, -
		vsstuberr.obj, vsta$com:bldcglshr.com, -
		bldcglshr.com, ident.opt
	$ purge vsta$source
	$ @VSTA$COM:BLDCGLSHR


vstalib.olb : vxslib.obj, vstangi.obj, vxsfont.obj, vstalibi.obj, -
		vxspack.obj, vstatblet.obj, vstamouse.obj, vstatext.obj, -
		vstargn.obj, vstamsg.obj
	$LIBRARY/CREATE VSTALIB -
	 VXSLIB, -
	 VSTANGI, -
	 VXSFONT, -
	 VXSPACK, -
	 VSTARGN, -
	 VSTATBLET, -
	 VSTATEXT, -
	 VSTALIBI, -
	 VSTAMOUSE, -
	 VSTAMSG
	$COPY VSTALIB.OLB VSTA$LIBRARY:
    	$copy vstalib.olb vsta$build:

vstastub.obj : vsta$source:vstastub.b32, libmacros.l32
	$BLISS VSTA$SOURCE:VSTASTUB
        $copy vstastub.obj vsta$build:

vstalibtv.obj : vsta$source:vstalibtv.mar, vstvmacs.mlb, vstvstub.mlb
	$MACRO VSTA$SOURCE:VSTALIBTV + VSTA$LIBRARY:VSTVMACS/LIB
	$MACRO/OBJ=VSTVSTUB VSTA$SOURCE:VSTALIBTV + VSTA$LIBRARY:VSTVSTUB/LIB
        $copy vstalibtv.obj vsta$build:

vstacgltv.obj : vsta$source:vstacgltv.mar, vstvmacs.mlb, vstvstub.mlb
	$MACRO VSTA$SOURCE:VSTACGLTV + VSTA$LIBRARY:VSTVMACS/LIB
	$MACRO/OBJ=CGLTVSTUB VSTA$SOURCE:VSTACGLTV + VSTA$LIBRARY:VSTVSTUB/LIB
    	$copy vstastub.obj vsta$build:

vstvmacs.mlb : vsta$source:vstvmacs.mar
	$LIBRARY/CREATE/LIST/LOG/MACRO VSTVMACS VSTA$SOURCE:VSTVMACS
	$COPY VSTVMACS.MLB VSTA$LIBRARY:

vstvstub.mlb : vsta$source:vstvstub.mar
	$LIBRARY/CREATE/LIST/LOG/MACRO VSTVSTUB VSTA$SOURCE:VSTVSTUB
	$COPY VSTVSTUB.MLB VSTA$LIBRARY:

vstacgl.olb :	VSCGLAT.OBJ, VSCGLCA.OBJ, VSCGLCL.OBJ,  -
		VSCGLCO.OBJ, VSCGLCU.OBJ, VSCGLDP.OBJ, -
		VSCGLDR.OBJ, VSCGLFI.OBJ, VSCGLLI.OBJ, VSCGLMA.OBJ, -
		VSCGLMO.OBJ, VSCGLSE.OBJ, VSCGLSF.OBJ, VSCGLTR.OBJ,  -
		VSCGLTX.OBJ, VSCGLUT.OBJ, VSCGLVW.OBJ
	$LIBRARY/CREATE VSTACGL -
		VSCGLAT,  VSCGLCA,  VSCGLCL, -
		VSCGLCO,  VSCGLCU,  VSCGLDP, -
		VSCGLDR,  VSCGLFI,  VSCGLLI, VSCGLMA, -
		VSCGLMO,  VSCGLSE,  VSCGLSF, VSCGLTR, -
		VSCGLTX,  VSCGLUT,  VSCGLVW
	$COPY VSTACGL.OLB VSTA$LIBRARY:

VSCGLAT.OBJ : VSTA$SOURCE:VSCGLAT.PAS, VSCGLDEF.PAS
		$PAS/noopt/NOWARN/DEB VSTA$SOURCE:VSCGLAT.PAS
VSCGLCA.OBJ : VSTA$SOURCE:VSCGLCA.B32
		$BLISS VSTA$SOURCE:VSCGLCA.B32
VSCGLCL.OBJ : VSTA$SOURCE:VSCGLCL.PAS, VSCGLDEF.PAS
		$PAS/noopt/NOWARN/DEB VSTA$SOURCE:VSCGLCL.PAS
VSCGLCO.OBJ : VSTA$SOURCE:VSCGLCO.PAS, VSCGLDEF.PAS
		$PAS/noopt/NOWARN/DEB VSTA$SOURCE:VSCGLCO.PAS
VSCGLCU.OBJ : VSTA$SOURCE:VSCGLCU.PAS, VSCGLDEF.PAS
		$PAS/noopt/NOWARN/DEB VSTA$SOURCE:VSCGLCU.PAS
VSCGLDP.OBJ : VSTA$SOURCE:VSCGLDP.B32, VSCGLDP.R32, VSACPDEF.R32, VXSLIB.R32
		$BLISS VSTA$SOURCE:VSCGLDP.B32
VSCGLDR.OBJ : VSTA$SOURCE:VSCGLDR.PAS, VSCGLDEF.PAS
		$PAS/noopt/NOWARN/DEB VSTA$SOURCE:VSCGLDR.PAS
VSCGLFI.OBJ : VSTA$SOURCE:VSCGLFI.PAS, VSCGLDEF.PAS
		$PAS/noopt/NOWARN/DEB VSTA$SOURCE:VSCGLFI.PAS
VSCGLLI.OBJ : VSTA$SOURCE:VSCGLLI.PAS, VSCGLDEF.PAS
		$PAS/noopt/NOWARN/DEB VSTA$SOURCE:VSCGLLI.PAS
VSCGLMA.OBJ : VSTA$SOURCE:VSCGLMA.PAS, VSCGLDEF.PAS
		$PAS/noopt/NOWARN/DEB VSTA$SOURCE:VSCGLMA.PAS
VSCGLMO.OBJ : VSTA$SOURCE:VSCGLMO.PAS, VSCGLDEF.PAS
		$PAS/noopt/NOWARN/DEB VSTA$SOURCE:VSCGLMO.PAS
VSCGLSE.OBJ : VSTA$SOURCE:VSCGLSE.PAS, VSCGLDEF.PAS
		$PAS/noopt/NOWARN/DEB VSTA$SOURCE:VSCGLSE.PAS
VSCGLSF.OBJ : VSTA$SOURCE:VSCGLSF.PAS, VSCGLDEF.PAS
		$PAS/noopt/NOWARN/DEB VSTA$SOURCE:VSCGLSF.PAS
VSCGLTR.OBJ : VSTA$SOURCE:VSCGLTR.PAS, VSCGLDEF.PAS
		$PAS/noopt/NOWARN/DEB VSTA$SOURCE:VSCGLTR.PAS
VSCGLTX.OBJ : VSTA$SOURCE:VSCGLTX.PAS, VSCGLDEF.PAS
		$PAS/noopt/NOWARN/DEB VSTA$SOURCE:VSCGLTX.PAS
VSCGLUT.OBJ : VSTA$SOURCE:VSCGLUT.PAS, VSCGLDEF.PAS
		$PAS/noopt/NOWARN/DEB VSTA$SOURCE:VSCGLUT.PAS
VSCGLVW.OBJ : VSTA$SOURCE:VSCGLVW.PAS, VSCGLDEF.PAS
		$PAS/noopt/NOWARN/DEB VSTA$SOURCE:VSCGLVW.PAS

VSCGLDP.R32 : VSTA$SOURCE:VSCGLDP.SDL
!		$SDL/LANG=(BLISS) VSTA$SOURCE:VSCGLDP.SDL
    		$cms fetch vscgldp.r32 "test2 mms call"
		$COPY VSCGLDP.R32 VSTA$LIBRARY:

VSCGLDEF.PAS : VSTA$SOURCE:VSCGLDEF.PAS
		$COPY VSTA$SOURCE:VSCGLDEF.PAS VSTA$LIBRARY:VSCGLDEF.PAS
		$COPY VSTA$SOURCE:VSCGLDEF.PAS VSTA$BUILD:VSCGLDEF.PAS

VSCGLDP.REQ : VSTA$SOURCE:VSCGLDP.REQ
		$COPY VSTA$SOURCE:VSCGLDP.REQ VSTA$LIBRARY:VSCGLDP.REQ
		$COPY VSTA$SOURCE:VSCGLDP.REQ VSTA$BUILD:VSCGLDP.REQ
!
! To build new VDDRIVER, type MMS vddriver.exe
!
vddriver.exe : vddriver.obj, vsta$com:vddl.com, vd.opt, -
		ident.opt
!	$ @VSTA$COM:VDDL.COM	!Creates VDDRIVER.EXE
	$link/notrace/map/full/cross -
	 vddriver,vd.opt/opt,ident.opt/opt,sys$system:sys.stb/selective

!
! To build new VBDRIVER, type MMS vbdriver.exe
!
vbdriver.exe : vbdriver.obj, vbsub.obj, vbend.obj, vbfdt.obj, -
		vbset.obj, vsta$com:dlnk.com, driver.opt, -
		ident.opt
!	$ @VSTA$COM:DLNK
	$link/nodebug/notrace/map/full/cross vbdriver,vbfdt,vbset,vbsub,vbend,-
	 IDENT.OPT/OPT,-
	 DRIVER.OPT/OPTIONS,-
	 sys$system:sys.stb/selective

!
! To build new STARTACP, type MMS startacp.exe
!
startacp.exe : startacp.obj, vsacpprms.obj, ident.opt
	$LINK/EXEC=STARTACP  STARTACP, -
			     VSACPPRMS, -
			     IDENT.OPT/OPT, -
			     SYS$SYSTEM:SYS.STB/SELECT
!
! To build new VSHILOGN (our version of the LOGINOUT image),
! type MMS vshilogn.exe
!
vshilogn.exe : audit.obj, breakin.obj, detached.obj, fileio.obj, -
		hpwd.obj, inituser.obj, interact.obj, libdaywk.obj, -
		libhour.obj, login.obj, protcli.obj, validate.obj, -
		loginlnk.com, messages.obj, ident.opt
	$ copy	vsta$library:cliutl.olb *
	$ purge vsta$build
	$ @vsta$com:loginlnk

!
! To build new VSTAERRS, type MMS vstaerrs.exe
!
vstaerrs.exe : vsta$source:vstaerrs.msg, vsta$source:vsstuberr.msg, -
		buildmsg.com, ident.opt
	$ @vsta$com:buildmsg


!
! To build new STOPACP, type MMS stopacp.exe
!
stopacp.exe : stopacp.obj, getstop.obj, ident.opt
	$LINK/EXEC=STOPACP  STOPACP, GETSTOP, -
		IDENT.OPT/OPT, -
		SYS$SYSTEM:SYS.STB/SELECT
		
!
! To build new STOPACPS, type MMS stopacps.exe
!
stopacps.exe : stopacps.obj, ident.opt
	$LINK/EXEC=STOPACPS STOPACPS, IDENT.OPT/OPT, -
		SYS$SYSTEM:SYS.STB/SELECT
		
!
! To build everything and put the right stuff into VSTA$EXE,
!  type MMS everything
!
everything : kit, vstadoc.exe
	$COPY VSTADOC.EXE VSTA$EXE:

! To build only the kit files, and put the right stuff into VSTA$EXE,
!  type MMS KIT
!
kit : vsacp.exe, vddriver.exe, startacp.exe, stopacp.exe, -
		stopacps.exe, vstashr.exe, cglshr.exe, vstaerrs.exe, -
		vbdriver.exe, vshilogn.exe, vstaprint.exe
	$COPY VSACP*.EXE VSTA$EXE:
	$COPY VSACP.MAP VSTA$EXE:
	$COPY VDDRIVER.EXE VSTA$EXE:
	$COPY VBDRIVER.EXE VSTA$EXE:
	$COPY STARTACP.EXE VSTA$EXE:
	$COPY STOPACP.EXE VSTA$EXE:
	$COPY STOPACPS.EXE VSTA$EXE:
	$COPY VSHILOGN.EXE VSTA$EXE:
	$COPY VSTAPRINT.EXE VSTA$EXE:



!-------------------------------------------------------------------------
! 		dependencies on the ACP object files
!-------------------------------------------------------------------------

vstaresrc.obj :	vsta$source:vstaresrc.b32, vserrors.l32, vstamacs.l32, -
		libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSTARESRC.B32

acpdspch.obj : vsta$source:acpdspch.b32, vsvkb.l32, ttydefs.l32,vserrors.l32, -
		vsvdsvd.l32, VSVDSVDC.l32, vsacpdef.l32, linkage.l32, -
		libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:ACPDSPCH.B32

buildver.obj : vsta$source:buildver.b32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:BUILDVER.B32

vstadmm.obj : vsta$source:vstadmm.b32, vstadef.r32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSTADMM.B32

vstamove.obj : vsta$source:vstamove.b32, vstamacs.l32, vstanativ.l32, -
		vstagbl.l32, vstadef.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSTAMOVE.B32

vsprint.obj : vsta$source:vsprint.b32, vstamacs.l32, vstanativ.l32, -
		vstagbl.l32, vstadef.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:vsprint.B32

vstakrnl.obj : vsta$source:vstakrnl.b32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:vstakrnl.B32

menus.obj : vsta$source:menus.b32, -
		vsacpdef.l32, vserrors.l32, ttydefs.l32, libmacros.l32, -
		vsvdsvd.l32, txtsym.l32, vstanativ.l32, vstagbl.l32
	$BLISS/DEBUG VSTA$SOURCE:menus.B32

mainmenu.obj : vsta$source:mainmenu.b32, -
		vssrvdata.l32, vsvssvs.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:mainmenu.B32

hlpbutton.obj : vsta$source:hlpbutton.b32, -
		vssrvdata.l32, vsvssvs.l32, libmacros.l32, vsvdspb.l32, -
		vserrors.l32, vstamacs.l32
	$BLISS/DEBUG VSTA$SOURCE:hlpbutton.B32

pmesetimr.obj :	vsta$source:pmesetimr.b32
	$ bliss/debug vsta$source:pmesetimr

npmeclock.obj :	vsta$source:npmeclock.mar, pmedefs.mlb
	$ macro/debug vsta$source:npmeclock

pmedefs.mlb :	vsta$source:pmedefs.mar
	$ library/macro/create pmedefs.mlb vsta$source:pmedefs.mar

regions.obj : vsta$source:regions.b32, vsvdsvd.l32, -
		txtcodes.l32, vsvssvs.l32, vsvdspb.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:regions.B32

mouseast.obj : vsta$source:mouseast.b32, -
		vsvdspb.l32, vsacpdef.l32, vsvtb.l32, libmacros.l32, termio.l32
	$BLISS/DEBUG VSTA$SOURCE:mouseast.B32

mousebtns.obj : vsta$source:mousebtns.b32, vstagbl.l32, -
		vsvdspb.l32, vsvtb.l32, VSTADEF.l32, VSVSSVS.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:mousebtns.B32

mouseloc.obj : vsta$source:mouseloc.b32, -
		vsvssvs.l32, -
		vsvdspb.l32, vsvtb.l32, VSTADEF.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:mouseloc.B32

mousertns.obj : vsta$source:mousertns.b32, txtsym.l32, -
		vsvdspb.l32, vsvtb.l32, VSTADEF.l32, VSVSSVS.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:mousertns.B32

shostk.obj : vsta$source:shostk.b32, termio.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:SHOSTK.B32

sobgtr.obj : vsta$source:sobgtr.mar
	$MACRO VSTA$SOURCE:SOBGTR.MAR

termnl.obj : vsta$source:termnl.b32, termio.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:TERMNL.B32

vsusage.obj : vsta$source:vsusage.b32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSUSAGE.B32

!-------------------------------------------------------------------
! 			TXT modules
!-------------------------------------------------------------------

txtalloc8.obj : vsta$source:txtalloc8.b32, txtsym.l32, termio.l32, -
		libmacros.l32, vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:TXTALLOC8.B32

txtdelete.obj : vsta$source:txtdelete.b32, txtsym.l32, termio.l32, -
		libmacros.l32, vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:TXTDELETE.B32

txtdiag.obj : vsta$source:txtdiag.b32, txtsym.l32, termio.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:TXTDIAG.B32

txtfields.obj : vsta$source:txtfields.b32, txtsym.l32, termio.l32, -
		libmacros.l32, vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:TXTFIELDS.B32

txtfile.obj : vsta$source:txtfile.b32, txtsym.l32, termio.l32, -
		libmacros.l32, vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:TXTFILE.B32

txtfont.obj : vsta$source:txtfont.b32, txtsym.l32, termio.l32, -
		VSACPDEF.l32, vserrors.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:TXTFONT.B32

txtinit.obj : vsta$source:txtinit.b32, txtsym.l32, vserrors.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:TXTINIT.B32

txtlines.obj : vsta$source:txtlines.b32, txtsym.l32, termio.l32, -
		libmacros.l32, vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:TXTLINES.B32

txtlists.obj : vsta$source:txtlists.b32, txtsym.l32, termio.l32, -
		libmacros.l32, vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:TXTLISTS.B32

txtpublic.obj : vsta$source:txtpublic.b32, txtsym.l32, termio.l32, -
		libmacros.l32, vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:TXTPUBLIC.B32

txtsetmod.obj : vsta$source:txtsetmod.b32, txtsym.l32, termio.l32, -
		libmacros.l32, vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:TXTSETMOD.B32

txtstring.obj : vsta$source:txtstring.b32, txtsym.l32, termio.l32, -
		libmacros.l32, vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:TXTSTRING.B32

txtwrite.obj : vsta$source:txtwrite.b32, txtsym.l32, termio.l32, -
		libmacros.l32, vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:TXTWRITE.B32
!

vsacp.obj : vsta$source:vsacp.b32, vsast.l32, vbdef.l32, vsvkb.l32, -
	    ttydefs.l32, vsvdsvd.l32, vsvdsvdc.l32, vsacpdef.l32, linkage.l32,-
	    VSERRORS.L32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSACP.B32

track.obj : vsta$source:track.b32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:TRACK.B32

vstaccess.obj : vsta$source:vstaccess.b32, linkage.l32, vsvdspb.l32, -
		libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSTACCESS.B32

pidaccess.obj : vsta$source:pidaccess.b32, libmacros.l32, vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:PIDACCESS.B32

vsbrdcst.obj : vsta$source:vsbrdcst.mar, vsmacros.mlb
	$MACRO/DEBUG/LIST VSTA$SOURCE:VSBRDCST.MAR + VSTA$LIBRARY:VSMACROS/LIB -
	+ SYS$LIBRARY:LIB/LIB

vsemul.obj : vsta$source:vsemul.b32, vssrvdata.l32, vstanativ.l32, -
		vserrors.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSEMUL.B32

vserrargh.obj : vsta$source:vserrargh.b32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSERRARGH.B32

vserrors.obj : vsta$source:vserrors.b32, VSERRORS.R32
	$BLISS/DEBUG VSTA$SOURCE:VSERRORS.B32

vsgenem.obj : vsta$source:vsgenem.b32, vsvdsvd.l32, vxslib.r32, -
		vsgenem.r32, txtcodes.l32, vserrors.l32, vstagbl.l32, -
		libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSGENEM.B32


!--------------------------------------------------------------------------
! 			GIDIS modules
!--------------------------------------------------------------------------

BLISS = bliss/term=stat/debug/machine=(assemb,binary)/source=(noheader,expand)
BLISSL = bliss/source=(noheader,expand,require)/library

VSGIAL.L32 : VSTA$SOURCE:VSGIAL.REQ
    $(BLISSL) VSTA$SOURCE:VSGIAL.REQ
    COPY VSGIAL.L32 VSTA$LIBRARY:VSGIAL.L32

VSGIAL.OBJ : VSTA$SOURCE:VSGIAL.BLI -
	VSTASYMS.L32 -
	VSGICX.L32 -
	VSGIRM.L32 -
	VSGISF.L32 -
	libmacros.l32
    $(BLISS) VSTA$SOURCE:VSGIAL.BLI

VSGIAS.L32 : VSTA$SOURCE:VSGIAS.REQ
    $(BLISSL) VSTA$SOURCE:VSGIAS.REQ
    COPY VSGIAS.L32 VSTA$LIBRARY:VSGIAS.L32

VSGIAS.OBJ : VSTA$SOURCE:VSGIAS.BLI, VSTASYMS.L32 -
	VSGIAL.L32 -
	VSGIPA.L32 -
	VSGING.L32 -
	VSGISF.L32 -
	VSGICX.L32 -
	libmacros.l32
    $(BLISS) VSTA$SOURCE:VSGIAS.BLI

VSGICC.L32 : VSTA$SOURCE:VSGICC.REQ
    $(BLISSL) VSTA$SOURCE:VSGICC.REQ
    COPY VSGICC.L32 VSTA$LIBRARY:VSGICC.L32

VSGICC.OBJ : VSTA$SOURCE:VSGICC.BLI, VSTASYMS.L32, libmacros.l32 -
	VSGISF.L32 -
	VSGICX.L32 -
	VSGIRM.L32 -
	VSGING.L32 -
	VSGIAL.L32
    $(BLISS) VSTA$SOURCE:VSGICC.BLI

VSGICX.L32 : VSTA$SOURCE:VSGICX.REQ
    $(BLISSL) VSTA$SOURCE:VSGICX.REQ
    COPY VSGICX.L32 VSTA$LIBRARY:VSGICX.L32

VSGICX.OBJ : VSTA$SOURCE:VSGICX.BLI, libmacros.l32 -
	VSGING.L32 -
	VSGISF.L32 -
	VSGIAS.L32
    $(BLISS) VSTA$SOURCE:VSGICX.BLI

VSGILP.L32 : VSTA$SOURCE:VSGILP.REQ
    $(BLISSL) VSTA$SOURCE:VSGILP.REQ
    COPY VSGILP.L32 VSTA$LIBRARY:VSGILP.L32

VSGILP.OBJ : VSTA$SOURCE:VSGILP.BLI, VSTASYMS.L32, libmacros.l32 -
	VSGISF.L32 -
	VSGING.L32
    $(BLISS) VSTA$SOURCE:VSGILP.BLI

VSGIOD.L32 : VSTA$SOURCE:VSGIOD.REQ
    $(BLISSL) VSTA$SOURCE:VSGIOD.REQ
    COPY VSGIOD.L32 VSTA$LIBRARY:VSGIOD.L32

VSGIOD.OBJ : VSTA$SOURCE:VSGIOD.BLI, libmacros.l32 -
	VSGISF.L32 -
	VSGIOPS.L32 -
	VSGISM.L32 -
	VSGIPP.L32 -
	VSGIPL.L32 -
	VSGICX.L32 -
	VSGIAS.L32 -
	VSGIPA.L32 -
	VSGICC.L32 -
	VSGIAL.L32
    $(BLISS) VSTA$SOURCE:VSGIOD.BLI

VSGIOPS.L32 : VSTA$SOURCE:VSGIOPS.REQ
    $(BLISSL) VSTA$SOURCE:VSGIOPS.REQ
    COPY VSGIOPS.L32 VSTA$LIBRARY:VSGIOPS.L32

VSGIPA.L32 : VSTA$SOURCE:VSGIPA.REQ
    $(BLISSL) VSTA$SOURCE:VSGIPA.REQ
    COPY VSGIPA.L32 VSTA$LIBRARY:VSGIPA.L32

VSGIPA.OBJ : VSTA$SOURCE:VSGIPA.BLI, libmacros.l32 -
	VSGISF.L32 -
	VSGIPP.L32 -
	VSGISP.L32 -
	VSGILP.L32 -
	VSGICC.L32 -
	VSGICX.L32
    $(BLISS) VSTA$SOURCE:VSGIPA.BLI

VSGIPL.L32 : VSTA$SOURCE:VSGIPL.REQ
    $(BLISSL) VSTA$SOURCE:VSGIPL.REQ
    COPY VSGIPL.L32 VSTA$LIBRARY:VSGIPL.L32

VSGIPL.OBJ : VSTA$SOURCE:VSGIPL.BLI, VSTASYMS.L32, libmacros.l32 -
	VSGISF.L32 -
	VSGING.L32
    $(BLISS) VSTA$SOURCE:VSGIPL.BLI

VSGIPP.L32 : VSTA$SOURCE:VSGIPP.REQ
    $(BLISSL) VSTA$SOURCE:VSGIPP.REQ
    COPY VSGIPP.L32 VSTA$LIBRARY:VSGIPP.L32

VSGIPP.OBJ : VSTA$SOURCE:VSGIPP.BLI, libmacros.l32 -
	VSGISF.L32 -
	VSGICX.L32 -
	VSGIRM.L32 -
	VSGIPA.L32
    $(BLISS) VSTA$SOURCE:VSGIPP.BLI

VSGIRM.L32 : VSTA$SOURCE:VSGIRM.REQ
    $(BLISSL) VSTA$SOURCE:VSGIRM.REQ
    COPY VSGIRM.L32 VSTA$LIBRARY:VSGIRM.L32

VSGIRM.OBJ : VSTA$SOURCE:VSGIRM.BLI, libmacros.l32 -
	VSGISF.L32 -
	VSGISM.L32
    $(BLISS) VSTA$SOURCE:VSGIRM.BLI

VSGISB.L32 : VSTA$SOURCE:VSGISB.REQ
    $(BLISSL) VSTA$SOURCE:VSGISB.REQ
    COPY VSGISB.L32 VSTA$LIBRARY:VSGISB.L32

VSGISF.L32 : VSTA$SOURCE:VSGISF.REQ,VSTA$SOURCE:VSGISB.REQ
    $(BLISSL) VSTA$SOURCE:VSGISF.REQ
    COPY VSGISF.L32 VSTA$LIBRARY:VSGISF.L32

VSGISM.L32 : VSTA$SOURCE:VSGISM.REQ
    $(BLISSL) VSTA$SOURCE:VSGISM.REQ
    COPY VSGISM.L32 VSTA$LIBRARY:VSGISM.L32

VSGISM.OBJ : VSTA$SOURCE:VSGISM.BLI , VSTASYMS.L32, libmacros.l32 -
	VSGISF.L32 -
	VSGIOPS.L32 -
	VSGIOD.L32 -
	VSGIRM.L32 -
	VSGING.L32 -
	VSGIAL.L32
    $(BLISS) VSTA$SOURCE:VSGISM.BLI

VSGISP.L32 : VSTA$SOURCE:VSGISP.REQ
    $(BLISSL) VSTA$SOURCE:VSGISP.REQ
    COPY VSGISP.L32 VSTA$LIBRARY:VSGISP.L32

VSGISP.OBJ : VSTA$SOURCE:VSGISP.BLI, VSTASYMS.L32, libmacros.l32 -
	VSGIAS.L32 -
	VSGISF.L32 -
	VSGING.L32
    $(BLISS) VSTA$SOURCE:VSGISP.BLI

VSGIVD.L32 : VSTA$SOURCE:VSGIVD.REQ
    $(BLISSL) VSTA$SOURCE:VSGIVD.REQ
    COPY VSGIVD.L32 VSTA$LIBRARY:VSGIVD.L32

VSGING.L32 : VSTA$SOURCE:VSGING.REQ
    $(BLISSL) VSTA$SOURCE:VSGING.REQ
    COPY VSGING.L32 VSTA$LIBRARY:VSGING.L32


!---------------------------------------------------------------------
! 			HI modules
!---------------------------------------------------------------------

vssrvann.obj : vsta$source:vssrvann.b32, vssrvdata.l32, -
		libmacros.l32, vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVANN.B32

vssrvauth.obj : vsta$source:vssrvauth.b32, vssrvdata.l32, -
		vstanativ.l32, vstagbl.l32, vsacpdef.r32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVAUTH.B32

vssrvcmd.obj : vsta$source:vssrvcmd.b32, vssrvmacs.l32, vssrvdata.l32, -
		vserrors.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVCMD.B32

vssrvdeb.obj : vsta$source:vssrvdeb.b32, vssrvmacs.l32, vssrvdata.l32, -
		libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVDEB.B32

vssrvedit.obj : vsta$source:vssrvedit.b32, vssrvdata.l32, vserrors.l32, -
		libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVEDIT.B32

vssrvfmio.obj : vsta$source:vssrvfmio.b32, vserrors.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVFMIO.B32

vssrvfoot.obj : vsta$source:vssrvfoot.b32, vssrvdata.l32, -
		vstanativ.l32, vstamacs.l32, vstadef.l32, vstagbl.l32, -
		libmacros.l32, txtsym.l32, vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVFOOT.B32

vssrvform.obj : vsta$source:vssrvform.b32, docfile.L32, -
		vssrvdata.l32, vstanativ.l32, vstagbl.l32, vstaterm.l32, -
		vsacpdef.l32, libmacros.l32, vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVFORM.B32

vssrvhold.obj : vsta$source:vssrvhold.b32, vssrvdata.l32, vserrors.l32, -
		libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVHOLD.B32

vssrvinit.obj : vsta$source:vssrvinit.b32, vssrvdata.l32, -
		vstaterm.l32, vserrors.l32, vsacpdef.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVINIT.B32

vssrvintr.obj : vsta$source:vssrvintr.b32, docfile.L32, vserrors.l32, -
		vssrvdata.l32, vstasyms.l32, vstaterm.l32, -
		vstekem.l32, vsvtem100.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVINTR.B32

vssrvjob.obj : vsta$source:vssrvjob.b32, vserrors.l32, vssrvdata.l32, -
		loginmsg.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVJOB.B32

vssrvmenu.obj : vsta$source:vssrvmenu.b32, vserrors.l32, vssrvdata.l32, -
		vstanativ.l32, vstagbl.l32, vsacpdef.l32, docfile.l32, -
		vstamf.l32, libmacros.l32, vstaterm.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVMENU.B32

vssrvprof.obj : vsta$source:vssrvprof.b32, vserrors.l32, libmacros.l32, -
		vstaterm.l32, vsvtem100.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVPROF.B32

vssrvsel.obj : vsta$source:vssrvsel.b32, vserrors.l32, vssrvdata.l32, -
		vstasyms.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVSEL.B32

vssrvsymb.obj : vsta$source:vssrvsymb.b32, libmacros.l32, vserrors.l32, -
		vsvdspb.l32, vssrvsymb.l32, vstanativ.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVSYMB.B32

vssrvts.obj : vsta$source:vssrvts.b32, docfile.l32, libmacros.l32, -
		vserrors.l32, vssrvdata.l32, vsvdsvd.l32, -
		vsvtem100.l32, vstekem.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVTS.B32

vssrvvds.obj : vsta$source:vssrvvds.b32, vssrvdata.l32, -
		vstaterm.l32, vstanativ.l32, vsacpdef.l32, libmacros.l32, -
		vstagbl.l32, vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVVDS.B32

vssrvvss.obj : vsta$source:vssrvvss.b32, vssrvdata.l32, -
		vstaterm.l32, vstanativ.l32, vstagbl.l32, vsacpdef.l32, -
		libmacros.l32, vsvdsvd.l32,  vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:VSSRVVSS.B32

vstahival.obj : vsta$source:vstahival.mar
	$MACRO/DEBUG VSTA$SOURCE:VSTAHIVAL.MAR + SYS$LIBRARY:LIB/LIB

vstacom.obj : vsta$source:vstacom.b32, vxslib.r32, vserrors.l32, -
		vstaterm.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSTACOM.B32

vscomdeb.obj : vsta$source:vscomdeb.b32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSCOMDEB.B32

!!!

audit.obj : vsta$source:audit.b32
	$BLISS/DEBUG VSTA$SOURCE:AUDIT.B32

breakin.obj : vsta$source:breakin.b32
	$BLISS/DEBUG VSTA$SOURCE:BREAKIN.B32

detached.obj : vsta$source:detached.b32, utildef.req, ppddef.b32, -
		lgidef.b32
	$DEFINE LIB$ VSTA$LIBRARY:
	$DEFINE SHRLIB$ VSTA$LIBRARY:
	$BLISS/DEBUG VSTA$SOURCE:DETACHED.B32

fileio.obj : vsta$source:fileio.b32, utildef.req, ppddef.b32, -
		lgidef.b32
	$DEFINE LIB$ VSTA$LIBRARY:
	$DEFINE SHRLIB$ VSTA$LIBRARY:
	$BLISS/DEBUG VSTA$SOURCE:FILEIO.B32

hpwd.obj : vsta$source:hpwd.mar
	$MACRO/DEBUG VSTA$SOURCE:HPWD.MAR

inituser.obj : vsta$source:inituser.b32, utildef.req, ppddef.b32, -
		net.l32
	$DEFINE LIB$ VSTA$LIBRARY:
	$DEFINE SHRLIB$ VSTA$LIBRARY:
	$BLISS/DEBUG VSTA$SOURCE:INITUSER.B32

interact.obj : vsta$source:interact.b32, utildef.req, ppddef.b32, -
		lgidef.b32
	$DEFINE LIB$ VSTA$LIBRARY:
	$DEFINE SHRLIB$ VSTA$LIBRARY:
	$BLISS/DEBUG VSTA$SOURCE:INTERACT.B32

libdaywk.obj : vsta$source:libdaywk.mar
	$MACRO/DEBUG VSTA$SOURCE:LIBDAYWK.MAR

libhour.obj : vsta$source:libhour.mar
	$MACRO/DEBUG VSTA$SOURCE:LIBHOUR.MAR

login.obj : vsta$source:login.b32, utildef.req, ppddef.b32, -
		lgidef.b32, intdef.r32
	$DEFINE LIB$ VSTA$LIBRARY:
	$DEFINE SHRLIB$ VSTA$LIBRARY:
	$BLISS/DEBUG VSTA$SOURCE:LOGIN.B32

!!!

protcli.obj : vsta$source:protcli.mar, login.mlb
	$MACRO/DEBUG VSTA$SOURCE:PROTCLI.MAR + SYS$LIBRARY:LIB/LIB + VSTA$LIBRARY:LOGIN/LIB

validate.obj : vsta$source:validate.b32
	$BLISS/DEBUG VSTA$SOURCE:VALIDATE.B32

messages.obj : vsta$source:messages.msg
	$MESSAGE VSTA$SOURCE:MESSAGES.MSG

utildef.req : vsta$source:utildef.req
	$COPY VSTA$SOURCE:UTILDEF.REQ *
	$COPY UTILDEF.REQ VSTA$LIBRARY:

ppddef.b32 : vsta$source:ppddef.b32
	$COPY PPDDEF.B32 VSTA$LIBRARY:

lgidef.b32 : vsta$source:lgidef.b32
	$COPY LGIDEF.B32 VSTA$LIBRARY:

intdef.r32 : vsta$source:intdef.r32
	$COPY VSTA$SOURCE:INTDEF.R32 *
	$COPY INTDEF.R32 VSTA$LIBRARY:

net.l32 : vsta$source:net.l32
	$COPY VSTA$SOURCE:NET.L32 *
	$COPY NET.L32 VSTA$LIBRARY:

login.mlb : vsta$source:ppddef.b32, vsta$source:lgidef.b32, -
	    vsta$source:ppddef.mar, vsta$source:lgidef.mar
	$COPY PPDDEF.B32,LGIDEF.B32 VSTA$LIBRARY:
	$LIB/CREATE/MACRO LOGIN.MLB PPDDEF.MAR,LGIDEF.MAR
	$COPY LOGIN.MLB VSTA$LIBRARY:
	
vstarects.obj : vsta$source:vstarects.b32, vstasyms.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSTARECTS.B32

vstadrive.obj : vsta$source:vstadrive.b32, vstamacs.l32, vstanativ.r32, -
		vstadef.l32, vstagbl.l32, libmacros.l32, vbdef.r32, linkage.r32
	$BLISS/DEBUG VSTA$SOURCE:VSTADRIVE.B32

vbcontrol.obj : vsta$source:vbcontrol.b32, vstasyms.l32, -
		vserrors.l32, vbdef.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VBCONTROL.B32

vstanativ.obj : vsta$source:vstanativ.b32, vstasyms.l32, -
		vserrors.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSTANATIV.B32

vstaque.obj : vsta$source:vstaque.b32, vsvdsvdc.r32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSTAQUE.B32

vstaqio.obj : vsta$source:vstaqio.b32, txtsym.req, linkage.l32, termio.l32, -
		vsacpdef.r32, VSVDSVD.R32
	$BLISS/DEBUG VSTA$SOURCE:VSTAQIO.B32

vstekem.obj : vsta$source:vstekem.b32, vstekem.l32, vsgidis.req, vsvdsvd.l32, -
		vstaterm.l32, VSACPDEF.L32, vstamacs.l32, txtsym.l32, -
		libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSTEKEM.B32

vstekfo.obj : vsta$source:vstekfo.b32, vstekem.l32, txtsym.l32, vstagbl.l32, -
		libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSTEKFO.B32

vstekcu.obj : vsta$source:vstekcu.b32, vstekem.l32, -
		vsvdsvd.l32, vsgidis.req
	$BLISS/DEBUG VSTA$SOURCE:VSTEKCU.B32

vsvdspb.obj : vsta$source:vsvdspb.b32, LIBMACROS.l32, vsvdspb.l32, -
		VSACPDEF.l32, VSERRORS.l32, vsvssvs.l32
	$BLISS/DEBUG VSTA$SOURCE:VSVDSPB.B32

vspaste.obj : vsta$source:vspaste.b32, LIBMACROS.l32, vsvdspb.l32, -
		VSACPDEF.l32, VSERRORS.l32
	$BLISS/DEBUG VSTA$SOURCE:vspaste.B32

vswindow.obj : vsta$source:vswindow.b32, LIBMACROS.l32, vsvdspb.l32, -
		VSSRVDATA.L32, VSACPDEF.l32, VSERRORS.l32, VSTAGBL.L32
	$BLISS/DEBUG VSTA$SOURCE:vswindow.B32

vsvdsvd.obj : vsta$source:vsvdsvd.b32, txtsym.l32, vsvdsvd.l32, -
		vstanativ.l32, VSACPDEF.l32, vstasyms.l32, libmacros.l32, -
		vserrors.l32
	$BLISS/DEBUG VSTA$SOURCE:VSVDSVD.B32

vstaodrv.obj : vsta$source:vstaodrv.b32, vstaodrv.r32, vsvkb.r32, -
		libmacros.r32
	$BLISS/DEBUG VSTA$SOURCE:VSTAODRV.B32

vsvdsvdc.obj : vsta$source:vsvdsvdc.b32, vsvdsvdc.r32, vstanativ.r32, -
		vsvdsvd.r32, vstagbl.l32, vstamacs.l32, vstadef.l32, -
		libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSVDSVDC.B32

vsvdsngi.obj : vsta$source:vsvdsngi.b32, vstamacs.l32, vstadef.l32, -
		vstagbl.l32, vstanativ.l32, txtsym.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSVDSNGI.B32

vsvkb.obj : vsta$source:vsvkb.b32, vsvkb.l32, ttydefs.l32, vsacpdef.l32, -
		vstadef.l32, linkage.l32, vbdef.l32, vsvdspb.l32, -
		vserrors.l32, vstagbl.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSVKB.B32

vstakbrd.obj : vsta$source:vstakbrd.b32, vstakbrd.l32, -
		vserrors.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSTAKBRD.B32

vsvtb.obj : vsta$source:vsvtb.b32, vsacpdef.r32, vstadef.r32, vsvtb.r32, -
		vsvdspb.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSVTB.B32

vstaptr.obj : vsta$source:vstaptr.b32, vsacpdef.r32, vsvtb.FLD, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSTAPTR.B32

vstairp.obj : vsta$source:vstairp.b32, vsacpdef.r32, libmacros.r32
	$BLISS/DEBUG VSTA$SOURCE:VSTAirp.B32

vsvssps.obj : vsta$source:vsvssps.b32, vsvssvs.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSVSSPS.B32

vsvssvp.obj : vsta$source:vsvssvp.b32, vssrvmacs.l32,vsvssvs.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSVSSVP.B32

vsvssvs.obj : vsta$source:vsvssvs.b32, vsvssvs.l32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSVSSVS.B32

vsvtem100.obj : vsta$source:vsvtem100.b32, vsvtem100.l32, txtsym.l32, -
		vstaterm.l32, VSACPDEF.l32, vstagbl.r32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSVTEM100.B32

vsvtemgl.obj : vsta$source:vsvtemgl.b32, libmacros.l32
	$BLISS/DEBUG VSTA$SOURCE:VSVTEMGL.B32

vsvt100cu.obj : vsta$source:vsvt100cu.b32, vsvtem100.r32, vsvdsvd.r32
	$BLISS/DEBUG VSTA$SOURCE:VSVT100CU.B32

!---------------------------------------------------------------------------
! require files, libraries, etc., in alphabetical order
!
! Note:  For resourceful .B32 files that use .L32 files instead of .R32 ones,
! we generate the .L32 file from a BLISSF version of the SDL file ONLY.  For
! old-style .B32 files that currently have "ref block[,byte]"'s in them that
! want to start using the .L32 files, such .B32 files MUST be changed to say
! "ref vd_block" or whatever the block type is.
!
! In order not to interfere with old-style .B32 files that expect .R32 files
! to be in the old format, we use the file type .T32 for the intermediate
! file between the .SDL and the .L32.
!
! The .T32 file, being temporary, could be deleted, but it is left around
! in case someone needs to see what actual symbol SDL generated.
!
! We use /NOLIST on the BLISS/LIB to avoid superceding some .B32's .LIS
! file with the one produced for the library.
!
! ***NOTE:***
! To remove dependency on SDL, the calls to SDL have been commented out
! and replaced with calls to CMS to fetch the appropriate require file.
!--------------------------------------------------------------------------

docfile.l32 : vsta$source:docfile.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:docfile
    	$ cms fetch docfile.t32 "test2 call"
	$ bliss/lib/nolist docfile.t32
	$ copy docfile.l32 vsta$library:
!	$ del/nolog docfile.t32.
!
!	************     WARNING                      *************
!	************ important VMS version dependency *************
!
! Login message file from VMS version. Note: If the VMS people
!		change the message file (between releases of VMS)
!		then we must get the new copy of this file.
!
loginmsg.l32 : vsta$source:loginmsg.msg
!	$ message/sdl vsta$source:loginmsg.msg
!	$ sdl/lang=blissf loginmsg
    	$ cms fetch loginmsg.r32 "test2 call"
	$ bliss/lib/nolist loginmsg.r32
	$ copy loginmsg.l32 vsta$library:

termio.l32 : vsta$source:termio.req
	$bliss/lib/nolist VSTA$SOURCE:TERMIO.REQ
	$COPY TERMIO.L32 VSTA$LIBRARY:

ttydefs.r32 : vsta$source:ttydefs.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:TTYDEFS
	$cms fetch ttydefs.r32 "test2 mms call"
	$COPY TTYDEFS.R32 VSTA$LIBRARY:

ttydefs.l32 : vsta$source:ttydefs.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:ttydefs
    	$ cms fetch ttydefs.t32 "test2 call"
	$ bliss/lib/nolist ttydefs.t32
	$ copy ttydefs.l32 vsta$library:
!	$ del/nolog ttydefs.t32.

ttydefs.fld : vsta$source:ttydefs.sdl
!	$SDL/LANG=BLISSF=.fld VSTA$SOURCE:TTYDEFS
	$cms fetch ttydefs.fld "test2 mms call"
	$COPY TTYDEFS.fld VSTA$LIBRARY:

txtsym.req : vsta$source:txtsym.req
	$COPY VSTA$SOURCE:TXTSYM.REQ TXTSYM.REQ
	$COPY TXTSYM.REQ VSTA$LIBRARY:

txtsym.l32 : vsta$source:txtsym.req
	$ bliss/lib/nolist vsta$source:txtsym
	$ copy txtsym.l32 vsta$library:

libmacros.r32 : vsta$source:libmacros.r32
	$COPY VSTA$SOURCE:libmacros.r32 libmacros.r32
	$COPY libmacros.r32 VSTA$LIBRARY:

libmacros.l32 : vsta$source:libmacros.r32
	$ bliss/lib/nolist vsta$source:libmacros
	$ copy libmacros.l32 vsta$library:
!	$ del/nolog ttydefs.t32.

txtcodes.r32 : vsta$source:txtcodes.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:TXTCODES
	$cms fetch txtcodes.r32 "test2 mms call"
	$COPY txtcodes.r32 VSTA$LIBRARY:

txtcodes.l32 : vsta$source:txtcodes.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:txtcodes
    	$ cms fetch txtcodes.t32 "test2 call"
	$ bliss/lib/nolist txtcodes.t32
	$ copy txtcodes.l32 vsta$library:
!	$ del/nolog txtcodes.t32.

txtcodes.fld : vsta$source:txtcodes.sdl
!	$SDL/LANG=BLISSF=.FLD VSTA$SOURCE:TXTCODES
	$cms fetch txtcodes.fld "test2 mms call"
	$COPY txtcodes.fld VSTA$LIBRARY:

vsacpdef.r32 : vsta$source:vsacpdef.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:VSACPDEF
	$cms fetch vsacpdef.r32 "test2 mms call"
	$COPY VSACPDEF.R32 VSTA$LIBRARY:

vsacpdef.l32 : vsta$source:vsacpdef.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vsacpdef
    	$ cms fetch vsacpdef.t32 "test2 call"
	$ bliss/lib/nolist vsacpdef.t32
	$ copy vsacpdef.l32 vsta$library:
!	$ del/nolog vsacpdef.t32.

vserrors.r32 : vsta$source:vserrors.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:vserrors
	$cms fetch vserrors.r32 "test2 mms call"
	$COPY vserrors.R32 VSTA$LIBRARY:

vserrors.l32 : vsta$source:vserrors.sdl, vsta$source:errmacros.r32
!	$ sdl/lang=blissf=.t32 vsta$source:vserrors
    	$ cms fetch vserrors.t32 "test2 call"
	$ bliss/lib/nolist vserrors.t32 + vsta$source:errmacros.r32
	$ copy vserrors.l32 vsta$library:
!	$ del/nolog vserrors.t32.

vsacpdef.fld : vsta$source:vsacpdef.sdl
!	$SDL/LANG=BLISSF=VSACPDEF.FLD VSTA$SOURCE:VSACPDEF
	$cms fetch vsacpdef.fld "test2 mms call"
	$COPY VSACPDEF.FLD VSTA$LIBRARY:

vsast.r32 : vsta$source:vsast.sdl
!	$SDL/LANG=BLISSF VSTA$SOURCE:VSAST.SDL
	$cms fetch vsast.r32 "test2 mms call"
	$COPY VSAST.R32 VSTA$LIBRARY:

!vsast.l32 : vsta$source:vsast.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vsast
vsast.l32 : vsta$source:vsast.t32
    	$ cms fetch vsast.t32 "test2 call"
	$ bliss/lib/nolist vsast.t32
	$ copy vsast.l32 vsta$library:
!	$ del/nolog vsast.t32.

vsdbfrs.r32 : vsta$source:vsdbfrs.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:VSDBFRS.SDL
	$cms fetch vsdbfrs.r32 "test2 mms call"
	$COPY VSDBFRS.R32 VSTA$LIBRARY:


!vsdbfrs.l32 : vsta$source:vsdbfrs.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vsdbfrs
vsdbfrs.l32 : vsta$source:vsdbfrs.t32
    	$ cms fetch vsdbfrs.t32 "test2 call"
	$ bliss/lib/nolist vsdbfrs.t32
	$ copy vsdbfrs.l32 vsta$library:
!	$ del/nolog vsdbfrs.t32.

vsgenem.r32 : vsta$source:vsgenem.sdl
!	$SDL/LANG=BLISSF VSTA$SOURCE:VSGENEM.SDL
	$cms fetch vsgenem.r32 "test2 mms call"
	$COPY VSGENEM.R32 VSTA$LIBRARY:

!vsgenem.l32 : vsta$source:vsgenem.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vsgenem
vsgenem.l32 : vsta$source:vsgenem.t32
    	$ cms fetch vsgenem.t32 "test2 call"
	$ bliss/lib/nolist vsgenem.t32
	$ copy vsgenem.l32 vsta$library:
!	$ del/nolog vsgenem.t32.

vsgidis.req : vsta$source:vsgidis.req
	$ COPY VSTA$SOURCE:VSGIDIS.REQ VSGIDIS.REQ
	$ COPY VSTA$SOURCE:VSGIDIS.REQ VSTA$LIBRARY:VSGIDIS.REQ

vsgidis.l32 : vsta$source:vsgidis.req
	$ bliss/lib/nolist vsta$source:vsgidis
	$ copy vsgidis.l32 vsta$library:

!vssrvdata.l32 : vsta$source:vssrvdata.sdl
!	$ sdl/lang=blissf vsta$source:vssrvdata
vssrvdata.l32 : vsta$source:vssrvdata.r32
    	$ cms fetch vssrvdata.r32 "test2 call"
	$ bliss/lib/nolist vssrvdata.r32
	$ copy vssrvdata.l32 vsta$library:

vssrvmacs.l32 : vsta$source:vssrvmacs.r32
	$bliss/lib/nolist VSTA$SOURCE:VSSRVMACS.R32
	$COPY VSSRVMACS.L32 VSTA$LIBRARY:

vssrvsymb.r32 : vsta$source:vssrvsymb.sdl
!	$SDL/LANG=BLISSF VSTA$SOURCE:VSSRVSYMB
	$COPY VSSRVSYMB.R32 VSTA$LIBRARY:

!vssrvsymb.l32 : vsta$source:vssrvsymb.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vssrvsymb
vssrvsymb.l32 : vsta$source:vssrvsymb.t32
    	$ cms fetch vssrvsymb.t32 "test2 call"
	$ bliss/lib/nolist vssrvsymb.t32
	$ copy vssrvsymb.l32 vsta$library:
!	$ del/nolog vssrvsymb.t32.

!vstamf.l32 : vsta$source:vstamf.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vstamf
vstamf.l32 : vsta$source:vstamf.t32
    	$ cms fetch vstamf.t32 "test2 call"
	$ bliss/lib/nolist vstamf.t32
	$ copy vstamf.l32 vsta$library:
!	$ del/nolog vstamf.t32.


vstaterm.r32 : vsta$source:vstaterm.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:VSTATERM
	$cms fetch vstaterm.r32 "test2 mms call"
	$COPY VSTATERM.R32 VSTA$LIBRARY:

!vstaterm.l32 : vsta$source:vstaterm.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vstaterm
vstaterm.l32 : vsta$source:vstaterm.t32
    	$ cms fetch vstaterm.t32 "test2 call"
	$ bliss/lib/nolist vstaterm.t32
	$ copy vstaterm.l32 vsta$library:
!	$ del/nolog vstaterm.t32.

!vstekem.l32 : vsta$source:vstekem.sdl
!	$ sdl/lang=blissf=.FLD vsta$source:vstekem
vstekem.l32 : vsta$source:vstekem.fld
    	$ cms fetch vstekem.fld "test2 call"
	$ bliss/lib/nolist vstekem.fld
	$ copy vstekem.l32 vsta$library:

vsvdspb.r32 : vsta$source:vsvdspb.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:VSVDSPB
	$cms fetch vsvdspb.r32 "test2 mms call"
	$COPY VSVDSPB.R32 VSTA$LIBRARY:

!vsvdspb.l32 : vsta$source:vsvdspb.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vsvdspb
vsvdspb.l32 : vsta$source:vsvdspb.t32
    	$ cms fetch vsvdspb.t32 "test2 call"
	$ bliss/lib/nolist vsvdspb.t32
	$ copy vsvdspb.l32 vsta$library:
!	$ del/nolog vsvdspb.t32.

vsvdspb.fld : vsta$source:vsvdspb.sdl
!	$SDL/LANG=BLISSF=VSVDSPB.FLD VSTA$SOURCE:VSVDSPB
	$cms fetch vsvdspb.fld "test2 mms call"
	$COPY VSVDSPB.FLD VSTA$LIBRARY:

vsvdsvd.r32 : vsta$source:vsvdsvd.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:VSVDSVD
	$cms fetch vsvdsvd.r32 "test2 mms call"
	$COPY VSVDSVD.R32 VSTA$LIBRARY:

!vsvdsvd.l32 : vsta$source:vsvdsvd.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vsvdsvd
vsvdsvd.l32 : vsta$source:vsvdsvd.t32
    	$ cms fetch vsvdsvd.t32 "test2 call"
	$ bliss/lib/nolist vsvdsvd.t32
	$ copy vsvdsvd.l32 vsta$library:
!	$ del/nolog vsvdsvd.t32.

vsvdsvd.fld : vsta$source:vsvdsvd.sdl
!	$SDL/LANG=BLISSF=.FLD VSTA$SOURCE:VSVDSVD
	$cms fetch vsvdsvd.fld "test2 mms call"
	$COPY VSVDSVD.FLD VSTA$LIBRARY:

vstaodrv.r32 : vsta$source:vstaodrv.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:VSTAODRV
	$cms fetch vstaodrv.r32 "test2 mms call"
	$COPY VSTAODRV.R32 VSTA$LIBRARY:

!vstaodrv.l32 : vsta$source:vstaodrv.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vstaodrv
vstaodrv.l32 : vsta$source:vstaodrv.t32
    	$ cms fetch vstaodrv.t32 "test2 call"
	$ bliss/lib/nolist vstaodrv.t32
	$ copy vstaodrv.l32 vsta$library:
!	$ del/nolog vstaodrv.t32.

vstasyms.l32 : vsta$source:vstasyms.bli, vsta$source:vstamacs.bli, -
		vstanativ.r32, vstadef.r32, vstagbl.r32, vsvdsvdc.r32
	$BLI/LIBRARY/DEB VSTA$SOURCE:VSTASYMS.BLI
	$COPY VSTASYMS.L32 VSTA$LIBRARY:

vstamacs.l32 : vsta$source:vstamacs.bli
	$BLI/LIBRARY/DEB VSTA$SOURCE:VSTAMACS.BLI
	$COPY VSTAMACS.L32 VSTA$LIBRARY:

vsvdsvdc.r32 : vsta$source:vsvdsvdc.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:VSVDSVDC
	$cms fetch vsvdsvdc.r32 "test2 mms call"
	$COPY VSVDSVDC.R32 VSTA$LIBRARY:

!vsvdsvdc.l32 : vsta$source:vsvdsvdc.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vsvdsvdc
vsvdsvdc.l32 : vsta$source:vsvdsvdc.t32
    	$ cms fetch vsvdsvdc.t32 "test2 call"
	$ bliss/lib/nolist vsvdsvdc.t32
	$ copy vsvdsvdc.l32 vsta$library:
!	$ del/nolog vsvdsvdc.t32.

vstanativ.r32 : vsta$source:vstanativ.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:VSTANATIV
	$cms fetch vstanativ.r32 "test2 mms call"
	$COPY VSTANATIV.R32 VSTA$LIBRARY:

!vstanativ.l32 : vsta$source:vstanativ.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vstanativ
vstanativ.l32 : vsta$source:vstanativ.t32
    	$ cms fetch vstanativ.t32 "test2 call"
	$ bliss/lib/nolist vstanativ.t32
	$ copy vstanativ.l32 vsta$library:
!	$ del/nolog vstanativ.t32.

vstagbl.r32 : vsta$source:vstagbl.sdl
!	$ SDL/LANG=(bliss,cc,for,macro,pli,pascal) VSTA$SOURCE:VSTAGBL
	$cms fetch vstagbl.* "test2 mms call"
	$ COPY VSTAGBL.R32 VSTA$LIBRARY:*
	$ copy vstagbl.pli,vstagbl.mar vsta$library:*

!vstagbl.l32 : vsta$source:vstagbl.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vstagbl
vstagbl.l32 : vsta$source:vstagbl.t32
    	$ cms fetch vstagbl.t32 "test2 call"
	$ bliss/lib/nolist vstagbl.t32
	$ copy vstagbl.l32 vsta$library:
!	$ del/nolog vstagbl.t32.

vstamsg.r32 : vsta$source:vstamsg.sdl
!	$ SDL/LANG=(bliss,cc,for,macro,pli,pascal) VSTA$SOURCE:VSTAMSG
	$cms fetch vstamsg.* "test2 mms call"
	$ COPY VSTAMSG.R32 VSTA$LIBRARY:*
	$ copy vstamsg.mar,vstamsg.pli vsta$library:*

vsvkb.r32 : vsta$source:vsvkb.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:VSVKB
	$cms fetch vsvkb.r32 "test2 mms call"
	$COPY VSVKB.R32 VSTA$library:

!vsvkb.l32 : vsta$source:vsvkb.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vsvkb
vsvkb.l32 : vsta$source:vsvkb.t32
    	$ cms fetch vsvkb.t32 "test2 call"
	$ bliss/lib/nolist vsvkb.t32
	$ copy vsvkb.l32 vsta$library:
!	$ del/nolog vsvkb.t32.

!vstakbrd.l32 : vsta$source:vstakbrd.sdl
!	$ sdl/lang=bliss vsta$source:vstakbrd
vstakbrd.l32 : vsta$source:vstakbrd.r32
    	$ cms fetch vstakbrd.r32 "test2 call"
	$ bliss/lib/nolist vstakbrd.r32
	$ copy vstakbrd.l32 vsta$library:

!vsvtb.r32 : vsta$source:vsvtb.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:VSVTB
vsvtb.r32 : vsta$source:vsvtb.r32
	$cms fetch vsvtb.r32 "test2 mms call"
	$COPY VSVTB.R32 VSTA$LIBRARY:

!vsvtb.l32 : vsta$source:vsvtb.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vsvtb
vsvtb.l32 : vsta$source:vsvtb.t32
    	$ cms fetch vsvtb.t32 "test2 call"
	$ bliss/lib/nolist vsvtb.t32
	$ copy vsvtb.l32 vsta$library:
!	$ del/nolog vsvtb.t32.

vsvtb.fld : vsta$source:vsvtb.sdl
!	$SDL/LANG=BLISSF=.FLD VSTA$SOURCE:VSVTB
	$cms fetch vsvtb.fld "test2 mms call"
	$COPY VSVTB.FLD VSTA$LIBRARY:

vsvssvs.r32 : vsta$source:vsvssvs.sdl
!	$SDL/LANG=BLISSF VSTA$SOURCE:VSVSSVS
	$cms fetch vsvssvs.r32 "test2 mms call"
	$COPY VSVSSVS.R32 VSTA$LIBRARY:

!vsvssvs.l32 : vsta$source:vsvssvs.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vsvssvs
vsvssvs.l32 : vsta$source:vsvssvs.t32
       	$ cms fetch vsvssvs.t32 "test2 call"
	$ bliss/lib/nolist vsvssvs.t32
	$ copy vsvssvs.l32 vsta$library:
!	$ del/nolog vsvssvs.t32.

vsvtem100.r32 : vsta$source:vsvtem100.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:VSVTEM100
	$cms fetch vsvtem100.r32 "test2 mms call"
	$COPY VSVTEM100.R32 VSTA$LIBRARY:

vsvtem100.l32 : vsta$source:vsvtem100.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vsvtem100
    	$ cms fetch vsvtem100.t32 "test2 call"
	$ bliss/lib/nolist vsvtem100.t32
	$ copy vsvtem100.l32 vsta$library:
!	$ del/nolog vsvtem100.t32.

vxslib.r32 : vsta$source:vxslib.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:VXSLIB
	$cms fetch vxslib.r32 "test2 mms call"
	$COPY VXSLIB.R32 VSTA$LIBRARY:

vxslib.l32 : vsta$source:vxslib.sdl
!	$ sdl/lang=blissf=.t32 vsta$source:vxslib
    	$ cms fetch vxslib.t32 "test2 call"
	$ bliss/lib/nolist vxslib.t32
	$ copy vxslib.l32 vsta$library:
!	$ del/nolog vxslib.t32.

vxslib.fld : vsta$source:vxslib.sdl
!	$SDL/LANG=BLISSF=.FLD VSTA$SOURCE:VXSLIB
	$cms fetch vxslib.fld "test2 mms call"
	$COPY VXSLIB.FLD VSTA$LIBRARY:

!-----------------------------------------------------------------
! 			VSTALIB modules
!-----------------------------------------------------------------

vxslib.obj : vsta$source:vxslib.b32, vxslib.r32, vsvdspb.l32, vsvdsvd.l32, -
		vsacpdef.r32, txtcodes.l32, libmacros.l32, vserrors.l32, -
		vstagbl.l32,  vssrvdata.l32
	$BLISS VSTA$SOURCE:VXSLIB

vstangi.obj : vsta$source:vstangi.b32, vsacpdef.l32, -
		vstagbl.l32 , vxslib.l32, vstamacs.l32, libmacros.l32, -
		vserrors.l32, vstadef.l32, vstanativ.l32
	$BLISS VSTA$SOURCE:VSTANGI

vxsfont.obj : vsta$source:vxsfont.b32, vxslib.r32, -
		vsvdspb.l32, vsvdsvd.l32, vsacpdef.r32, txtcodes.l32, -
		libmacros.l32, vserrors.l32
	$BLISS VSTA$SOURCE:VXSFONT

vxspack.obj : vsta$source:vxspack.b32, vxslib.r32, vsacpdef.r32, -
		libmacros.l32
	$BLISS VSTA$SOURCE:VXSPACK

vstamouse.obj : vsta$source:vstamouse.b32, vsacpdef.r32, libmacros.l32, -
		vserrors.l32
	$BLISS VSTA$SOURCE:VSTAMOUSE

vstatblet.obj : vsta$source:vstatblet.b32, vsacpdef.r32, vserrors.l32, -
		libmacros.l32, vxslib.r32
	$BLISS VSTA$SOURCE:VSTATBLET

vstargn.obj : vsta$source:vstargn.b32, -
		vsvdsvd.fld, libmacros.l32, vxslib.fld, vserrors.l32, -
		txtcodes.l32, vsacpdef.r32
	$BLISS/DEBUG VSTA$SOURCE:vstargn

vstatext.obj : vsta$source:vstatext.b32, vsacpdef.r32,  vserrors.l32, -
		libmacros.l32, vxslib.r32, vsvdspb.l32, vsvdsvd.l32, -
		txtcodes.l32
	$BLISS VSTA$SOURCE:VSTATEXT

vstalibi.obj : vsta$source:vstalibi.b32, vsacpdef.l32,  vserrors.l32, -
		libmacros.l32, vxslib.r32, vsvdspb.l32, vsvdsvd.l32, -
		txtcodes.l32, vstagbl.l32
	$BLISS VSTA$SOURCE:VSTALIBI

vstamsg.obj : vsta$source:vstaerrs.msg, buildmsg.com, ident.opt
	$ @VSTA$COM:BUILDMSG

vsstuberr.obj : vsta$source:vsstuberr.msg
	$ MESS VSTA$SOURCE:VSSTUBERR.MSG


!----------------------------------------------------------------------
! 			VDDRIVER modules
!----------------------------------------------------------------------

vddriver.obj : vsta$source:vddriver.mar, vsmacros.mlb
	$MACRO/LIS VSTA$SOURCE:VDDRIVER.MAR

vsmacros.mlb : vsacpdef.mar
	$LIBRARY/CREATE/LIST/LOG/MACRO VSMACROS VSACPDEF
	$COPY VSMACROS.MLB VSTA$LIBRARY:

!vsacpdef.mar : vsta$source:vsacpdef.sdl
!	$SDL/LANG=MACRO VSTA$SOURCE:VSACPDEF

!-----------------------------------------------------------------------
! 			VBDRIVER modules
!-----------------------------------------------------------------------

vbdriver.obj : vsta$source:vbdriver.mar, vbdef.mlb, dasm.com
	$ @VSTA$COM:DASM DRIVER

vbend.obj : vsta$source:vbend.mar, vbdef.mlb, dasm.com
	$ @VSTA$COM:DASM END

vbsub.obj : vsta$source:vbsub.mar, vbdef.mlb, dasm.com
	$ @VSTA$COM:DASM SUB

vbfdt.obj : vsta$source:vbfdt.b32, linkage.r32, -
		vblinkage.r32, vbdef.r32, vstadef.r32
	$ BLISS VSTA$SOURCE:VBFDT

vbset.obj : vsta$source:vbset.b32, linkage.r32, -
		vblinkage.r32, vbdef.r32, vstadef.r32
	$ BLISS VSTA$SOURCE:VBSET

!----------------------------------------------------------------------
! 		REQUIRE files, etc. for VBDRIVER and VSACP
!----------------------------------------------------------------------

linkage.r32 : vsta$source:linkage.r32
	$COPY VSTA$SOURCE:LINKAGE.R32 VSTA$BUILD:
	$COPY VSTA$SOURCE:LINKAGE.R32 VSTA$LIBRARY:

vblinkage.r32 : vsta$source:vblinkage.r32
	$COPY VSTA$SOURCE:VBLINKAGE.R32 VSTA$BUILD:
	$COPY VSTA$SOURCE:VBLINKAGE.R32 VSTA$LIBRARY:

linkage.l32 : vsta$source:linkage.r32
	$bliss/lib/nolist VSTA$SOURCE:LINKAGE.R32
	$COPY LINKAGE.L32 VSTA$LIBRARY:

vblinkage.l32 : vsta$source:vblinkage.r32
	$bliss/lib/nolist VSTA$SOURCE:VBLINKAGE.R32
	$COPY VBLINKAGE.L32 VSTA$LIBRARY:

vbdef.mar : vsta$source:vbdef.sdl
!	$SDL/LANG=(MACRO) VSTA$SOURCE:VBDEF
	$cms fetch vbdef.mar "test2 mms call"
	$COPY VBDEF.MAR VSTA$LIBRARY:

vbdef.r32 : vsta$source:vbdef.sdl
!	$SDL/LANG=(BLISS) VSTA$SOURCE:VBDEF
	$cms fetch vbdef.r32 "test2 mms call"
	$COPY VBDEF.R32 VSTA$LIBRARY:

vbdef.l32 : vsta$source:vbdef.sdl
!	$SDL/LANG=BLISS VSTA$SOURCE:VBDEF
	$ cms fetch vbdef.r32 "test2 call"
	$bliss/lib/nolist VBDEF.R32
	$COPY VBDEF.L32 VSTA$LIBRARY:
	$COPY VBDEF.R32 VSTA$LIBRARY:

vstadef.mar : vsta$source:vstadef.sdl
!	$SDL/LANG=(MACRO) VSTA$SOURCE:VSTADEF
	$cms fetch vstadef.mar "test2 mms call"
	$COPY VSTADEF.MAR VSTA$LIBRARY:


vstadef.r32 : vsta$source:vstadef.sdl
!	$SDL/LANG=(BLISS) VSTA$SOURCE:VSTADEF
!	$SDL/LANG=(BLISSF=.FLD) VSTA$SOURCE:VSTADEF
    	$ cms fetch vstadef.* "test2 call"
	$bliss/lib/nolist VSTADEF.FLD
	$COPY VSTADEF.FLD VSTA$LIBRARY:
	$COPY VSTADEF.R32 VSTA$LIBRARY:
	$COPY VSTADEF.L32 VSTA$LIBRARY:


vstadef.l32 : vsta$source:vstadef.sdl
!	$SDL/LANG=(BLISSF=.FLD) VSTA$SOURCE:VSTADEF
    	$ cms fetch vstadef.fld "test2 call"
	$BLISS/LIB/NOLIST VSTADEF.FLD
	$COPY VSTADEF.L32 VSTA$LIBRARY:

vbdef.mlb : vstadef.mar, vbdef.mar
	$LIBRARY/CREATE/MACRO vbdef vbdef,vstadef
	$COPY VBDEF.MLB VSTA$LIBRARY:

! Make sure it ends up in scaff directory also.

ident.opt : vsta$scaff:ident.opt
	$COPY VSTA$SOURCE:IDENT.OPT VSTA$SCAFF:

!------------------------------------------------------------------
! 		Startacp and stopacp modules
!------------------------------------------------------------------

startacp.obj : vsta$source:startacp.b32, linkage.l32, vsacpdef.r32
	$BLISS/DEBUG VSTA$SOURCE:STARTACP

vsacpprms.obj : vsta$source:vsacpprms.b32
	$BLISS/DEBUG VSTA$SOURCE:VSACPPRMS

stopacp.obj : vsta$source:stopacp.b32, linkage.l32
	$BLISS/DEBUG VSTA$SOURCE:STOPACP

stopacps.obj : vsta$source:stopacps.b32, linkage.l32
	$BLISS/DEBUG VSTA$SOURCE:STOPACPS

getstop.obj : vsta$source:getstop.for
	$FORTRAN VSTA$SOURCE:GETSTOP.FOR

!---------------------------------------------------------------------------
!
! The following mms directives indicate how to build the files needed for the
! help system and for multiple languages:
!
!	$ mms MFENG.MF		Message File in English
!	$ mms MFFRE.MF		Message file In French
!	. . .			add other languages as needed !
!	$ mms MFHLP.MF		Help file
!
mfeng.mf	:	vsta$source:mfeng.txt, vsta$exe:vstamf.exe
	$ open/write a runmf.com
	$ write a "$ run vsta$exe:vstamf"
	$ write a "C"
	$ write a "vsta$source:mfeng.txt"
	$ write a "ENGLISH"
	$ close a
	$ @runmf
	$ delete/nolog runmf.com;*
	$ copy mfeng.mf vsta$hilib:

mffre.mf	:	vsta$source:mffre.txt, vsta$exe:vstamf.exe
	$ open/write a runmf.com
	$ write a "$ run vsta$exe:vstamf"
	$ write a "C"
	$ write a "vsta$source:mffre.txt"
	$ write a "FRENCH"
	$ close a
	$ @runmf
	$ delete/nolog runmf.com;*
	$ copy mffre.mf vsta$hilib:

mfhlp.mf	:	vsta$source:mfhlp.txt, vsta$exe:vstamf.exe
	$ open/write a runmf.com
	$ write a "$ run vsta$exe:vstamf"
	$ write a "C"
	$ write a "vsta$source:mfhlp.txt"
	$ write a "HELP"
	$ close a
	$ @runmf
	$ delete/nolog runmf.com;*
	$ copy mfhlp.mf vsta$hilib:

vsta$exe:vstamf.exe	:	mf.obj, getans.obj, ident.opt
	$ link/exe=vsta$exe:vstamf -
	    mf, -
	    getans, -
	    ident.opt/opt,-	 
	    sys$library:recog/lib
!
!	vstaprint added
!
vstaprint.obj    : vsta$source:vstaprint.b32
	$BLISS/DEBUG VSTA$SOURCE:VSTAPRINT

vstaprint.exe    :  vstaprint.obj, ident.opt
	$ link/exe=vstaprint -
	    vstaprint,-
	    ident.opt/opt 

mf.obj : vsta$source:mf.b32, docfile.l32, vstamf.l32
	$BLISS/DEBUG VSTA$SOURCE:mf

getans.obj : vsta$source:getans.b32
	$BLISS/DEBUG VSTA$SOURCE:getans

