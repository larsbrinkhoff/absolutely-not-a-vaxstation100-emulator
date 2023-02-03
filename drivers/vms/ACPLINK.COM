$! ACPLINK.COM - Command file to LINK the ACP
$ ASSIGN VSTA$COM: VC:
$!
$! On error, tell user.
$!
$ on severe_error then mail nl: 'f$getjpi ("", "username")' -
	/subj="Fatal error during link of vsacp !"
$!
$ if f$extract(0,1,p1) .eqs. "D" then goto DEBUG_ONLY
$ if f$extract(0,1,p1) .eqs. "P" then goto PCA_ONLY
$!
$ WRITE SYS$OUTPUT "Linking VaxSTAtion ACP"
$ link/nodebug/nosysshr/map=vsacp/full/exe=vsacp -
vc:acp.opt/option, -
vsta$scaff:IDENT.OPT/OPT, -
sys$system:sys.stb/selective
$!
$! If only non-debug version required, then we're done
$!
$ if f$extract(0,1,p1) .eqs. "N" then goto NONDEBUG_ONLY
$!
$!
$! and also make a debugging version
$!
$ DEBUG_ONLY:
$!
$ WRITE SYS$OUTPUT "Linking VaxSTAtion Debugging ACP"
$ link/debug/nosysshr/map=vsacpd/full/cross/exe=vsacpd -
vc:acp.opt/option, -
vc:acpdbg.opt/option, -
vsta$scaff:IDENT.OPT/OPT, -
sys$system:sys.stb/selective
$!
$ goto nondebug_only
$!
$PCA_ONLY:
$ WRITE SYS$OUTPUT "Linking VaxSTAtion ACP with PCA for performance analysis"
$ link/debug=sys$library:pca$obj.obj/map=vsacpp/full/exe=vsacpp -
vc:acp.opt/option, -
vsta$scaff:IDENT.OPT/OPT, -
sys$system:sys.stb/selective
$!
$NONDEBUG_ONLY:
$ exit
