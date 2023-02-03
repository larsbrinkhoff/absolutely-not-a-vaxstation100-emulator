MODULE vsta$cgl_lines;
{-----------------------------------------------------------------------------
!
!  LINES - CGL Line Drawing Functions
!
-----------------------------------------------------------------------------}

%include 'VSTA$LIBRARY:VSCGLDEF'

{table of contents}

[global] procedure G$LA(var x,y : real); forward;
[global] procedure G$LR(var dx,dy : real); forward;
[global] procedure G$PLA(var x,y : G$reals; var n : integer); forward;
[global] procedure G$PLR(var dx,dy : G$reals; var n : integer); forward;
[global] procedure G$PGA(var x,y : G$reals; var n : integer); forward;
[global] procedure G$PGR(var dx,dy : G$reals; var n : integer); forward;
[global] procedure G$RA(var x,y : real); forward;
[global] procedure G$RR(var dx,dy : real); forward;
[global] procedure G$SLS(var n,p,m : integer); forward;
[global] procedure G$ILS(var n,p,m : integer); forward;
[global] procedure G$SLW(var dx,dy : real); forward;
[global] procedure G$ILW(var dx,dy : real); forward;

{external references}

function G$get_ptr : G$impure_ptr; external;
function G$wsx(x : real) : integer; external;
function G$wsy(y : real) : integer; external;
procedure G$do(var command : G$instr_type); external;
procedure G$MA(var x,y : real); external;
procedure G$MR(var dx,dy : real); external;
procedure G$ICP(var x,y : real); external;
procedure G$SFC (var n,c,wm,hm : integer); external;
procedure G$width(dx,dy : real); external;
procedure G$error_handler(f,e : integer); external;




{
 NOTE: lines are drawn whether they are outside the window or not since fill
       may be on.  In a future release some optimization may be done.
}


procedure G$LA;
  {Line_Abs_2(var x,y : real)}

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
{-----------------------------------------------------------------------------
    if (G$clipping = 0) or
       (G$clipping <> 0) and
	  G$clip(G$current_x_position, G$current_y_position, x, y)
      then begin
-----------------------------------------------------------------------------}
	with cmd do begin
	  G$instr:= G$vector;
	  G$parameter_count:= 2;
	  G$parameter_list[1]:= G$wsx(x);
	  G$parameter_list[2]:= G$wsy(y)
	end;
	G$do(cmd);
	G$current_x_position:= x;
	G$current_y_position:= y
  end
end;



procedure G$LR;
  {Line_Rel_2(var dx,dy : real)}

var
  x,y	: real;

begin
  G$ICP(x,y);
  x:= x + dx;
  y:= y + dy;
  G$LA(x,y)
end;



procedure G$PLA;
  {PolyLine_Abs_2(var x,y : G$reals;
		  var n : integer)}

var
  i	: integer;

begin
  if n < 0
    then G$error_handler(FNG$PLA,2)
    else for i:= 1 to n do
      G$LA(x[i],y[i])
end;



procedure G$PLR;
  {PolyLine_Rel_2(var dx,dy : G$reals;
		  var n : integer)}

var
  i	: integer;

begin
  if n < 0
    then G$error_handler(FNG$PLR,2)
    else for i:= 1 to n do
      G$LR(dx[i],dy[i])
end;



procedure G$PGA;
  {PolyGon_Abs_2(var x,y : G$reals;
		 var n : integer)}

var
  i	: integer;

begin
  if n <= 2
    then G$error_handler(FNG$PGA,3)
    else begin
      G$MA(x[1],y[1]);				{move to first point}
      for i:= 2 to n do
	G$LA(x[i],y[i]);
      G$LA(x[1],y[1])				{back from whence we came}
    end
end;



procedure G$PGR;
  {PolyGon_Rel_2(var dx,dy : G$reals;
		 var n : integer)}

var
  x,y	: real;
  i	: integer;

begin
  if n <= 2
    then G$error_handler(FNG$PGR,3)
    else begin
      G$MR(dx[1],dy[1]);			{move to first point}
      G$ICP(x,y);				{save for last line}
      for i:= 2 to n do
	G$LR(dx[i],dy[i]);
      G$LA(x,y)					{back to start}
    end
end;



procedure G$RA;
  {Rectangle_Abs_2(var x,y : real)}

var
  p,q	: real;

begin
  G$ICP(p,q);					{get current x,y}
  G$LA(x,q);					{across..}
  G$LA(x,y);					{...up...}
  G$LA(p,y);					{..back..}
  G$LA(p,q)					{....down}
end;



procedure G$RR;
  {Rectangle_Rel_2(var dx,dy : real)}

var
  x,y	: real;

begin
  G$ICP(x,y);
  x:= x + dx;
  y:= y + dy;
  G$RA(x,y)
end;



procedure G$SLS;
  {Set_LineStyle(var n,p,m : integer)}

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;
  G$line_style_array   : G$line_styles;

begin
  ida:= G$get_ptr;
  G$line_style_array[1]  :=			%O177777;	{1 111 111 111 111 111}
  G$line_style_array[2]  :=			%O007417;	{0 000 111 100 001 111}
  G$line_style_array[3]  :=			%O057537;	{0 101 111 101 011 111}
  G$line_style_array[4]  :=			%O052525;	{0 101 010 101 010 101}
  G$line_style_array[5]  :=			%O053527;	{0 101 011 101 010 111}
  G$line_style_array[6]  :=			%O010421;	{0 001 000 100 010 001}
  G$line_style_array[7]  :=			%O031463;	{0 011 001 100 110 011}
  G$line_style_array[8]  :=			%O037477;	{0 011 111 100 111 111}
  G$line_style_array[9]  :=			%O005413;	{0 000 101 100 001 011}
  with ida^ do begin
    G$line_style_number:= n;
    if (n < 1) or (n > G$FIXED_LINE_STYLES)
      then begin				{user defined..}
	G$line_style_pattern:= p;		{pattern}
	G$line_style_multiplier:= m		{and multiplier}
      end
      else begin				{wants a predefined one..}
	G$line_style_pattern:= G$line_style_array[n];
	G$line_style_multiplier:= G$LINE_STYLE_STANDARD_MULTIPLIER
      end;
    with cmd do begin
      G$instr:= G$set_linestyle;
      G$parameter_count:= 3;
      G$parameter_list[1]:= 16;		{the (not-unused) length -lsc-bugfix 21 October 83}
      G$parameter_list[2]:= G$line_style_pattern;
      G$parameter_list[3]:= G$line_style_multiplier
    end;
    G$do(cmd);
  end
end;



procedure G$ILS;
  {Inquire_LineStyle(var n,p,m : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    n:= G$line_style_number;
    p:= G$line_style_pattern;
    m:= G$line_style_multiplier;
    if n = 1 then p := -1
  end
end;



procedure G$SLW;
  {Set_LineWidth(var dx,dy : real)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    G$line_width:= dx;
    G$line_height:= dy;
    if dx < 0.0		{check for negative line dimensions}
    then			
	G$line_width:= 0.0;
    if dy < 0.0
    then
	G$line_height:= 0.0;
    G$width(G$line_width,G$line_height)		{internal set line thickness}
  end
end;



procedure G$ILW;
  {Inquire_LineWidth(var dx,dy : real)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    dx:= G$line_width;
    dy:= G$line_height
  end
end;



END.
