$ ! Command file to load VAXstation device drivers and startup ACP processes.
$ !
$ ! Establish the needed privileges
$ needed_privs := "CMKRNL,PHY_IO,LOG_IO,DIAGNOSE,EXQUOTA,PFNMAP,PRMGBL"-
		 ",PSWAPM,TMPMBX,WORLD,ALLSPOOL,OPER,SYSGBL,GROUP,GRPNAM"-
		 ",SYSNAM,DETACH,ALTPRI,SYSLCK,SETPRV,CMEXEC"
$ old_privs := 'f$setprv(needed_privs)
$ if "''f$privilege(needed_privs)'" .eqs. "TRUE" then goto dologs
$ write sys$output "?Insufficient privileges to start VAXstation software"
$ goto done
$ !
$ dologs:
$ if f$logical("vsta$device").nes."" then deassign/system vsta$device
$ if f$logical("sys$common").nes."" then define/system vsta$device sys$common:
$ if f$logical("sys$common").eqs."" then define/system vsta$device sys$sysroot:
$ !
$ !
$ ! Define system-wide logical names for vaxstation directories
$ if f$logical("vsta$com").nes."" then deassign/system vsta$com
$ define/system vsta$com vsta$device:[vsta.com]
$ if f$logical("vsta$examples").nes."" then deassign/system vsta$examples
$ define/system vsta$examples vsta$device:[vsta.examples]
$ if f$logical("vsta$exe").nes."" then deassign/system vsta$exe
$ define/system vsta$exe vsta$device:[vsta.exe]
$ if f$logical("vsta$font").nes."" then deassign/system vsta$font
$ define/system vsta$font vsta$device:[vsta.font]
$ if f$logical("vsta$hilib").nes."" then deassign/system vsta$hilib
$ define/system vsta$hilib vsta$device:[vsta.hilib]
$ if f$logical("vsta$micro").nes."" then deassign/system vsta$micro
$ define/system vsta$micro vsta$device:[vsta.micro]
$ if f$logical("vsta$sysmaint").nes."" then deassign/system vsta$sysmaint
$ define/system vsta$sysmaint vsta$device:[vsta.sysmaint]
$ !
$ define/system vsta$parameters vsta$exe:vsacp.prm
$ !
$ set noon
$ !
$ ! Load VDDRIVER and connect VDA0:, VDB0:, etc. as needed
$ @vsta$com:sysgenvd
$ !
$ MC INSTALL
SYS$SHARE:VSTASHR/SHARE
SYS$SHARE:CGLSHR/SHARE
$ ! Start the ACPs
$ run/nodeb vsta$exe:startacp
$ done:
$ new_privs := 'f$setprv(old_privs)
$ exit
