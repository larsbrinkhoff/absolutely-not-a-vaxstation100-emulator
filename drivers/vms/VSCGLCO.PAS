MODULE vsta$cgl_control;
{----------------------------------------------------------------------------
!
!  CONTROL - CGL Control Functions
!
-----------------------------------------------------------------------------}

%include 'VSTA$LIBRARY:VSCGLDEF'

{table of contents}

[global] procedure G$INIT; forward;
[global] procedure G$EXIT; forward;
[global] procedure G$NF; forward;
[global] procedure G$RMRE(var f,e : integer); forward;
[global] procedure G$PRNT(var xmin,xmax,ymin,ymax,xoff,yoff : real); forward;
[global] procedure G$WAIT(var seconds : real); forward;

{external routine references}

function G$get_ptr : G$impure_ptr; external;
function G$wsx(x : real) : integer; external;
function G$wsy(y : real) : integer; external;
procedure G$do(var command : G$instr_type); external;
procedure G$error_handler(f,e : integer); external;
procedure G$font(n : integer); external;
procedure G$type(n,dx,dy : integer); external;
procedure G$SO(var c : integer); external;
procedure G$SC(var s : integer); external;
procedure G$SMP(var rgb : G$RGB_array); external;
procedure G$SWP(var n : integer); external;
procedure G$SPA(var list1 : G$integer_attributes;
		var list2 : G$real_attributes); external;
procedure G$SGV(var v : integer); external;
procedure G$SGA(var list1 : G$integer_attributes;
		var list2 : G$real_attributes); external;
procedure G$bounds(clip : boolean); external;
procedure G$CLS; external;

const

  G$default_integer_attributes = G$integer_attributes(
	{writing_index}				4,
	{background_index}			0,
	{writing_mode}				G$OVERLAY,
	{line_style_number}			1,
	{line_style_pattern}			0,
	{line_style_multiplier}			0,
	{font_number}				0,
	{char_path}				0,
	{char_rotation_mode}			0,
	{char_horizontal_justification}		1,
	{char_vertical_justification}		1,
	{char_italic}				0,
	{marker_number}				1,
	{marker_symbol}				0,
	{fill_mode}				G$OFF,
	{fill_font}				0,
	{fill_char}				0,
	{fill_char_width_multiplier}		1,
	{fill_char_height_multiplier}		1			);


  G$default_real_attributes = G$real_attributes(
	{line_width}				0.0,
	{line_height}				0.0,
	{char_width}				12.0,
	{char_height}				25.0,
	{char_width_spacing}			12.0,
	{char_height_spacing}			0.0,
	{fill_x}				0.0,
	{fill_y}				0.0			);


  G$default_color_map_values = G$RGB_array(	0,0,0,		{black}
						0,0,7,		{blue}
						7,0,0,		{red}
						0,7,0,		{green}
						7,7,7,		{white}
						7,7,7,		{white}
						7,7,7,		{white}
						7,7,7		{white}	);

procedure call(procedure n(var i : integer); i : integer);
  {call a CGL function with one integer}

begin
  n(i)
end;



procedure G$INIT;
  {INITialize_core()}

var
  cmd	: G$instr_type;
  list1	: G$integer_attributes;
  list2	: G$real_attributes;
  list3	: G$RGB_array;
  i	: integer;
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    if G$initialized
      then G$error_handler(FNG$INIT,701)
      else begin
	G$screen[G$LEFT]  := G$SCREEN_LEFT;	{physical screen}
	G$screen[G$RIGHT] := G$SCREEN_RIGHT;
	G$screen[G$BOTTOM]:= G$SCREEN_BOTTOM;
	G$screen[G$TOP]   := G$SCREEN_TOP;
	for i:= 0 to 3 do
	  G$window[i]:= G$screen[i];		{window as screen}
	G$viewport[G$LEFT]  := 0;		{viewport is whole screen}
	G$viewport[G$RIGHT] := 1;
	G$viewport[G$BOTTOM]:= 0;
	G$viewport[G$TOP]   := 1;

	G$seg_open:= FALSE;			{no segments open..}
	G$seg_file_open:= FALSE;		{..we don't even have a file}
	G$extending_seg:= FALSE;		{and certainly not extending}

	G$error_handler(FNG$NULL,0);		{no errors yet}
	G$initialized:= TRUE;			{all now set up..}

	G$buffer_count:= 0;		{ensure buffer count starts at 0 (lsc)}

	with cmd do begin
	  G$instr:= G$initialize;
	  G$parameter_count:= 0
	end;
	G$do(cmd);				{reset}
	with cmd do begin
	  G$instr:= G$set_screen_address;
	  G$parameter_count:= 2;
	  G$parameter_list[1]:= G$SCREEN_RIGHT;
	  G$parameter_list[2]:= G$SCREEN_TOP
	end;
	G$do(cmd);

	G$current_font_index:= 0;		{define font 0}
	G$font_array[0]:= G$FONT_0_EXTENT;
	G$font_array[1]:= G$FONT_0_PIXEL_WIDTH;
	G$font_array[2]:= G$FONT_0_PIXEL_HEIGHT;
	for i:= 1 to G$MAX_FONT do begin	{zeroise definable fonts}
	  G$font(i);
	  G$type(0,0,0)
	  end;
	G$font_memory_left:= G$TOTAL_FONT_MEMORY;	{then reset space}

	call(G$SO,G$TOP_LEFT);			{NOTE: this will init view..}
        call(G$SC,G$ON);			{..and this will init region}
	call(G$SWP,G$PLANE_SELECT_MAX_VALUE);	{select all planes}

	list1:= G$default_integer_attributes;	{set the primitive atts..}
	list2:= G$default_real_attributes;
	G$SPA(list1,list2);
	G$set_for_markers:= TRUE;		{markers will appear o.k.}
	G$text_attributes:= [];			{because all these are reset}
	list3:= G$default_color_map_values;	{set color defaults..}
	G$SMP(list3);
	call(G$SGV,G$VISIBLE);			{segments can be seen}
        G$SGA(list1,list2)			{segment attribute defaults}
      end
  end
end;



procedure G$EXIT;
  {terminate_core()}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    if G$seg_open then G$CLS;
    G$initialized:= FALSE
  end
end;



procedure G$NF;
  {New_Frame()}

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  G$bounds(FALSE);			{ensure region is whole screen..}
  with cmd do begin
    G$instr:= G$screen_erase;
    G$parameter_count:= 0
  end;
  G$do(cmd);				{clear the screen..}
  G$bounds(ida^.G$clipping <> 0)	{and restore clipping region}
end;



procedure G$RMRE;
  {Report_Most_Recent_Error(var f,e : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    f:= G$function_number;		{send back what we have}
    e:= G$error_number;
    G$error_handler(FNG$NULL,0)		{and flush that one}
  end
end;



procedure G$PRNT;
  {PRiNT(var xmin,xmax,ymin,ymax,xoff,yoff : real)}

var
  cmd	: G$instr_type;

begin
  with cmd do begin
    G$instr:= G$hardcopy;
    G$parameter_count:= 6;
    G$parameter_list[1]:= G$wsx(xmin);
    G$parameter_list[2]:= G$wsy(ymin);
    G$parameter_list[3]:= G$wsx(xmax);
    G$parameter_list[4]:= G$wsy(ymax);
    G$parameter_list[5]:= abs(G$wsx(xoff) - G$wsx(0));
    G$parameter_list[6]:= abs(G$wsy(yoff) - G$wsy(0))
  end;
  G$do(cmd)
end;



procedure G$WAIT;
  {WAIT(var seconds : real)}

var
  cmd	: G$instr_type;

begin
  with cmd do begin
    G$instr:= G$delay;
    G$parameter_count:= 1;
    G$parameter_list[1]:= round(seconds * G$TICKS_PER_SECOND)
  end;
  G$do(cmd)
end;


END.
