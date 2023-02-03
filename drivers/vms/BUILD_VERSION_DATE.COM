$ ! BUILD_VERSION.COM 
$ ! This file writes the date and time into a temp file and them
$ ! merges it with the buildver module of the ACP.
$ !
$ !
$ ! Create an empty file, and append the module header to it.
$ !
$ temp_file = "date_time.tmp"
$ copy nl: vsta$source:buildver.b32
$ append vsta$source:buildver_header.b32 vsta$source:buildver.b32
$ !
$ ! Now write our build and date specific line to the temp file.
$ !
$ open/write temp 'temp_file'
$ WRITE temp "MACRO bldver = 'VSTA V1.2-02 ",F$EXTRACT(0,17,f$time() ),"' %;"
$ close temp
$ !
$ ! Append the temp file to the module header.
$ !
$ write sys$output "[An incomptabible attributes message may be ignored.]"
$ append 'temp_file' vsta$source:buildver.b32
$ delete 'temp_file'.*
$ !
$ ! Append the module footer to finish the job.
$ !
$ append vsta$source:buildver_footer.b32 vsta$source:buildver.b32
$ purge vsta$source:buildver.b32
$ exit
