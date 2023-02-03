MODULE vsta$cgl_putil;
{-----------------------------------------------------------------------------
!
!  PUTIL.PRG - CGL Pascal Utility Routines for Vaxstation Gidis
!
-----------------------------------------------------------------------------}

%include 'VSTA$LIBRARY:VSCGLDEF'

{table of contents}

[global] procedure G$string(var s : G$text_string; n : integer); forward;
[global] procedure G$font(n : integer); forward;
[global] procedure G$size(width,height : real); forward;
[global] procedure G$path(d,mode : integer); forward;
[global] procedure G$space(dx,dy : real); forward;
[global] procedure G$italic(angle : integer); forward;
[global] procedure G$load(c : integer; var m : G$char_matrix); forward;
[global] procedure G$type(n,dx,dy : integer); forward;
[global] procedure G$width(dx,dy : real); forward;
[global] procedure G$map(n : integer; var rgb : G$RGB_values); forward;
[global] procedure G$ask_cp(var x,y : real); forward;
[global] procedure G$error_handler(f,e : integer); forward;

{external references}

procedure G$read; external;
procedure G$write; external;
procedure G$flip(var start : [word] G$16_bits); external;
function G$wsx(x : real) : integer; external;
function G$swx(x : integer) : real; external;
function G$wsy(y : real) : integer; external;
function G$swy(y : integer) : real; external;
function G$get_ptr : G$impure_ptr; external;
procedure G$do(var command : G$instr_type); external;
procedure G$print(i : integer); external;
procedure G$crlf; external;

procedure G$string;
  {(var s : G$text_string; n : integer)}

var
  cmd	: G$instr_type;
  i	: integer;

begin
  with cmd do begin
    G$instr:= G$character;
    G$parameter_count:= 1;
    for i:= 1 to n do begin
      G$parameter_list[1]:= ord(s[i]);
      G$do(cmd)
    end
  end
end;



procedure G$font;
  {(n : integer)}
  {internal set font}

var
  cmd	: G$instr_type;

begin
  with cmd do begin
    G$instr:= G$set_alphabet;
    G$parameter_count:= 1;
    G$parameter_list[1]:= n
  end;
  G$do(cmd)
end;



  procedure set_size(d : integer);
    {set the cell size as the largest multiple of unit_size available
     for the screen_size (the screen equivalent of the required world size)
     at the supplied rotation direction, d}

  var
    cmd	: G$instr_type;
    ida	: G$impure_ptr;

  begin
    ida:= G$get_ptr;
    with ida^ do begin
      G$char_unit_width:= G$font_array[G$current_font_index + 1];
      G$char_unit_height:= G$font_array[G$current_font_index + 2];
      if (d = 2) or (d = 6)			{i.e. 90 or 270 degrees}
	then G$char_unit_width:= round(G$char_unit_width * 2.5)
	else G$char_unit_height:= round(G$char_unit_height * 2.5);




      G$char_physical_width:= (G$screen_char_width div G$char_unit_width)
				* G$char_unit_width;
      if G$char_physical_width = 0		{use minimum 1/2 size}
	then begin
	    if ( g$current_font_index = 0 ) 

	{ if the current font is the font zero then we need to compute the }
	{ correct font size....else we need to make the font size correct  }
	{ for the load font character command wihout clipping occurring    }


	     then G$char_physical_width  := ( G$char_unit_width  + 1) div 2

	     else G$char_physical_width  := G$char_unit_width ;

	     end;



      G$char_physical_height:= (G$screen_char_height div G$char_unit_height)
				* G$char_unit_height;


      if G$char_physical_height = 0		{use minimum 1/2 size}
	then begin
	    if ( g$current_font_index = 0 ) 

	{ if the current font is the font zero then we need to compute the }
	{ correct font size....else we need to make the font size correct  }
	{ for the load font character command wihout clipping occurring    }


	     then G$char_physical_height  := ( G$char_unit_height  + 1) div 2

	     else G$char_physical_height  := G$char_unit_height ;

	     end;

	  if odd (G$char_physical_height)
	    then G$char_physical_height:= G$char_physical_height + 1;

      with cmd do begin
	G$instr:= G$set_unit_size;
	G$parameter_count:= 2;
	G$parameter_list[1]:= G$char_physical_width;
        G$parameter_list[2]:= G$char_physical_height;
	G$do(cmd);
	G$instr:= G$set_display_size;
	G$parameter_list[1]:= G$parameter_list[1] * G$char_width_mirrored;
	G$parameter_list[2]:= G$parameter_list[2] * G$char_height_mirrored;
	G$do(cmd)
      end
    end
  end;



procedure G$size;
  {(width,height : real)}
  {internal set character size}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    G$screen_char_width:= abs(G$wsx(width) - G$wsx(0));
    G$screen_char_height:= abs(G$wsy(height) - G$wsy(0));
    set_size(G$char_path)
  end
end;



procedure G$path;
  {(d,mode : integer)}
  {set the character angle, size and spacing for the new charpath direction.
   The angles available are 0,51,90,129,180,231,270,309 corresponding to
   directions 0,1,2,3,4,5,6,7 respectively}

const
  TAN51	= 1.2345;

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;
  w,h	: integer;

begin
  with cmd do begin
    G$instr:= G$set_angle;
    G$parameter_count:= 1;
    G$parameter_list[1]:= d * 45
  end;
  G$do(cmd);				{set individual char angle}
  set_size(d);				{and size for this rotation}

  if mode <> 0
    then begin				{it's whole string rotation..}
      ida:= G$get_ptr;			{so set the spacing..}
      with ida^ do begin
	if G$char_width_spacing = 0
	  then w:= G$char_physical_width	{use size if zero spacing}
	  else w:= abs(G$wsx(G$char_width_spacing) - G$wsx(0));
	h:= w;					{initially height = width}
	if (d = 2) or (d = 6) or odd(d)		{all but 0 and 180..}
	  then h:= round(h * TAN51);		{..need more space}

	if (d = 2) or (d = 6)				{90,270}
	  then w:= 0
	  else if (d > 2) and (d < 6)			{129,180,231}
	    then w:= - w;

	if (d = 0) or (d = 4)				{0,180}
	  then h:= 0
	  else if d < 4					{51,90,129}
	    then h:= - h;

	G$space(G$swx(w) - G$swx(0), G$swy(h) - G$swy(0))
      end
  end
end;



procedure G$space;
  {(dx,dy : real)}
  {internal set character spacing}

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    G$screen_char_width_spacing:= G$wsx(dx) - G$wsx(0);
    G$screen_char_height_spacing:= G$wsy(dy) - G$wsy(0);
    with cmd do begin
      G$instr:= G$set_space;
      G$parameter_count:= 2;
      G$parameter_list[1]:= G$screen_char_width_spacing;
      G$parameter_list[2]:= G$screen_char_height_spacing
    end;
    G$do(cmd);
  end
end;



procedure G$italic;
  {(angle : integer)}
  {internal set character italic angle}

var
  cmd	: G$instr_type;

begin
  with cmd do begin
    G$instr:= G$set_italic;
    G$parameter_count:= 1;
    G$parameter_list[1]:= angle
  end;
  G$do(cmd)
end;



procedure G$load;
  {(c : integer; var m : G$char_matrix)}
  {internal load character}

var
  cmd	: G$instr_type;
  i	: integer;

begin
  with cmd do begin
    G$instr:= G$load_cell;
    G$parameter_count:= 17;
    G$parameter_list[1]:= c;
    for i:= 2 to 17 do
      G$parameter_list[i]:= m[i-1];
    G$flip(G$parameter_list[2])
  end;
  G$do(cmd)
end;



procedure G$type;
  {(n,dx,dy : integer)}
  {internal set font size}

var
  cmd	: G$instr_type;

begin
  with cmd do begin
    G$instr:= G$set_storage_size;
    G$parameter_count:= 3;
    G$parameter_list[1]:= dx;
    G$parameter_list[2]:= dy;
    G$parameter_list[3]:= n
  end;
  G$do(cmd)
end;



procedure G$width;
  {(dx,dy : real)}
  {internal set line width}

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    G$screen_line_width:= abs(G$wsx(dx) - G$wsx(0));
    G$screen_line_height:= abs(G$wsy(dy) - G$wsy(0));
    with cmd do begin
      G$instr:= G$set_linewidth;
      G$parameter_count:= 2;
      G$parameter_list[1]:= G$screen_line_width;
      G$parameter_list[2]:= G$screen_line_height
    end;
    G$do(cmd)
  end
end;



procedure G$map;
  {(n : integer; var rgb : G$RGB_values)}
  {internal set color map index}

var
  cmd	: G$instr_type;
  i	: integer;

begin
  with cmd do begin
    G$instr:= G$set_color_map;
    G$parameter_count:= 6;
    G$parameter_list[1]:= G$COLOR_MAP_NUMBER;
    G$parameter_list[2]:= n;
    for i:= 3 to 5 do
      G$parameter_list[i]:= rgb[i-2];
    G$parameter_list[6]:= (rgb[1] * 2 + rgb[2] * 4 + rgb[3]) div 7
						{mono = (R*2 + G*4 + B) / 7}
  end;
  G$do(cmd)
end;



procedure G$ask_cp;
  {(var x,y : real)}
  {internal report position}

var
  ida	: G$impure_ptr;
  cmd	: G$instr_type;

begin
  with cmd do begin
    G$instr:= G$report_position;
    G$parameter_count:= 0
  end;
  G$do(cmd);    			{buffer the request}
  G$write;				{and send it!}
  ida:= G$get_ptr;
  with ida^ do begin
    G$buffer_count:= 2;			{we want 2 words read}
    G$read;				{go get them}
    if G$debug
      then begin
	G$print(G$buffer[1]);
	G$print(G$buffer[2]);
	G$crlf
      end;
    G$buffer_count := 0;		{clear the I/O buffer counter}
    x:= G$swx(G$buffer[1]);		{and convert to worlds}
    y:= G$swy(G$buffer[2])
  end
end;



procedure G$error_handler;
  {(f,e : integer)}
  {error numbers are from Appendix B2, ANSI X3H3 working document, 20-Nov-80}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    G$function_number:= f;
    G$error_number:= e;
  end
end;



END.
