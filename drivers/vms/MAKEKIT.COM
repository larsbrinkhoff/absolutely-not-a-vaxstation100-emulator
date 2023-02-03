$ ! MAKEKIT.COM	  
$ !
$ ! Purpose:	  	Build an actual saveset
$ !	Uses files collected by GET_KIT_FILES.COM to build an
$ !	actual VMSINSTAL saveset.
$ !
$ kit_name := vsta020			! For easy changes...
$!
$! Set logical pointers for build here.
$!
$!   Define source directory with files from GET_KIT_FILES.COM
$ define bl$kit_files	asd$public:[vs100.test]
$!   Define destination directory for saveset
$ define bl$saveset	asd$public:[vs100.test.saveset]
$!
$! Make saveset.
$!
$ spkitbld:
$ @bl$kit_files:spkitbld 'kit_name' bl$saveset: bl$kit_files:*.* N 
$ set protection=(s:rewd,o:rewd,g:rewd,w:re)  bl$saveset:'kit_name'.a
$!
$!
$ exit
