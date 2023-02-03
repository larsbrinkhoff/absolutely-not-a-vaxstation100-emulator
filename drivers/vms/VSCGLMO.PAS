MODULE vsta$cgl_moves;
{-----------------------------------------------------------------------------
!
!  MOVES - CGL Current Position Functions
!
-----------------------------------------------------------------------------}

%include 'VSTA$LIBRARY:VSCGLDEF'

{table of contents}

[global] procedure G$MA(var x,y : real); forward;
[global] procedure G$MR(var dx,dy : real); forward;
[global] procedure G$ICP(var x,y : real); forward;

{external references}

function G$get_ptr : G$impure_ptr; external;
function G$wsx(x : real) : integer; external;
function G$wsy(y : real) : integer; external;
procedure G$do(var command : G$instr_type); external;

{
 NOTE: moves are made whether the move is to outside the window or not;
       this keeps the "firmware" cp in step with CGLs cp.  In a future
       release some optimization may be done (i.e. only move as necessary).
}


procedure G$MA;
  {Move_Abs_2(var x,y : real)}

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;

begin
  with cmd do begin
    G$instr:= G$position;
    G$parameter_count:= 2;
    G$parameter_list[1]:= G$wsx(x);
    G$parameter_list[2]:= G$wsy(y)
  end;
  G$do(cmd);
  ida:= G$get_ptr;
  with ida^ do begin
    G$current_x_position:= x;
    G$current_y_position:= y
  end
end;



procedure G$MR;
  {Move_Rel_2(var dx,dy : real)}

var
  x,y	: real;

begin
  G$ICP(x,y);
  x:= x + dx;
  y:= y + dy;
  G$MA(x,y)
end;



procedure G$ICP;
  {Inquire_Current_Position_2(var x,y : real)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    x:= G$current_x_position;
    y:= G$current_y_position
  end
end;




END.
