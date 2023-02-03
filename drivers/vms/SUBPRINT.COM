$ set ver
$ set file/version_limit=1000 vsta$hilib:vstaprint.dat
$ a = f$logical("vsta$sixelizer_available")
$ if a .eqs. "YES" then goto QUIT
$ submit/user=system vsta$com:vstaprint.com/queue=vsta$batch/noprint/log=vsta$com:
$ QUIT:
$ purge vsta$com:subprint.log/keep=3
$ purge vsta$com:vstaprint.log/keep=3
$ exit
