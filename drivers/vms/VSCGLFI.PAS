MODULE vsta$cgl_fill;
{-----------------------------------------------------------------------------
!
!  FILL - CGL Fill Functions
!
-----------------------------------------------------------------------------}

%include 'VSTA$LIBRARY:VSCGLDEF'

{table of contents}

[global] procedure G$SFM(var m : integer); forward;
[global] procedure G$IFM(var m : integer); forward;
[global] procedure G$SFA(var x,y : real); forward;
[global] procedure G$IFA(var x,y : real); forward;
[global] procedure G$SFC(var n,c,wm,hm : integer); forward;
[global] procedure G$IFC(var n,c,wm,hm : integer); forward;

{external references}

function G$get_ptr : G$impure_ptr; external;
function G$wsx(x : real) : integer; external;
function G$wsy(y : real) : integer; external;
procedure G$do(var command : G$instr_type); external;
procedure G$error_handler(f,e : integer); external;



procedure G$SFM;
  {Set_Fill_Mode(var m : integer)}

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;

begin
  if (m < G$OFF) or (m > G$TO_POINT)
    then G$error_handler(FNG$SFM,401)
    else begin
      ida:= G$get_ptr;
      with ida^ do with cmd do begin
	G$fill_mode:= m;
	if G$fill_mode <> 0
	  then begin					{set fill ON}
	    G$instr:= G$set_fill_x;			{default to x}
	    G$parameter_count:= 1;
	    G$parameter_list[1]:= G$wsx(G$fill_x);
	    G$parameter_list[2]:= G$wsy(G$fill_y);
	    if G$fill_mode = G$TO_Y
	      then begin				{but this is to y}
		G$instr:= G$set_fill_y;
		G$parameter_list[1]:= G$parameter_list[2]
	      end
	      else if G$fill_mode = G$TO_POINT
		then begin				{and this to point}
		  G$instr:= G$set_fill_point;
		  G$parameter_count:= 2
		end
	  end
	  else begin
	    G$instr:= G$set_fill_off;			{set fill OFF}
	    G$parameter_count:= 0
	  end
	end;
      G$do(cmd)
  end
end;



procedure G$IFM;
  {Inquire_Fill_Mode(var m : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  m:= ida^.G$fill_mode
end;



procedure G$SFA;
  {Set_Fill_Axes(var x,y : real)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    G$fill_x:= x;
    G$fill_y:= y;
    if G$fill_mode <> 0			{if fill is ON..}
      then G$SFM(G$fill_mode)		{go update fill coordinate(s)}
  end
end;



procedure G$IFA;
  {Inquire_Fill_Axes(var x,y : real)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    x:= G$fill_x;
    y:= G$fill_y
  end
end;



procedure G$SFC;
  {Set_Fill_Char(var n,c,wm,hm : integer)}

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    G$fill_font:= n;
    G$fill_char:= c;
    G$fill_char_width_multiplier:= wm;
    G$fill_char_height_multiplier:= hm;
    with cmd do begin
      G$instr:= G$set_fillstyle;
      G$parameter_count:= 4;
      G$parameter_list[1]:= G$fill_font;
      G$parameter_list[2]:= G$fill_char;
      G$parameter_list[3]:= G$char_unit_width *
					G$fill_char_width_multiplier;
      G$parameter_list[4]:= G$char_unit_height *
					 G$fill_char_height_multiplier
    end;
    G$do(cmd)
  end
end;



procedure G$IFC;
  {Inquire_Fill_Char(var n,c,wm,hm : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    n:= G$fill_font;
    c:= G$fill_char;
    wm:= G$fill_char_width_multiplier;
    hm:= G$fill_char_height_multiplier
  end
end;



END.
