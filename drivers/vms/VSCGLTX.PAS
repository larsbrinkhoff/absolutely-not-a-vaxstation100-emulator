MODULE vsta$cgl_text;
{-----------------------------------------------------------------------------
!
!  TEXT - CGL Text Functions
!
-----------------------------------------------------------------------------}

%include 'VSTA$LIBRARY:VSCGLDEF'

{table of contents}

[global] procedure G$T(var s : G$text_string; var n : integer); forward;
[global] procedure G$ITE(var n : integer; var dx,dy : real); forward;
[global] procedure G$SFO(var n : integer); forward;
[global] procedure G$IFO(var n : integer); forward;
[global] procedure G$SCS(var width,height : real); forward;
[global] procedure G$ICS(var width,height : real); forward;
[global] procedure G$SCA(var d,m : integer); forward;
[global] procedure G$ICA(var d,m : integer); forward;
[global] procedure G$SCM(var dx,dy : real); forward;
[global] procedure G$ICM(var dx,dy : real); forward;
[global] procedure G$SCJ(var h,v : integer); forward;
[global] procedure G$ICJ(var h,v : integer); forward;
[global] procedure G$SCI(var angle : integer); forward;
[global] procedure G$ICI(var angle : integer); forward;
[global] procedure G$SFS(var n,dx,dy : integer); forward;
[global] procedure G$IFS(var n,dx,dy : integer); forward;
[global] procedure G$LDC(var c : integer; var m : G$char_matrix); forward;

{external references}

function G$get_ptr : G$impure_ptr; external;
procedure G$string(var s : G$text_string; n : integer); external;
procedure G$font(n : integer); external;
procedure G$size(width,height : real); external;
procedure G$path(d,mode : integer); external;
procedure G$space(dx,dy : real); external;
procedure G$italic(angle : integer); external;
procedure G$load(c : integer; var m : G$char_matrix); external;
procedure G$type(n,dx,dy : integer); external;
procedure G$error_handler(f,e : integer); external;
function G$wsx(x : real) : integer; external;
function G$swx(x : integer) : real; external;
function G$wsy(y : real) : integer; external;
function G$swy(y : integer) : real; external;
procedure G$do(var command : G$instr_type); external;
procedure G$MA(var x,y : real); external;
procedure G$MR(var dx,dy : real); external;
procedure G$ICP(var x,y : real); external;

{
 NOTE: CGL does not attempt to clip text - it takes too much code
       to accurately calculate string extents.
}


procedure G$T;
  {Text(var s : G$text_string;
	var n : integer)}

var
  x,y,
  dx,dy	: real;
  sx,sy	: integer;
  ida	: G$impure_ptr;

begin
  if n < 0
    then G$error_handler(FNG$T,2)
    else begin
      ida:= G$get_ptr;
      with ida^ do begin
	if G$set_for_markers and (G$text_attributes <> [])
	  then begin				{set attributes for text}
	    if G$alphabet in G$text_attributes
	      then G$font(G$current_font_index div G$FONT_ENTRY_SIZE);
	    if G$dimension in G$text_attributes
	      then G$size(G$char_width,G$char_height);
	    if G$direction in G$text_attributes
	      then G$path(G$char_path,G$char_rotation_mode);
	    if G$slant in G$text_attributes
	      then G$italic(G$char_italic);
	    G$set_for_markers:= FALSE
	  end;
	G$ICP(x,y);				{for cp restore}
	if G$text_justified
	  then begin				{must move to justify text}
	    if G$char_horizontal_justification < 2
	      then sx:= 0			{left is normal}
	      else begin
		sx:= n * abs(G$wsx(G$char_width_spacing) - G$wsx(0));
		if G$char_horizontal_justification = 2
		  then sx:= sx div 2		{to centre}
	      end;

	    if G$char_vertical_justification < 2
	      then sy:= 0			{top is normal}
	      else begin
		sy:= G$char_physical_height;
		if G$char_vertical_justification = 2
		  then sy:= sy div 2		{to centre}
	      end;

	    dx:= G$swx(0) - G$swx(sx);		{transform to world}
	    dy:= G$swy(0) - G$swy(sy);
	    G$MR(dx,dy)				{and move relative}
	  end;
	G$string(s,n);				{draw the characters}
	G$MA(x,y)				{text does NOT update cp!}
      end
    end
end;



procedure G$ITE;
  {Inquire_Text_Extent_2(var n : integer;
			 var dx,dy : real)}

var
  ida	: G$impure_ptr;

begin
  if n < 0
    then G$error_handler(FNG$ITE,2)
    else begin
      ida:= G$get_ptr;
      with ida^ do begin
	dx:= G$swx(n * G$screen_char_width_spacing) - G$swx(0);
	dy:= G$swy(n * G$screen_char_height_spacing) - G$swy(0)
      end
    end
end;



  procedure set_size;
    {set character size for current font}

  var
    ida	: G$impure_ptr;

  begin
    ida:= G$get_ptr;
    with ida^ do begin
      G$SCS(G$char_width,G$char_height);
      G$SCA(G$char_path,G$char_rotation_mode)	{because path affects size}
    end
  end;



procedure G$SFO;
  {Set_FOnt(var n : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    if (n < 0) or (n > G$MAX_FONT)
      then G$error_handler(FNG$SFO,401)
      else begin
	G$current_font_index:= n * G$FONT_ENTRY_SIZE;
	G$font(n);				{internal set font}
	if n = 0 then begin			{standard markers will be ok}
	  set_size;				{establish char size}
	  G$text_attributes:= G$text_attributes - [G$alphabet];
	  end
      end
  end
end;



procedure G$IFO;
  {Inquire_FOnt(var n : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  n:= ida^.G$current_font_index div G$FONT_ENTRY_SIZE
end;



procedure G$SCS;
  {Set_CharSize(var width,height : real)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    if width < 0
      then G$char_width_mirrored:= -1
      else G$char_width_mirrored:= 1;
    if height < 0
      then G$char_height_mirrored:= -1
      else G$char_height_mirrored:= 1;
    G$char_width:= abs(width);
    G$char_height:= abs(height);
    G$size(G$char_width,G$char_height);		{internal set size}
    G$set_for_markers:= FALSE;			{marker size may be wrong}
    G$text_attributes:= G$text_attributes + [G$dimension]
  end
end;



procedure G$ICS;
  {Inquire_CharSize(var width,height : real)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    width:= G$char_width * G$char_width_mirrored;
    height:= G$char_height * G$char_height_mirrored
  end
end;



procedure G$SCA;
  {Set_CharAngle(var d,m : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    if (d < 0) or (d > 7)
      then G$error_handler(FNG$SCA,401)
      else begin
	G$char_path:= d;
	G$char_rotation_mode:= m;
	G$path(d,m);			{internal set char path}
	if d = 0
	  then G$text_attributes:= G$text_attributes - [G$direction]
	  else begin
	    G$set_for_markers:= FALSE;
	    G$text_attributes:= G$text_attributes + [G$direction]
	  end
      end
  end
end;



procedure G$ICA;
  {Inquire_CharAngle(var d,m : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    d:= G$char_path;
    m:= G$char_rotation_mode
  end
end;



procedure G$SCM;
  {Set_CharMove(var dx,dy : real)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    G$char_width_spacing:= dx;
    G$char_height_spacing:= dy;
    G$space(dx,dy)			{internal set char spacing}
  end
end;



procedure G$ICM;
  {Inquire_CharMove(var dx,dy : real)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    dx:= G$char_width_spacing;
    dy:= G$char_height_spacing
  end
end;



procedure G$SCJ;
  {Set_CharJust(var h,v : integer)}

var
  ida	: G$impure_ptr;

begin
  if (h < 0) or (h > 3) or
     (v < 0) or (v > 3)
    then G$error_handler(FNG$SCJ,401)
    else begin
      ida:= G$get_ptr;
      with ida^ do begin
	G$char_horizontal_justification:= h;
	G$char_vertical_justification:= v;
	G$text_justified:= (h = 2) or (h = 3) or (v = 2) or (v = 3)
      end
    end
end;



procedure G$ICJ;
  {Inquire_CharJust(var h,v : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    h:= G$char_horizontal_justification;
    v:= G$char_vertical_justification
  end
end;



procedure G$SCI;
  {Set_CharItalic(var angle : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    G$char_italic:= angle;
    G$italic(angle);			{internal set italic}
    if angle = 0
      then G$text_attributes:= G$text_attributes - [G$slant]
      else begin
	G$set_for_markers:= FALSE;
	G$text_attributes:= G$text_attributes + [G$slant]
      end
  end
end;



procedure G$ICI;
  {Inquire_CharItalic(var angle : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  angle:= ida^.G$char_italic
end;



procedure G$SFS;
  {Set_Font_Size(var n,dx,dy : integer)}

var
  ida	: G$impure_ptr;
  old,
  new	: integer;


  function size(s,w,h : integer) : integer;
    {calculate font memory occupied and return it as function value}
    {s = extent, w = dx width, h = dy height}

  begin
    s:= s - 31;				{C0 chars use no space}
    if s > 128				{into 8 bit country}
      then s:= s - 33;			{C1 and <DEL> use none as well}
    if w > 8				{width bigger than 1/2 word}
      then s:= s * 2;			{so it's two bytes per char}
    size:= s * h			{by the number of scan lines}
  end;


begin
  ida:= G$get_ptr;
  with ida^ do begin
    if (G$current_font_index = 0) or 			{can't alter font 0..}
       (n < 0) or					{give silly extent..}
       ((n > 0) and
	((dx < 1) or (dx > G$MAX_CHAR_PIXEL_SIZE) or
	 (dy < 1) or (dy > G$MAX_CHAR_PIXEL_SIZE)))	{or go outside range}
      then G$error_handler(FNG$SFS,401)
      else begin
	old:= size(G$font_array[G$current_font_index],	{space currently used}
		   G$font_array[G$current_font_index+1],
		   G$font_array[G$current_font_index+2]);
	new:= size(n,dx,dy);				{new space required}
	if (G$font_memory_left + old - new) < 0
	  then G$error_handler(FNG$SFS,902)		{no room for font!}
	  else begin					{it will fit..}
	    G$font_memory_left:= G$font_memory_left + old - new;
	    G$font_array[G$current_font_index]:= n;
	    G$font_array[G$current_font_index+1]:= dx;
	    G$font_array[G$current_font_index+2]:= dy;
	    G$type(n,dx,dy);			{internal set font size}
	    set_size				{establish char size}
	  end
      end
  end
end;



procedure G$IFS;
  {Inquire_Font_Size(var n,dx,dy : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    n:= G$font_array[G$current_font_index];
    dx:= G$font_array[G$current_font_index+1];
    dy:= G$font_array[G$current_font_index+2]
  end
end;



procedure G$LDC;
  {LoaD_Char(var c : integer;
	     var m : G$char_matrix)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    if (G$current_font_index = 0) or			{can't alter font 0,}
       (c > G$font_array[G$current_font_index])	or	{go past max index,}
       (c < 32) or ((c > 126) and (c < 160))		{or define these}
      then G$error_handler(FNG$LDC,401)
      else G$load(c,m)				{internal load char}
  end
end;



END.
