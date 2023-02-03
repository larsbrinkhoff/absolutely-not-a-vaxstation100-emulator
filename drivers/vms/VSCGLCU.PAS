MODULE vsta$cgl_curves;
{----------------------------------------------------------------------------
!  CURVES - CGL Arc and Curve Functions
!
-----------------------------------------------------------------------------}

%include 'VSTA$LIBRARY:VSCGLDEF'

{table of contents}

[global] procedure G$AA(var x,y : real; var angle : integer); forward;
[global] procedure G$AR(var dx,dy : real; var angle : integer); forward;
[global] procedure G$CA(var x,y : G$reals; var n,b : integer); forward;
[global] procedure G$CR(var dx,dy : G$reals; var n,b : integer); forward;

{external references}

function G$get_ptr : G$impure_ptr; external;
function G$wsx(x : real) : integer; external;
function G$wsy(y : real) : integer; external;
procedure G$do(var command : G$instr_type); external;
procedure G$MA(var x,y : real); external;
procedure G$MR(var dx,dy : real); external;
procedure G$ICP(var x,y : real); external;
procedure G$error_handler(f,e : integer); external;
procedure G$ask_cp(var x,y : real); external;

{
 NOTE: CGL does not attempt to clip arcs or curves 
       nor are they correctly transformed.
}


procedure G$AA;
  {Arc_Abs_2(var x,y : real;
	     var angle : integer)}

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;

begin
  with cmd do begin
    G$instr:= G$arc;
    G$parameter_count:= 3;
    G$parameter_list[1]:= G$wsx(x);		{x,y is on circumference}
    G$parameter_list[2]:= G$wsy(y);
    G$parameter_list[3]:= angle
  end;
  G$do(cmd);					{draw the arc}
  ida:= G$get_ptr;
  with ida^ do begin
    G$ask_cp(G$current_x_position,G$current_y_position);	{update cp}
  end
end;



procedure G$AR;
  {Arc_Rel_2(var dx,dy : real;
	     var angle : integer)}

var
  x,y	: real;

begin
  G$ICP(x,y);
  x:= x + dx;
  y:= y + dy;
  G$AA(x,y,angle)
end;



procedure curve_point(x,y : real);
  {send a curve continuation point}

var
  cmd	: G$instr_type;

begin
  with cmd do begin
    G$instr:= G$curve_continue;
    G$parameter_count:= 2;
    G$parameter_list[1]:= G$wsx(x);
    G$parameter_list[2]:= G$wsy(y)
  end;
  G$do(cmd)
end;



procedure G$CA;
  {Curve_Abs_2(var x,y : G$reals;
	       var n,b : integer)}

var
  cmd	: G$instr_type;
  i,j	: integer;

begin
  if n <= 0
    then G$error_handler(FNG$CA,2)
    else if ( n <= 2 )
      then G$error_handler(FNG$CA,3)		{not enough points?}
      else begin
	cmd.G$parameter_count:= 0;
	G$MA(x[1],y[1]);			{move to first point}
	if b <> 0
	  then begin				{begin a closed sequence..}
	    cmd.G$instr:= G$curve_closed;
	    j:= 2				{start at 2nd point}
	  end
	  else begin				{begin an open sequence..}
	    cmd.G$instr:= G$curve_open;
	    j:= 1				{first point is cp}
	  end;
	G$do(cmd);				{start the curve}
	for i:= j to n do
	  curve_point(x[i],y[i]);
	cmd.G$instr:= G$curve_end;		{get set to end}
	if b <> 0
	  then begin
	    G$do(cmd);				{end the closed curve..}
	    G$MA(x[1],y[1])			{update firmware cp!}
	  end
	  else begin				{end the open curve..}
	    curve_point(x[n],y[n]);		{duplicate last point to end}
	    G$do(cmd);
	    G$MA(x[n],y[n])			{update current position}
	  end
      end
end;



procedure G$CR;
  {Curve_Rel_2(var dx,dy : G$reals;
	       var n,b : integer)}

var
  cmd	: G$instr_type;
  i	: integer;
  x,y,
  x1,y1	: real;

begin
  if n <= 0
    then G$error_handler(FNG$CR,2)
    else if ( n <= 2 )
      then G$error_handler(FNG$CA,3)		{not enough points?}
      else begin
	G$MR(dx[1],dy[1]);			{move to first point}
	G$ICP(x,y);				{and take a copy}
	cmd.G$parameter_count:= 0;
	if b <> 0
	  then begin				{begin a closed sequence..}
	    cmd.G$instr:= G$curve_closed;
	    G$do(cmd);
	    x1:= x;  y1:= y			{remember this for end}
	  end
	  else begin				{begin an open sequence..}
	    cmd.G$instr:= G$curve_open;
	    G$do(cmd);
	    curve_point(x,y)			{first point is cp}
	  end;
	for i:= 2 to n do begin
	  x:= x + dx[i];  y:= y + dy[i];
	  curve_point(x,y)
	end;
	cmd.G$instr:= G$curve_end;
	if b <> 0
	  then begin				{end the closed curve..}
	    G$do(cmd);
	    G$MA(x1,y1)				{cursor to start}
	  end
	  else begin				{end the open curve..}
	    curve_point(x,y);			{send last point again}
	    G$do(cmd);
	    G$MA(x,y)				{update current position}
	  end
      end
end;


END.
