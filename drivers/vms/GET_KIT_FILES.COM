$ ! get_kit_files.com	  
$ !
$ ! Purpose:		Get file needed for installation procedure.
$ !
$ !	This procedure does not actually create the VMSINSTAL command
$ !	procedure.  It copies all of the necessary files from the CMS
$ !	library and the just-completed MMS build into one directory.
$ !	MAKEKIT.COM will take this directory and build the installation
$ !	kit. 
$!
$! Mount the disk containing files from mms build
$!
$ all dma0:
$ mount/noassist dma0: vsta
$!
$ kit_name := VSTAxxx			! For easy changes...
$!
$! Set logical pointers for build here.
$!
$ define bl$examples	asd$public:[vs100.examples]
$ define bl$font 	asd$public:[vs100.font]
$ define bl$help 	asd$public:[vs100.help]
$ define bl$micro 	asd$public:[vs100.micro]
$ define bl$uetp	asd$public:[vs100.uetp]
$!
$ define bl$build 	dma0:[vs100.bl.build]
$ define bl$exe 	dma0:[vs100.bl.exe]
$ define bl$library	dma0:[vs100.bl.library]
$ define bl$source	dma0:[vs100.bl.source]
$!                                   
$ define bl$hilib 	asd$public:[vs100.hilib]
$!
$! Define output directory logical.
$!
$ define bl$kit_files	asd$public:[vs100.test]
$!
$ del bl$kit_files:*.*.*/nolog			! Clean out the work area
$!
$! Fetch files needed for installation kit and store
$! in work area.
$! 
$ WO :=WRITE SYS$OUTPUT
$ TO :=bl$kit_files:
$ !
$ set def 'TO'
$ !
$ cms set lib asd$public:[vs100.decus_cmscode]
$ cms fetch vstastart.com "for installation kit"
$ cms fetch deakitlog.com "for installation kit"
$ cms fetch defkitlog.com "for installation kit"
$ cms fetch kitinstal.com "for installation kit"
$ cms fetch kitlogs.dat   "for installation kit"
$ cms fetch spkitbld.com  "for installation kit"
$ cms fetch sysgenvd.com  "for installation kit"
$ cms fetch version.vst   "for installation kit"
$ cms fetch vs100.swl     "for installation kit"
$ cms fetch vskitbas.com  "for installation kit"
$ cms fetch vskitivp.com  "for installation kit"
$ cms fetch vstaque.com    "for installation kit"
$ cms fetch subprint.com   "for installation kit"
$ cms fetch vstaprint.com  "for installation kit"
$ cms fetch vsacp.prm	   "for installation kit"
$!
$! include copying files from BL$exe,BL$font,BL$hilib,BL$micro,BL$help,BL$build
$!
$ COPY BL$EXE:*.*			'TO'*
$ COPY BL$FONT:*.*			'TO'*
$ COPY BL$HILIB:*.*			'TO'*
$ COPY BL$MICRO:VS100FW.BIN		'TO'*
$ COPY BL$HELP:VSTAHELP.HLP		'TO'*
$ COPY BL$library:VSTAMSG.*,VSTAGBL.*	'TO'*
$ COPY BL$UETP:VSTALOGIN.COM,UETVSTA*.EXE,UETVSTA*.COM,UETVSTA*.DAT 'TO'*
$ COPY BL$EXAMPLES:*.*			'TO'*
$!
$! Delete all files except for executables and command files...
$!
$ DELETE 'TO'VSTA*.DTR.*,VSTA*.PV1.*,VSTA*.OBJ.*,VSTA*.T32.*,VSTA*.L32.*,VSACPD.*.*
$!
$! Set protection and owner for all files in Kit.
$!
$ set protection=(s:rewd,o:rewd,g:rewd,w:re)  'TO'*.*;*
$!
$ WO ""
$ WO " Update the following files"
$ WO "VSKITBAS.COM	- in case of changes in file names"
$ WO "VS100.SWL		- in case of changes in file names"
$ !
$ ! Verify the presence of all files.
$ ! Compare list of files just created and fetched to known list.
$ !
$ ivp_status == 0	! convey result of IVP
$ missed = 0
$ !
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "	[Performing kit verification]"
$ WRITE SYS$OUTPUT ""
$
$ open/read dirfile 'TO'vs100.swl
$ 
$ Check_Next_File:
$ read/end=done dirfile file
$ name = f$parse(file, "","", "NAME")
$ type = f$parse(file, "","", "TYPE")
$ file = TO + name + type
$ if f$search(file) .eqs. "" then $ goto missing
$ goto Check_Next_File
$ 
$ done:
$ If missed .ne. 0 then $ goto Install_Lost_missed
$ WRITE SYS$OUTPUT "	[Kit verified.  All files present.]"
$ goto spkitbld
$ 
$! Come here if any file is not found...
$ missing:
$ message = file + " is not present!"
$ WRITE SYS$OUTPUT message
$ missed = missed + 1
$ goto Check_Next_File
$ 
$ Install_Lost_Missed:
$ message = "1 file missing."
$ if missed .gt. 1 then $ message = f$string(missed) + " files missing."
$ WRITE SYS$OUTPUT message
$ 
$ lost_bye:
$ WRITE SYS$OUTPUT "	[Kit verification failed]"
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "	*** THIS IS A BAD KIT!!! ***"
$ goto EXIT
$!
$! 	Everything ok so build kit.
$!
$ spkitbld:
$!
$!	Don't acutally build kit here.  MAKEKIT.COM will take
$!	all of the files just created, and build a VMS installation
$!	procedure.
$
$!
$!	Dismount source Disk and exit.
$!
$ Exit:
$ dismount/nounload dma0:
$ deall dma0:
$ !
$ exit
