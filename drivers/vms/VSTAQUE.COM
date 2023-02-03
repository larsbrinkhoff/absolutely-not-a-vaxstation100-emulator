$ !
$ ! VSTA$PRINTER must be defined, and must point to a terminal.
$ ! VSTA$BATCH must be defined, and must point to a batch queue.
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ ! CHECK ENVIRONMENT	(Are required logical names in place?)
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ if f$Logical("vsta$printer") .eqs. "" then goto ERROR_EXIT
$ if f$Logical("vsta$batch") .eqs. "" then goto ERROR_EXIT
$ !
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ ! SET UP QUEUE
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ set process/privilege=all				! Enable privileges
$ ! CHECK OUTPUT DEVICE NOW THAT WE HAVE A VERSATEC
$ if f$extract(0,3,f$logical("vsta$printer")) .eqs. "_LV" then goto VRSA_QUE
$ set term/dev=la100/sixel/nowrap/nobroadcast/pasthru/notype/noecho/wid=132/perm vsta$printer
$ define/form VSTA/margin=(bottom=0)/notrun/nowrap/stock=default/descr="VAXstation printer sixel output" 34
$ VRSA_QUE:
$ initialize/queue/default=(noburst,noflag,nofeed)/form=VSTA/prot=w:wr/start/on:vsta$printer vsta$printer
$ goto SUCCESS_EXIT
$ !
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ ! ERROR_EXIT
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ ERROR_EXIT:
$ write sys$output "VAXstation print queue setup failed."
$ exit
$ !
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ ! SUCCESS_EXIT
$ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ SUCCESS_EXIT:
$ exit
