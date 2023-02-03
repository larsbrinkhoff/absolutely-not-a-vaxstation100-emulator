MODULE vsta$cgl_trans;
{-----------------------------------------------------------------------------
!
!  Author:	Bill Clements	CT Software	ML5-2/T77	3-Dec-82
!
-----------------------------------------------------------------------------}

%include 'VSTA$LIBRARY:VSCGLDEF'

{table of contents}

[global] function G$wsx(x : real) : integer; forward;
[global] function G$swx(x : integer) : real; forward;
[global] function G$wsy(y : real) : integer; forward;
[global] function G$swy(y : integer) : real; forward;
[global] procedure G$view(new_window : boolean); forward;

{external references}

procedure G$MA(var x,y : real); external;
function G$get_ptr : G$impure_ptr; external;

function world_to_screen(w : real; i : integer) : integer;
  {convert world real to screen integer value}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do
    world_to_screen:= round((w - G$transformation_constant[i+4])
			       * G$transformation_constant[i]
			       + G$transformation_constant[i+2])
end;



function screen_to_world(s : integer; i : integer) : real;
  {convert screen integer to world real value}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do
    screen_to_world:= (s + G$transformation_constant[i+4]
			 * G$transformation_constant[i]
			 - G$transformation_constant[i+2])
			 / G$transformation_constant[i]
end;



function G$wsx;
  {(x : real) : integer}

begin
  G$wsx:= world_to_screen(x,0)
end;



function G$swx;
  {(x : integer) : real}

begin
  G$swx:= screen_to_world(x,0)
end;



function G$wsy;
  {(y : real) : integer}

begin
  G$wsy:= world_to_screen(y,1)
end;



function G$swy;
  {(y : integer) : real}

begin
  G$swy:= screen_to_world(y,1)
end;

procedure G$view;
  {(new_window : boolean)}
  {Calculate the constant values for use in coordinate transformation.
   Update world charsize, charspace and linewidth if new_window is TRUE.

   NOTE: before this routine is called the window/viewport/origin arrays
   are expected to be set for the new transformation!}

var
  screen,
  window,
  viewport,
  offset,
  world_x0,
  world_y0	: real;
  i		: integer;
  ida		: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    for i:= 0 to 1 do begin			{find new constants, x then y}
      screen:= G$screen[i+2] - G$screen[i];	{** beware compiler bugs!! **}
      window:= G$window[i+2] - G$window[i];
      viewport:= G$viewport[i+2] - G$viewport[i];
      G$transformation_constant[i]:= screen * viewport / window;
      G$transformation_constant[i+4]:= G$window[i];
      offset:= G$viewport[i];
      if G$corner[i]				{the world is upside down}
	then begin
	  G$transformation_constant[i]:= - G$transformation_constant[i];
	  G$transformation_constant[i+4]:= G$window[i+2];
	  offset:= 1 - G$viewport[i+2]
	end;
      G$transformation_constant[i+2]:= screen * offset - G$screen[i]
    end;

    G$MA(G$window[G$LEFT],G$window[G$BOTTOM]);	{to XMIN,YMIN of the new view}

    if new_window
      then begin				{it's a new window or origin}
	world_x0:= G$swx(0);			{..update these world values}
	world_y0:= G$swy(0);

	G$char_width:= abs(G$swx(G$screen_char_width) - world_x0);
	G$char_height:= abs(G$swy(G$screen_char_height) - world_y0);

	G$char_width_spacing:=
	  G$swx(G$screen_char_width_spacing) - world_x0;
	G$char_height_spacing:=
	  G$swy(G$screen_char_height_spacing) - world_y0;

	G$line_width:= G$swx(G$screen_line_width) - world_x0;
	G$line_height:= G$swy(G$screen_line_height) - world_y0;

	G$set_for_markers:= FALSE;		{marker size may now be wrong}
	G$text_attributes:= G$text_attributes + [G$dimension]
      end;
  end
end;




END.
