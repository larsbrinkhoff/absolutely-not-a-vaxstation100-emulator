MODULE vsta$cgl_markers;
{-----------------------------------------------------------------------------
!
!  MARKERS - CGL Marker Functions
!
-----------------------------------------------------------------------------}

%include 'VSTA$LIBRARY:VSCGLDEF'

{table of contents}

[global] procedure G$MRA(var x,y : real); forward;
[global] procedure G$MRR(var dx,dy : real); forward;
[global] procedure G$PMRA(var x,y : G$reals; var n : integer); forward;
[global] procedure G$PMRR(var dx,dy : G$reals; var n : integer); forward;
[global] procedure G$SMS(var n,c : integer); forward;
[global] procedure G$IMS(var n,c : integer); forward;

{external references}

function G$get_ptr : G$impure_ptr; external;
function G$swx(x : integer) : real; external;
function G$swy(y : integer) : real; external;
procedure G$font(n : integer); external;
procedure G$size(width,height : real); external;
procedure G$path(d,mode : integer); external;
procedure G$italic(angle : integer); external;
procedure G$do(var command : G$instr_type); external;
procedure G$MA(var x,y : real); external;
procedure G$ICP(var x,y : real); external;
procedure G$IFO(var n : integer); external;
procedure G$error_handler(f,e : integer); external;


procedure G$MRA;
  {MarkeR_Abs_2(var x,y : real)}

var
  cmd	: G$instr_type;
  p,q	: real;
  font,
  fontnum,
  i,j	: integer;
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    if not G$set_for_markers and (G$text_attributes <> [])
      then begin				{text attribute(s) to set..}
	font:= G$current_font_index;		{save for restore}
	if G$alphabet in G$text_attributes
	  then begin
	    G$font(0);				{want a standard marker}
	    G$current_font_index:= 0		{for correct size}
	  end;
	if G$dimension in G$text_attributes
	  then begin
	    i:= G$font_array[G$current_font_index + 1];
	    if (G$viewport[G$RIGHT] - G$viewport[G$LEFT]) < 1
	      then i:= (i + 1) div 2;		{** can only have 1/2 size **}
	    j:= round(G$font_array[G$current_font_index + 2] * 2.5);
	    if (G$viewport[G$TOP] - G$viewport[G$BOTTOM]) < 1
	      then j:= (j + 1) div 2;
	    G$char_marker_width:= abs(G$swx(i) - G$swx(0));
	    G$char_marker_height:= abs(G$swy(j)	- G$swy(0));
	    G$size(G$char_marker_width,G$char_marker_height)
	  end;
	if G$direction in G$text_attributes
	  then G$path(0,0);
	if G$slant in G$text_attributes
	  then G$italic(0);
	G$current_font_index:= font;		{restore current font}
	G$set_for_markers:= TRUE		{and flag what we've done}
      end;
{calculate relative move}
    G$IFO(fontnum);
    if ( fontnum = 0 ) or ( g$alphabet in g$text_attributes )
      then begin				{offset is dependent on font}
	p:= G$char_marker_width / 3;		{smaller x offset for font 0}
	if G$marker_number = 1			{"." marker requires..}
	     then q:= G$char_marker_height / 2	{..bigger y offset}
	     else q:= G$char_marker_height / 3
	end
      else begin
	q:= G$char_marker_height * 0.4;
	p:= G$char_marker_width / 2
	end;
{then make it absolute}
    if G$corner[0]
      then p:= x + p
      else p:= x - p;
    if G$corner[1]
      then q:= y + q
      else q:= y - q;
    G$MA(p,q);					{move for centered marker}
    with cmd do begin
      G$instr:= G$character;
      G$parameter_count:= 1;
      G$parameter_list[1]:= G$marker_symbol;
    end;
    G$do(cmd);					{then draw it}
    G$MA(x,y)					{and move to centre}
  end
end;



procedure G$MRR;
  {MarkeR_Rel_2(var dx,dy : real)}

var
  x,y	: real;

begin
  G$ICP(x,y);
  x:= x + dx;
  y:= y + dy;
  G$MRA(x,y)
end;



procedure G$PMRA;
  {PolyMarkeR_Abs_2(var x,y : G$reals;
		    var n : integer)}

var
  i	: integer;

begin
  if n < 0
    then G$error_handler(FNG$PMRA,2)
    else for i:= 1 to n do
      G$MRA(x[i],y[i])
end;



procedure G$PMRR;
  {PolyMarkeR_Rel_2(var dx,dy : G$reals;
		    var n : integer)}

var
  i	: integer;

begin
  if n < 0
    then G$error_handler(FNG$PMRR,2)
    else for i:= 1 to n do
      G$MRR(dx[i],dy[i])
end;



procedure G$SMS;
  {Set_Marker_Symbol(var n,c : integer)}

var
  ida	: G$impure_ptr;
  G$marker_symbol_array : G$marker_symbols;

begin
  ida:= G$get_ptr;
  G$marker_symbol_array[1] :=	46;		{'.'}
  G$marker_symbol_array[2] :=	43;		{'+'}
  G$marker_symbol_array[3] :=	42;		{'*'}
  G$marker_symbol_array[4] :=	79;		{'O'}
  G$marker_symbol_array[5] :=	88;		{'X'}
  with ida^ do begin
    G$marker_number:= n;
    if (n < 1) or (n > G$FIXED_MARKER_SYMBOLS)
      then begin
	G$marker_symbol:= c;			{use character code supplied}
	G$text_attributes:= G$text_attributes - [G$alphabet];	{current font}
	G$set_for_markers:= FALSE			{flag it}
      end
      else begin
	G$marker_symbol:= G$marker_symbol_array[n];	{use standard symbol}
	if G$current_font_index <> 0
	  then begin					{so we want font 0}
	    G$set_for_markers:= FALSE;			{flag it}
	    G$text_attributes:= G$text_attributes
					+ [G$alphabet]	{to select font 0}
					+ [G$dimension]	{and correct size}
	  end
      end
  end
end;



procedure G$IMS;
  {Inquire_Marker_Symbol(var n,c : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    n:= G$marker_number;
    c:= G$marker_symbol
  end
end;



END.
