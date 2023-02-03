MODULE vsta$cgl_view;
{-----------------------------------------------------------------------------
!
!  VIEW - CGL Viewing Functions
!
-----------------------------------------------------------------------------}

%include 'VSTA$LIBRARY:VSCGLDEF'

{table of contents}

[global] procedure G$SW(var xmin,xmax,ymin,ymax : real); forward;
[global] procedure G$IW(var xmin,xmax,ymin,ymax : real); forward;
[global] procedure G$SV(var xmin,xmax,ymin,ymax : real); forward;
[global] procedure G$IV(var xmin,xmax,ymin,ymax : real); forward;
[global] procedure G$SC(var s : integer); forward;
[global] procedure G$IC(var s : integer); forward;
[global] procedure G$SO(var c : integer); forward;
[global] procedure G$IO(var c : integer); forward;
[global] procedure G$EV; forward;
[global] procedure G$SCRL(var dx,dy : real); forward;

{external references}

function G$get_ptr : G$impure_ptr; external;
function G$wsx(x : real) : integer; external;
function G$wsy(y : real) : integer; external;
procedure G$do(var command : G$instr_type); external;
procedure G$error_handler(f,e : integer); external;
procedure G$view(new_window : boolean); external;
procedure G$SCS(var width,height : real); external;
procedure G$SCA(var d,m : integer); external;
procedure G$SCM(var dx,dy : real); external;
procedure G$SLW(var dx,dy : real); external;
procedure G$bounds(clip : boolean); external;




procedure G$SW;
  {Set_Window(var xmin,xmax,ymin,ymax : real)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do
    if G$seg_open
      then G$error_handler(FNG$SW,301)
      else if (xmin >= xmax) or (ymin >= ymax)
	then G$error_handler(FNG$SW,501)
	else begin
	  G$window[G$LEFT]  := xmin;	{set new window}
	  G$window[G$RIGHT] := xmax;
	  G$window[G$BOTTOM]:= ymin;
	  G$window[G$TOP]   := ymax;
	  G$view(TRUE)			{find new transformation constants}
	end
end;



procedure G$IW;
  {Inquire_Window(var xmin,xmax,ymin,ymax : real)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    xmin:= G$window[G$LEFT];
    xmax:= G$window[G$RIGHT];
    ymin:= G$window[G$BOTTOM];
    ymax:= G$window[G$TOP]
  end
end;



procedure G$SC;
  {Set_window_Clipping(var s : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do
    if G$seg_open
      then G$error_handler(FNG$SC,301)
      else begin
	G$clipping:= s;
	G$bounds(G$clipping <> 0)	{internal set clipping boundaries}
      end
end;



procedure G$IC;
  {Inquire_window_Clipping(var s : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    s:= G$clipping
  end
end;



procedure G$SV;
  {Set_Viewport_2(var xmin,xmax,ymin,ymax : real)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do
    if G$seg_open
      then G$error_handler(FNG$SV,301)
      else begin
	if ((xmax - xmin) <= 0) or ((ymax - ymin) <= 0)
	  then G$error_handler(FNG$SV,501)
	  else if (xmin < 0) or (xmin > 1) or (xmax < 0) or (xmax > 1) or
		  (ymin < 0) or (ymin > 1) or (ymax < 0) or (ymax > 1)
	    then G$error_handler(FNG$SV,505)
	    else begin
	      G$viewport[G$LEFT]  := xmin;	{set new viewport}
	      G$viewport[G$RIGHT] := xmax;
	      G$viewport[G$BOTTOM]:= ymin;
	      G$viewport[G$TOP]   := ymax;
	      G$view(FALSE);
						{rescale things for new view}
						{NOTE: order is important!}
	      G$SCS(G$char_width,G$char_height);
	      G$SCM(G$char_width_spacing,G$char_height_spacing);
	      G$SCA(G$char_path,G$char_rotation_mode);
	      G$SLW(G$line_width,G$line_height);
	      G$bounds(G$clipping <> 0)		{and set clipping boundaries}
	    end
      end
end;



procedure G$IV;
  {Inquire_Viewport_2(var xmin,xmax,ymin,ymax : real)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    xmin:= G$viewport[G$LEFT];
    xmax:= G$viewport[G$RIGHT];
    ymin:= G$viewport[G$BOTTOM];
    ymax:= G$viewport[G$TOP]
  end
end;



procedure G$SO;
  {Set_Origin(var c : integer)}

var
  ida	: G$impure_ptr;

begin
  if (c < G$BOTTOM_LEFT) or (c > G$BOTTOM_RIGHT)
    then G$error_handler(FNG$SO,401)
    else begin
      ida:= G$get_ptr;
      with ida^ do begin
	G$origin:= c;
	G$corner[0]:= (c = G$TOP_RIGHT) or (c = G$BOTTOM_RIGHT);
	G$corner[1]:= (c = G$BOTTOM_LEFT) or (c = G$BOTTOM_RIGHT);
	G$view(TRUE);
	G$bounds(G$clipping <> 0)		{set clipping boundaries}
      end
  end
end;



procedure G$IO;
  {Inquire_Origin(var c : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    c:= G$origin
  end
end;



procedure G$EV;
  {Erase_Viewport()}

var
  cmd	: G$instr_type;

begin
  with cmd do begin
    G$instr:= G$screen_erase;
    G$parameter_count:= 0
  end;
  G$do(cmd)
end;



procedure G$SCRL;
  {SCRolL(var dx,dy : real)}

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  G$bounds(FALSE);			{ensure region is whole screen..}
  with cmd do begin
    G$instr:= G$scroll;
    G$parameter_count:= 2;
    G$parameter_list[1]:= G$wsx(dx) - G$wsx(0);
    G$parameter_list[2]:= G$wsy(dy) - G$wsy(0)
  end;
  G$do(cmd);
  G$bounds(ida^.G$clipping <> 0)	{and restore clipping region}
end;



END.
