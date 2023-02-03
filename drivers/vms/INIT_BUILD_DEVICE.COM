$ !--------------------------------------------------------------------------
$ ! Initializes and creates necessary directories on VS100 build disk.
$ !
$ ! Also initializes library directory by copying neccessary object libraries
$ ! to it.  Note that source directory name is hard coded and must be
$ ! changed if the directory is moved.
$ !--------------------------------------------------------------------------
$ !
$ ! Define logicals for build device and source library directory.
$ !
$ define vsta_dev dma0:
$ define vsta_source$library asd$public:[vs100.library]
$ !
$ ! Initialize and mount device.
$ !
$ init vsta_dev: vsta
$ mount vsta_dev: vsta
$ !
$ ! Create necessary directories.
$ !
$ create/directory vsta_dev:[vs100.bl]
$ set def vsta_dev:[vs100.bl]
$ create/dir [.source]
$ create/dir [.build]
$ create/dir [.library]
$ create/dir [.exe]
$ create/dir [.hilib]
$ create/dir [.scaff]
$ !
$ ! Fill library directory.
$ !
$ copy vsta_source$library:*.* [.library]
$ ! 
$ ! Exit
$ !
$ dismount/nounload vsta_dev:
$ exit
