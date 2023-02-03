MODULE vsta$cgl_clip;
{-----------------------------------------------------------------------------
!
!
!  CLIP.PRG - CGL clipping functions
!
-----------------------------------------------------------------------------}

%include 'VSTA$LIBRARY:VSCGLDEF'

{----------------------------------------------------------------------------
function G$clip(x1,y1,x2,y2 : real) : boolean; external;
-----------------------------------------------------------------------------}
{table of contents}
[global] procedure G$bounds(clip : boolean); forward;

{external routine references}
function G$get_ptr : G$impure_ptr; external;
function G$wsx(x : real) : integer; external;
function G$wsy(y : real) : integer; external;
procedure G$do(var command : G$instr_type); external;




{-----------------------------------------------------------------------------
function G$clip;
  (x1,y1,x2,y2 : real) : boolean
   Return 'true' if any portion of the line (x1,y1) (x2,y2) is in the current
   window.
   The algorithm is found in Newman & Sproull 'Principles of Interactive
   Computer Graphics' 2nd Edition, page 66.

type
  edge		= (left,right,bottom,top);
  outcode	= set of edge;

var
  c1,c2		: outcode;
  visible	: boolean;  


  procedure code(x,y : real; var c : outcode);
    compose the set of edges for the point x,y that are outside the window

  var
    ida	: G$impure_ptr;

  begin
    ida:= G$get_ptr;
    with ida^ do begin
      c:= [];
      if x < G$window[G$LEFT]
	then c:= [left]
	else if x > G$window[G$RIGHT] then c:= [right];
      if y < G$window[G$BOTTOM]
	then c:= c + [bottom]
	else if y > G$window[G$TOP] then c:= c + [top]
    end
  end;


begin
  code(x1,y1,c1);
  code(x2,y2,c2);
  G$clip:= (c1*c2) = []
			c1 AND c2 not null - line is entirely off-screen!!
      else begin
	if c1 = []
	  then c:= c2 else c:= c1;
        if left in c
	  then begin				crosses left edge
	    y:= y1 + (y2 - y1) * (window[left] - x1) / (x2 - x1);
	    x:= window[left]
	  end
	  else if right in c
	    then begin				crosses right edge
	      y:= y1 + (y2 - y1) * (window[right] - x1) / (x2 - x1);
	      x:= window[right]
	    end
	  else if bottom in c
	    then begin				crosses bottom edge
	      x:= x1 + (x2 - x1) * (window[bottom] - y1) / (y2 - y1);
	      y:= window[bottom]
	    end
	  else if top in c
	    then begin				crosses top edge
	      x:= x1 + (x2 - x1) * (window[top] - y1) / (y2 - y1);
	      y:= window[top]
	    end;
	if c = c1
	  then begin
	    start_clipped:= true;		start was clipped
	    x1:= x;  y1:= y;  code(x1,y1,c1)
	  end
	  else begin
	    x2:= x;  y2:= y;  code(x2,y2,c2)
	  end
    end
end;
-----------------------------------------------------------------------------}

procedure G$bounds;
  {(clip : boolean)}
  {internal set clipping boundaries:-
   to viewport if 'clip' is TRUE; to full screen if 'clip' is FALSE}

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;
  i,j	: integer;

begin
  ida:= G$get_ptr;
  with ida^ do with cmd do begin
    G$instr:= G$set_clipping_region;
    G$parameter_count:= 4;
    if clip and
	(((G$viewport[G$RIGHT] - G$viewport[G$LEFT]) < 1) or
	 ((G$viewport[G$TOP] - G$viewport[G$BOTTOM]) < 1))
      then begin				{region inside screen edges}
	i:= G$wsx(G$window[G$LEFT]);
	j:= G$wsx(G$window[G$RIGHT]);
	if i > j
	  then begin
	    G$parameter_list[3]:= i;
	    G$parameter_list[1]:= j
	  end
	  else begin
	    G$parameter_list[1]:= i;
	    G$parameter_list[3]:= j
	  end;
	i:= G$wsy(G$window[G$BOTTOM]);
	j:= G$wsy(G$window[G$TOP]);
	if i > j
	  then begin
	    G$parameter_list[4]:= i;
	    G$parameter_list[2]:= j
	  end
	  else begin
	    G$parameter_list[2]:= i;
	    G$parameter_list[4]:= j
	  end
      end
      else for i:= 1 to 4 do			{region to whole screen}
	G$parameter_list[i]:= G$screen[i-1]
  end;
  G$do(cmd)
end;


END.
