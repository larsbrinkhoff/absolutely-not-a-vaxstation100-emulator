$ !----------------------------------------------------------------------
$ ! Main VSTA software build routine.
$ !
$ ! Establishes logicals for directories used by MMS build procedure,
$ ! and by other build procedures.  Calls BUILD_VERSION_DATE.COM to
$ ! establish the version name and date, and then calls MMS to build the
$ ! software.
$ !
$ ! Note that the device which houses these directories is hard coded;
$ ! this must be changed to build on a different device.
$ !
$ !--------------------------------------------------------------------
$ !
$ all dma0:
$ mount/noassist dma0: vsta
$ !
$ on error then goto exit
$ set process/name="VSTA build"
$ set default dma0:[vs100.bl.build]
$ !
$ !	Set all logical pointers and set CMS library
$ !
$ define vsta$com 	dma0:[vs100.bl.source]
$ define vsta$source	dma0:[vs100.bl.source],-
 			dma0:[vs100.bl.build]
$ define vsta$build 	dma0:[vs100.bl.build],-
			dma0:[vs100.bl.source]
$ define vsta$library	dma0:[vs100.bl.library]
$ define vsta$exe 	dma0:[vs100.bl.exe]
$ define vsta$hilib 	dma0:[vs100.bl.hilib]
$ define vsta$scaff	dma0:[vs100.bl.scaff]
$ cms set library	asd$public:[vs100.decus_cmscode]
$ !
$ !   Some old sources look for require files on VS:
$ !
$ define vs dma0:[vs100.bl.library] 
$ !
$ !   Don't have access to syslib or syscomm so redirect logical then restore.
$ !
$ define sys$library	vsta$library -
			,sys$sysroot:[syslib]
$ !
$ !   Define library for linker
$ !
$ define lnk$library vsta$library:vstaimg
$ !
$ !   Build version date
$ !
$ cms fetch build_version_date.COM "for combine.com build"
$ cms fetch buildver_header.b32 "for combine.com build"
$ cms fetch buildver.b32 "for combine.com build"
$ cms fetch buildver_footer.b32 "for combine.com build"
$ @build_version_date
$ ! .bl is destination directory.
$ set default dma0:[vs100.bl.source]			
$ ! get various libraries into the build/source directory
$ copy vsta$library:*.*   *.*
$ !
$ MMS/cms/description=combine.mms everything
$ !
$ ! Restore logical pointers
$ !
$ define sys$library	sys$sysroot:[syslib]
$ !
$ exit:
$ dismount/nounload dma0:
$ exit
