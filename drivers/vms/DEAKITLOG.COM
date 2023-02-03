$ !
$ ! Deassign all logicals used by install procedure.
$ !
$	ON CONTROL_Y THEN VMI$CALLBACK CONTROL_Y
$	ON ERROR THEN GOTO error_exit
$	OPEN logical_file VMI$KWD:KITLOGS.DAT
$ loop:
$	READ/END_OF_FILE=all_done logical_file line
$	space = 'F$LOCATE(" ",line)'
$	tab = 'F$LOCATE("	",line)'
$	IF space .GT. tab THEN space = tab
$	logical_name := 'F$EXTRACT(0,space,line)'
$	DEASSIGN 'logical_name'
$	GOTO loop
$ error_exit:
$	IF "''F$LOGICAL(""logical_file"")'" .NES. "" THEN CLOSE logical_file
$	EXIT VMI$_FAILURE
$ all_done:
$	CLOSE logical_file
