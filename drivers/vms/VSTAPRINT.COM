$ set verify
$ set process/priviledge=all			! Turn on privileges.
$ set proc/priority=3				! Let running .com run
$ set process/name="VSTAPRINT"			! Make ourselves known.
$ on error then goto ERROR_EXIT			! Set up error handler
$ on severe_error then goto ERROR_EXIT
$ bitmap_file = "vsta$hilib:vstaprint.dat.*"	! Define symbols for the files.
$ sixel_file = "vsta$hilib:vstasixel.dat"
$ oldest = "\\\"				! Create an invalid string.
$ !
$ set proc/priority=7				! Enter MutEx (sort of)
$ a = f$logical("vsta$sixelizer_available")
$ if a .eqs. "YES" then goto DUPLICATE_EXIT	! Exit if we are not unique.
$ def/sys vsta$sixelizer_available YES		! Assert that we are here.
$ set proc/priority=4				! Exit MutEx
$ !
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ ! Routine FIND_OLDEST: Locates the oldest version of the bitmap file.
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ FIND_OLDEST:
$ this_one = f$search(bitmap_file,1)	! 1 is the optional stream id.
$ if this_one .nes. "" then oldest = this_one
$ if this_one .eqs. "" then goto SIXELIZE_IT
$ goto FIND_OLDEST			! Loop back around
$ !
$ !
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ ! Routine SIXELIZE_IT: Run the program to translate the file into sixels.
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ SIXELIZE_IT:
$ if oldest .eqs. "\\\" then goto SUCCESS_EXIT
$ on error then goto SIXELIZER_ERROR		! Set up local error handler.
$ on severe_error then goto SIXELIZER_ERROR
$ def/user sys$input 'oldest'
$ def/user sys$output 'sixel_file'
$ run vsta$exe:vstaprint.exe
$ set file/version_limit=1000 'sixel_file'
$ print/user=system/queue=vsta$printer/form=VSTA/delete 'sixel_file'
$ delete/log 'oldest'
$ oldest = "\\\"				! Create an invalid string.
$ on error then goto ERROR_EXIT			! Restore global error handler.
$ on severe_error then goto ERROR_EXIT
$ goto FIND_OLDEST
$ !
$ !
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ ! Routine SIXELIZER_ERROR.		! This handles bad image files.
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ SIXELIZER_ERROR:
$ delete/log 'sixel_file';			! Delete the useless output.
$ delete/log 'oldest'				! Delete the bad image file.
$ goto FIND_OLDEST
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ ! Routine DUPLICATE_EXIT:  We already have a job running.
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ DUPLICATE_EXIT:
$ exit
$ !
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ ! Routine SUCCESS_EXIT:  We have processed all the files.
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ SUCCESS_EXIT:
$ def/sys vsta$sixelizer_available NO		! Flag that we are gone.
$ exit
$ !
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ ! Routine ERROR_EXIT:  Do something about this error!
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ ERROR_EXIT:
$ def/sys vsta$sixelizer_available NO		! Flag that we are gone.
$ delete/log 'sixel_file';			! Delete the useless output.
$ delete/log 'oldest'				! Delete the bad image file.
$ exit
