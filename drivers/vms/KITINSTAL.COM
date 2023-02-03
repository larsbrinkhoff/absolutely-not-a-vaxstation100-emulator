$! ----------------------------------------------------------------------------
$!
$! KITINSTAL.COM : Installation procedure for VAXstation software
$!
$	ON CONTROL_Y THEN GOTO control_y_abort
$	ON WARNING THEN GOTO abort
$	save_verify = F$VERIFY(0)	! Save VERIFY status & SET NOVERIFY
$	kit_debug := 'p2'		! Make sure kit_debug gets set.
$	install_status == 0		! install status init HERE
$	s = VMI$_SUCCESS		! initialize return flag
$	WO := WRITE SYS$OUTPUT
$	IF p1 .EQS. "VMI$_INSTALL" THEN GOTO install
$	IF p1 .EQS. "VMI$_IVP"     THEN GOTO kit_ivp
$	s = VMI$_UNSUPPORTED		! flag = unsupported function
$	EXIT s
$!
$ install:
$	min_vms := "040"		! VAXstation actually requires VMS V4.0
$	min_vms_human := "V4.0"		! VAXstation actually requires VMS V4.0
$	vskitbas_blocks = 6000		! no. of blocks needed for installation
$	vskitivp_blocks = 0		! no. of blocks needed for ivp
$	vskitbas := "YES"		! kit installation
$	vskitivp := "NO"		! Installation Verification
$	log_switch := ""
$	verify_switch := ""
$	IF kit_debug THEN log_switch := "/LOG"
$	IF kit_debug THEN verify_switch := "/VERIFY"
$!
$	save_dir = F$DIRECTORY()	! save current default directory
$	SET DEFAULT VMI$KWD:		! Kit's working directory
$	SET PROTECTION=WORLD:RE/DEFAULT
$	IF "''F$LOGICAL("VST_VERSION")'" .NES. "" THEN DEASSIGN VST_VERSION
$	DEFINE VST_VERSION @VMI$KWD:VERSION.VST
$	VST_VERSION := 'F$LOGICAL("VST_VERSION")'
$	product := "VAXstation software ''VST_VERSION'"
$!
$!  Check if the user is logged into the SYSTEM account
$	NAME = F$GETJPI("","USERNAME")
$	IF "''NAME'" .EQS. "SYSTEM      " THEN GOTO go_ahead
$	WO "You are not logged into the SYSTEM account"
$	WO "Please log in as requested and run VMSINSTAL again"
$	s = VMI$_FAILURE
$	GOTO abort_s
$!
$ go_ahead:
$!  Check VMS version number
$	VMI$CALLBACK CHECK_VMS_VERSION okay 'min_vms'
$	vms_version := 'F$GETSYI("VERSION")'
$	IF okay THEN GOTO vms_ok
$	WO "Your system has VAX/VMS ''vms_version' installed."
$	WO "''product requires VAX/VMS ''min_vms_human'."
$	s = VMI$_FAILURE
$	GOTO abort_s
$!
$ vms_ok:
$	WO ""
$	WO "Your system is running VAX/VMS, Version ''vms_version'"
$	WO ""
$!
$ check_target_disk:
$!	Check for room on target disk
$ add_em_up:
$	blocks_needed = 0
$	IF vskitbas THEN blocks_needed = blocks_needed + vskitbas_blocks
$	IF vskitivp THEN blocks_needed = blocks_needed + vskitivp_blocks
$	VMI$CALLBACK CHECK_NET_UTILIZATION okay 'blocks_needed'
$	IF okay THEN GOTO restore_vskitbas
$	WO "There is not enough space on system disk for the VAXstation"
$	WO "software installation; it requires ''blocks_needed' blocks."
$	s = VMI$_FAILURE
$	GOTO abort_s
$!
$ restore_vskitbas:
$	VMI$CALLBACK SET PURGE ASK		! Ask about purging
$! ask about ivp here which will be run AFTER installation if user says YES
$	VMI$CALLBACK SET IVP ASK
$	WO ""
$	WO ""
$	VMI$CALLBACK CREATE_DIRECTORY SYSTEM VSTA
$	VMI$CALLBACK CREATE_DIRECTORY SYSTEM VSTA.COM
$	VMI$CALLBACK CREATE_DIRECTORY SYSTEM VSTA.EXAMPLES
$	VMI$CALLBACK CREATE_DIRECTORY SYSTEM VSTA.EXE
$	VMI$CALLBACK CREATE_DIRECTORY SYSTEM VSTA.FONT
$	VMI$CALLBACK CREATE_DIRECTORY SYSTEM VSTA.HILIB
$	VMI$CALLBACK CREATE_DIRECTORY SYSTEM VSTA.MICRO
$!
$ SET DIRECTORY/VERSION_LIMIT=2 [VSTA.HILIB]	! Set version-limit=2 for hilib
$!
$	@VMI$KWD:VSKITBAS.COM 'kit_debug'
$	IF install_status .EQ. 0 THEN GOTO done
$	s = VMI$_FAILURE
$	GOTO abort_s
$!
$ done:
$ WO ""
$ WO ""
$ WO "******************************************"
$ WO "*  Add @SYS$SYSROOT:[VSTA.COM]VSTASTART  *"
$ WO "*  in your system startup command file   *"
$ WO "******************************************"
$ WO ""
$	GOTO exit
$!
$ control_y_abort:
$	WO "Installation of ''product' aborted by control Y"
$	VMI$CALLBACK MESSAGE I TIME "Time is: ''F$TIME()'"
$	VMI$CALLBACK CONTROL_Y
$	GOTO exit
$!
$ exit:
$	IF save_verify .EQ. 1 THEN SET VERIFY	! Restore VERIFY status
$	SET DEFAULT 'save_dir'			! Restore original default dir
$	EXIT s
$!
$ abort:
$	s = $STATUS
$ abort_s:
$	WO ""
$	WO "Installation of ''product' failed."
$	GOTO exit
$!
$!	Installation Verification Procedure (IVP)  here
$ kit_ivp:
$	ON ERROR THEN GOTO fail_ivp
$	@VSKITIVP.COM		! do the installation verification procedure
$	IF ivp_status .EQ. 10 THEN GOTO fail_ivp
$	EXIT
$ fail_ivp:
$	s = VMI$_FAILURE
$	EXIT s
