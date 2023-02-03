$ ivp_status == 0	! convey result of IVP
$ missed = 0
$ 
$ @defkitlog.com
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "** INSTALLATION VERIFICATION PROCEDURE (IVP) **"
$ WRITE SYS$OUTPUT ""
$
$ open/read dirfile vs100.swl
$ 
$ Check_Next_File:
$ read/end=done dirfile file
$ if f$search(file) .eqs. "" then $ goto missing
$ goto Check_Next_File
$ 
$ done:
$ If missed .ne. 0 then $ goto Install_Lost_missed
$ WRITE SYS$OUTPUT "** VAXstation Display Services V1.2 IVP successful **"
$ @deakitlog.com
$ EXIT
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
$ WRITE SYS$OUTPUT "** VAXstation Display Services V1.2 IVP failed **"
$ ivp_status == 10	! installation verification unsuccessful
$ @deakitlog.com
$ EXIT
