MODULE vsta$cgl_segs;
{-----------------------------------------------------------------------------
!
!  SEGS.CGL - CGL segment functions
!
-----------------------------------------------------------------------------}

%include 'VSTA$LIBRARY:VSCGLDEF'

{table of contents}

[global] procedure G$CRS(var seg_name : integer); forward;
[global] procedure G$EXS(var seg_name : integer); forward;
[global] procedure G$IOS(var seg_name : integer); forward;
[global] procedure G$CLS; forward;
[global] procedure G$DLS(var seg_name : integer); forward;
[global] procedure G$DLAS; forward;
[global] procedure G$RNS(var old_name,new_name : integer); forward;
[global] procedure G$SGV(var v : integer); forward;
[global] procedure G$IGV(var v : integer); forward;
[global] procedure G$SSV(var seg_name,v : integer); forward;
[global] procedure G$ISV(var seg_name,v : integer); forward;
[global] procedure G$SGA(var list1 : G$integer_attributes;
		var list2 : G$real_attributes); forward;
[global] procedure G$IGA(var list1 : G$integer_attributes;
		var list2 : G$real_attributes); forward;
[global] procedure G$SSA(var seg_name : integer;
		var list1 : G$integer_attributes;
		var list2 : G$real_attributes); forward;
[global] procedure G$ISA(var seg_name : integer;
		var list1 : G$integer_attributes;
		var list2 : G$real_attributes); forward;
[global] procedure G$SSS(var seg_name : integer; var x,y : real); forward;
[global] procedure G$ISS(var seg_name : integer; var x,y : real); forward;

procedure G$CRS;

begin
end;


procedure G$EXS;

begin
end;


procedure G$IOS;

begin
end;


procedure G$CLS;

begin
end;


procedure G$DLS;

begin
end;


procedure G$DLAS;

begin
end;


procedure G$RNS;

begin
end;


procedure G$SGV;

begin
end;


procedure G$IGV;

begin
end;


procedure G$SSV;

begin
end;


procedure G$ISV;

begin
end;


procedure G$SGA;

begin
end;


procedure G$IGA;


begin
end;


procedure G$SSA;

begin
end;


procedure G$ISA;

begin
end;


procedure G$SSS;

begin
end;


procedure G$ISS;

begin
end;



END.
