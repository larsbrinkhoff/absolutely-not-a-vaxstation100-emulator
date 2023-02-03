$on control_y then goto bad_kit
$on warning then goto bad_kit
$ask = "inquire/nopunctuation"
$say = "write sys$output"
$remount = 0
$say "''f$fao("!/!/!_VAX/VMS V4.0 Software Product Kit Build Procedure!/")"
$p = "CMKRNL,LOG_IO,SYSNAM,VOLPRO"
$saved_privs = f$setprv(p)
$if .not. f$priv(p) then say "You need the following privileges: ",p
$if .not. f$priv(p) then goto bad_kit
$if p1 .nes. "" then goto m5
$type sys$input:
Kits have names in the format facvvu, where fac is the facility name,
vv is the major version number, and u is the update number.
$ask p1 "Which kit would you like to build: "
$m5: facility = f$ext(0,f$len(p1)-3,p1)
$version = 'f$ext(f$len(p1)-3,2,p1)
$update = 'f$ext(f$len(p1)-1,1,p1)
$dest = p2
$if dest .eqs. "" then ask dest "On which device is the kit to be built: "
$if f$loc(":",dest) .eq. f$len(dest) then dest = dest + ":"
$device = f$parse(dest,,,"DEVICE","SYNTAX_ONLY")
$destdir = f$parse(dest,"[0,0]",,"DIRECTORY","SYNTAX_ONLY")
$dest = device + destdir
$if f$loc("CSA",device) .ne. f$len(device) then goto m7
$if f$getdvi(dest,"EXISTS") then -
if f$getdvi(dest,"DEVCLASS") .eq. 1 .or. -
f$getdvi(dest,"DEVCLASS") .eq. 2 then goto m7
$say "Device must be a disk or tape."
$goto bad_kit
$m7:
$remount = f$loc("CSA",device) .ne. f$len(device)
$if .not. remount then goto m9
$s = "$sysgen"
$s connect console
$if f$getdvi(device,"MNT") then dismount 'device
$allocate 'device
$m9:
$if f$getdvi(device,"DEVCLASS") .eq. 1 .and. -
f$getdvi(device,"MNT") .and. -
.not. f$getdvi(device,"FOR") then goto m15
$if f$getdvi(device,"MNT") .and. f$getdvi(device,"FOR") .and. -
f$getdvi(device,"DEVCLASS") .eq. 2 then goto m_tape
$if f$getdvi(device,"MNT") then dismount/nounload 'device
$say "Please ready the first distribution volume on ''device."
$m10: ask w "Are you ready? "
$if .not. w then goto m10
$mount/foreign/noassist 'device
$remount = 1
$m15: if f$getdvi(device,"DEVCLASS") .eq. 2 then goto m_TAPE
$if f$getdvi(device,"MAXBLOCK") .gt. 8*512 then goto m_DISK
$m_CONSOLE:
$backup_quals = "/init/block=9000/group=25"
$if f$len(facility) .gt. 10 then facility = f$ext(0,10,facility)
$labels = "''facility'01,''facility'02,''facility'03,''facility'04,''facility'05,"
$labels = labels + "''facility'06,''facility'07,''facility'08,''facility'09,''facility'10"
$goto m20
$m_DISK:
$backup_quals = "/block=9000/group=25"
$labels = facility
$lim = 12
$goto m19
$m_TAPE:
$backup_quals = "/rewi/dens=1600"
$ask w "Are there already savesets on this tape? "
$if w then backup_quals = "/norewi/dens=1600"
$if f$getdvi(device,"DEVTYPE") .eq. 10 then -
backup_quals = backup_quals - "/dens=1600" + "/buffers=5"
$labels = facility
$lim = 6
$goto m19
$m19:
$if f$len(labels) .le. lim then goto m20
$labels = f$ext(0,lim,labels)
$m20:
$say "Saveset A must contain the KITINSTAL.COM procedure."
$letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
$ssn = 0
$s10:
$ssn = ssn + 1
$ssname = f$ext(ssn-1,1,letters)
$ssid = ssname
$if ssn .gt. 26 then ssname = f$fao("VMI_!4ZL",ssn)
$if ssn .gt. 26 then ssid = f$fao("!4ZL",ssn)
$say "''f$fao("!/!_!AS V!UL.!UL, Saveset !AS!/",facility,version,update,ssid)"
$f = p3
$if p3 .eqs. "" then ask f "Which files: "
$prot = "(S:RWED,O:RWED,G:RWED,W:RE)"
$write sys$output "Resetting protection on all files to ",prot,"..."
$set protection='prot 'f
$s12: backup/comment="VAX/VMS SPKITBLD Procedure"/inter/log/verify -
'f -
'dest''p1.'ssname/label=('labels)/save'backup_quals
$ask w "Is there another saveset to create [NO]? "
$if .not. w then goto s19
$p3 = ""
$backup_quals = backup_quals + "/noinit/norewi"
$if f$getdvi(device,"DEVCLASS") .eq. 2 .or. -
f$getdvi(device,"MAXBLOCK") .gt. 8*512 then goto s10
$ask w "Does it need to start on a new volume [NO]? "
$if .not. w then goto s10
$dismount/nounload 'device
$mount/foreign/noassist/nomessage 'device
$i = f$loc(f$getdvi(device,"VOLNAM"),labels)
$labels = f$ext(i+f$len(facility)+3,999,labels)
$if f$len(labels) .le. lim then goto s13
$labels = f$ext(f$len(labels)-lim,lim,labels)
$s13: backup_quals = backup_quals + "/init"
$dismount 'device
$say "Please mount the next distribution volume on ''device."
$s15: ask w "Are you ready? "
$if .not. w then goto s15
$mount/foreign/noassist 'device
$goto s10
$s19:
$say "''f$fao("!/!_Kit Build Completed Successfully!/!/")"
$done:
$on warning then exit
$if .not. remount then goto d9
$if f$getdvi(device,"MNT") then dismount/nounload 'device
$if f$loc("CSA",device) .eq. f$len(device) then goto d9
$say "Please remount the console volume."
$d5: ask w "Are you ready? "
$if .not. w then goto d5
$mount/foreign/system/protection=s:rwlp/nowrite/noassist 'device console
$d9: w = f$setpriv(saved_privs)
$exit
$bad_kit:
$type sys$input:

	+---------------------+
	|		      |
	|  THIS IS A BAD KIT  |
	|		      |
	+---------------------+

$goto done
