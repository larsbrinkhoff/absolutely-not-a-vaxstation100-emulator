MODULE vsta$cgl_atts;
{
!
!  ATTS - CGL Global Attribute Functions
!
-----------------------------------------------------------------------------}

%include 'VSTA$LIBRARY:VSCGLDEF'

{ table of contents }
[global] procedure  G$SWI(var n : integer); forward;
[global] procedure  G$IWI(var n : integer); forward;
[global] procedure  G$SBI(var n : integer); forward;
[global] procedure  G$IBI(var n : integer); forward;
[global] procedure  G$SMP(var rgb : G$RGB_array); forward;
[global] procedure  G$IMP(var rgb : G$RGB_array); forward;
[global] procedure  G$SMPI(var n : integer; var rgb : G$RGB_values); forward;
[global] procedure  G$IMPI(var n : integer; var rgb : G$RGB_values); forward;
[global] procedure  G$SWP(var n : integer); forward;
[global] procedure  G$IWP(var n : integer); forward;
[global] procedure  G$SWM(var m : integer); forward;
[global] procedure  G$IWM(var m : integer); forward;
[global] procedure  G$SPA(var list1 : G$integer_attributes;
		var list2 : G$real_attributes); forward;
[global] procedure  G$IPA(var list1 : G$integer_attributes;
		var list2 : G$real_attributes); forward;


{ external routine references}
procedure G$error_handler(f,e : integer); external;
function G$get_ptr : G$impure_ptr; external;
procedure G$do(var command : G$instr_type); external;
procedure G$map(n : integer; var rgb : G$RGB_values); external;
procedure G$SLS(var n,p,m : integer); external;
procedure G$ILS(var n,p,m : integer); external;
procedure G$SLW(var dx,dy : real); external;
procedure G$ILW(var dx,dy : real); external;
procedure G$SFO(var n : integer); external;
procedure G$IFO(var n : integer); external;
procedure G$SCS(var width,height : real); external;
procedure G$ICS(var width,height : real); external;
procedure G$SCA(var d,m : integer); external;
procedure G$ICA(var d,m : integer); external;
procedure G$SCM(var dx,dy : real); external;
procedure G$ICM(var dx,dy : real); external;
procedure G$SCJ(var h,v : integer); external;
procedure G$ICJ(var h,v : integer); external;
procedure G$SCI(var angle : integer); external;
procedure G$ICI(var angle : integer); external;
procedure G$SMS(var n,c : integer); external;
procedure G$IMS(var n,c : integer); external;
procedure G$SFM(var m : integer); external;
procedure G$IFM(var m : integer); external;
procedure G$SFA(var x,y : real); external;
procedure G$IFA(var x,y : real); external;
procedure G$SFC(var n,c,wm,hm : integer); external;
procedure G$IFC(var n,c,wm,hm : integer); external;

const

{indices of the integer_attributes array..}

  I$WRITING_INDEX			=  1;
  I$BACKGROUND_INDEX			=  2;
  I$WRITING_MODE			=  3;
  I$LINE_STYLE_NUMBER			=  4;
  I$LINE_STYLE_PATTERN			=  5;
  I$LINE_STYLE_MULTIPLIER		=  6;
  I$FONT_NUMBER				=  7;
  I$CHAR_PATH				=  8;
  I$CHAR_ROTATION_MODE			=  9;
  I$CHAR_HORIZONTAL_JUSTIFICATION	= 10;
  I$CHAR_VERTICAL_JUSTIFICATION		= 11;
  I$CHAR_ITALIC				= 12;
  I$MARKER_NUMBER			= 13;
  I$MARKER_SYMBOL			= 14;
  I$FILL_MODE				= 15;
  I$FILL_FONT				= 16;
  I$FILL_CHAR				= 17;
  I$FILL_CHAR_WIDTH_MULTIPLIER		= 18;
  I$FILL_CHAR_HEIGHT_MULTIPLIER		= 19;

{indices of the real_attributes array..}

  R$LINE_WIDTH				=  1;
  R$LINE_HEIGHT				=  2;
  R$CHAR_WIDTH				=  3;
  R$CHAR_HEIGHT				=  4;
  R$CHAR_WIDTH_SPACING			=  5;
  R$CHAR_HEIGHT_SPACING			=  6;
  R$FILL_X				=  7;
  R$FILL_Y				=  8;


procedure G$SWI;
  {Set_Writing_Index(var n : integer)}

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;

begin
  if (n < G$MIN_COLOR_INDEX) or (n > G$MAX_COLOR_INDEX)
    then G$error_handler(FNG$SWI,401)
    else begin
      ida:= G$get_ptr;
      ida^.G$writing_index:= n;
      with cmd do begin
	G$instr:= G$set_writing_index;
	G$parameter_count:= 1;
	G$parameter_list[1]:= n
      end;
      G$do(cmd)
    end
end;




procedure G$IWI;
  {Inquire_Writing_Index(var n : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    n:= G$writing_index
  end
end;




procedure G$SBI;
  {Set_Background_Index(var n : integer)}

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;

begin
  if (n < G$MIN_COLOR_INDEX) or (n > G$MAX_COLOR_INDEX)
    then G$error_handler(FNG$SBI,401)
    else begin
      ida:= G$get_ptr;
      ida^.G$background_index:= n;
      with cmd do begin
	G$instr:= G$set_background_index;
	G$parameter_count:= 1;
	G$parameter_list[1]:= n
      end;
      G$do(cmd)
    end
end;




procedure G$IBI;
  {Inquire_Background_Index(var n : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  with ida^ do begin
    n:= G$background_index
  end
end;




procedure G$SMP;
  {Set_color_MaP(var rgb : G$RGB_array)}

var
  c	: G$RGB_values;
  i,j,k	: integer;
  bad	: boolean;

begin
  bad:= FALSE;
  for i:= 1 to G$COLOR_MAP_ARRAY_SIZE do
    if (rgb[i] < G$MIN_COLOR_VALUE) or (rgb[i] > G$MAX_COLOR_VALUE)
      then bad:= TRUE;
  if bad
    then G$error_handler(FNG$SMP,401)
    else begin
      for i:= 0 to 7 do begin
	k:= i * G$COLOR_MAP_ENTRY_SIZE;
	for j:= 1 to G$COLOR_MAP_ENTRY_SIZE do
	  c[j]:= rgb[j+k];
	j:= i;	
	G$SMPI(j,c) 
      end
    end
end;




procedure G$IMP;
  {Inquire_color_MaP(var rgb : G$RGB_array)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  rgb:= ida^.G$color_map_array
end;




procedure G$SMPI;
  {Set_color_MaP_Index(var n : integer;
		       var rgb : G$RGB_values)}

var
  i,j	: integer;
  ida	: G$impure_ptr;
  bad	: boolean;

begin
  bad:= FALSE;
  for i:= 1 to G$COLOR_MAP_ENTRY_SIZE do
    if (rgb[i] < G$MIN_COLOR_VALUE) or (rgb[i] > G$MAX_COLOR_VALUE)
      then bad:= TRUE;
  if bad or (n < G$MIN_COLOR_INDEX) or (n > G$MAX_COLOR_INDEX)
    then G$error_handler(FNG$SMPI,401)
    else begin
      j:= n * G$COLOR_MAP_ENTRY_SIZE;
      ida:= G$get_ptr;
      for i:= 1 to G$COLOR_MAP_ENTRY_SIZE do
	ida^.G$color_map_array[i+j]:= rgb[i];
      G$map(n,rgb)
    end
end;




procedure G$IMPI;
  {Inquire_color_MaP_Index(var n : integer;
			   var rgb : G$RGB_values)}
var
  i,j	: integer;
  ida	: G$impure_ptr;

begin
  j:= n * G$COLOR_MAP_ENTRY_SIZE;
  ida:= G$get_ptr;
  for i:= 1 to G$COLOR_MAP_ENTRY_SIZE do
    rgb[i]:= ida^.G$color_map_array[i+j];
end;




procedure G$SWP;
  {Set_Writing_Planes(var n : integer)}

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;

begin
  if (n < G$PLANE_SELECT_MIN_VALUE) or (n > G$PLANE_SELECT_MAX_VALUE)
    then G$error_handler(FNG$SWP,401)
    else begin
      ida:= G$get_ptr;
      with ida^ do begin
	G$writing_planes:= n;
	with cmd do begin
	  G$instr:= G$set_writing_planes;
	  G$parameter_count:= 1;
	  G$parameter_list[1]:= n
	end;
	G$do(cmd);
	G$SWI(G$writing_index);			{*** redefine indices ***}
	G$SBI(G$background_index)
      end
    end
end;




procedure G$IWP;
  {Inquire_Writing_Planes(var n : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  n:= ida^.G$writing_planes
end;




procedure G$SWM;
  {Set_Writing_Mode(var m : integer)}

var
  cmd	: G$instr_type;
  ida	: G$impure_ptr;

begin
  if (m < G$MIN_WRITING_MODE) or (m > G$MAX_WRITING_MODE)
    then G$error_handler(FNG$SWM,401)
    else begin
      ida:= G$get_ptr;
      ida^.G$writing_mode:= m;
      with cmd do begin
	G$instr:= G$set_writing_mode;
	G$parameter_count:= 1;
	G$parameter_list[1]:= m
      end;
      G$do(cmd)
    end
end;




procedure G$IWM;
  {Inquire_Writing_Mode(var m : integer)}

var
  ida	: G$impure_ptr;

begin
  ida:= G$get_ptr;
  m:= ida^.G$writing_mode
end;



procedure G$SPA;
  {Set_Primitive_Attributes_2(var list1 : G$integer_attributes;
			      var list2 : G$real_attributes)}

begin
  G$SWI(list1[I$WRITING_INDEX]);
  G$SBI(list1[I$BACKGROUND_INDEX]);
  G$SWM(list1[I$WRITING_MODE]);

  G$SLS(list1[I$LINE_STYLE_NUMBER],
	list1[I$LINE_STYLE_PATTERN],
	list1[I$LINE_STYLE_MULTIPLIER]);
  G$SLW(list2[R$LINE_WIDTH],
	list2[R$LINE_HEIGHT]);

  G$SFO(list1[I$FONT_NUMBER]);
  G$SCS(list2[R$CHAR_WIDTH],
	list2[R$CHAR_HEIGHT]);
  G$SCA(list1[I$CHAR_PATH],
	list1[I$CHAR_ROTATION_MODE]);
  G$SCM(list2[R$CHAR_WIDTH_SPACING],
	list2[R$CHAR_HEIGHT_SPACING]);
  G$SCJ(list1[I$CHAR_HORIZONTAL_JUSTIFICATION],
	list1[I$CHAR_VERTICAL_JUSTIFICATION]);
  G$SCI(list1[I$CHAR_ITALIC]);

  G$SMS(list1[I$MARKER_NUMBER],
	list1[I$MARKER_SYMBOL]);

  G$SFM(list1[I$FILL_MODE]);
  G$SFA(list2[R$FILL_X],
	list2[R$FILL_Y]);
  G$SFC(list1[I$FILL_FONT],
	list1[I$FILL_CHAR],
	list1[I$FILL_CHAR_WIDTH_MULTIPLIER],
	list1[I$FILL_CHAR_HEIGHT_MULTIPLIER])
end;



procedure G$IPA;
  {Inquire_Primitive_Attributes_2(var list1 : G$integer_attributes;
				  var list2 : G$real_attributes)}

begin
  G$IWI(list1[I$WRITING_INDEX]);
  G$IBI(list1[I$BACKGROUND_INDEX]);
  G$IWM(list1[I$WRITING_MODE]);

  G$ILS(list1[I$LINE_STYLE_NUMBER],
	list1[I$LINE_STYLE_PATTERN],
	list1[I$LINE_STYLE_MULTIPLIER]);
  G$ILW(list2[R$LINE_WIDTH],
	list2[R$LINE_HEIGHT]);

  G$IFO(list1[I$FONT_NUMBER]);
  G$ICS(list2[R$CHAR_WIDTH],
	list2[R$CHAR_HEIGHT]);
  G$ICA(list1[I$CHAR_PATH],
	list1[I$CHAR_ROTATION_MODE]);
  G$ICM(list2[R$CHAR_WIDTH_SPACING],
	list2[R$CHAR_HEIGHT_SPACING]);
  G$ICJ(list1[I$CHAR_HORIZONTAL_JUSTIFICATION],
	list1[I$CHAR_VERTICAL_JUSTIFICATION]);
  G$ICI(list1[I$CHAR_ITALIC]);

  G$IMS(list1[I$MARKER_NUMBER],
	list1[I$MARKER_SYMBOL]);

  G$IFM(list1[I$FILL_MODE]);
  G$IFA(list2[R$FILL_X],
	list2[R$FILL_Y]);
  G$IFC(list1[I$FILL_FONT],
	list1[I$FILL_CHAR],
	list1[I$FILL_CHAR_WIDTH_MULTIPLIER],
	list1[I$FILL_CHAR_HEIGHT_MULTIPLIER])
end;

END.
