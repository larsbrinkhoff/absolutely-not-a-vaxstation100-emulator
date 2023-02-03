{-----------------------------------------------------------------------------
!
! Include file for vax pascal.
!----------------------------------------------------------------------------}

{constant and type declaration for CGL calls}

const
  OFF			= 0;			{generic "off" switch}
  ON			= 1;			{generic "on" switch}

  OPEN			= 0;			{curve modes}
  CLOSED		= 1;

  TRANSPARENT		= 0;			{writing modes}
  TRANSPARENT_NEGATE	= 1;
  COMPLEMENT		= 2;
  COMPLEMENT_NEGATE	= 3;
  OVERLAY		= 4;
  OVERLAY_NEGATE	= 5;
  REPLACE		= 6;
  REPLACE_NEGATE	= 7;
  ERASE			= 8;
  ERASE_NEGATE		= 9;

  TO_X			= 1;			{fill modes}
  TO_Y			= 2;
  TO_POINT		= 3;

  LEFT			= 1;			{text justification}
  CENTER		= 2;
  RIGHT			= 3;
  TOP			= 1;
  BOTTOM		= 3;

  CHAR_SPACE		= 0;			{character path modes}
  STRING_SPACE		= 1;

  DOT			= 1;			{marker symbol codes}
  PLUS			= 2;
  STAR			= 3;
  CROSS			= 4;
  CIRCLE		= 5;

  BOTTOM_LEFT		= 0;			{origin codes}
  TOP_LEFT		= 1;
  TOP_RIGHT		= 2;
  BOTTOM_RIGHT		= 3;

  SOLID			= 1;			{line styles}
  DASHED		= 2;
  DOT_DASHED		= 3;
  DOTTED		= 4;
  DOT_DOT_DASHED	= 5;
  WIDE_DOTTED		= 6;
  SHORT_DASHED		= 7;
  LONG_DASHED		= 8;
  SHORT_DOT_DASHED	= 9;


type
  reals 	= array [MIN_REAL..MAX_REAL] of real;
  string	= packed array [1..STRINGLEN] of char;
  char_matrix	= array [0..15] of integer;
  color_array	= array [1..24] of integer;
  RGB_array	= array [1..3] of integer;
  integer_atts	= array [1..19] of integer;
  real_atts	= array [1..8] of real;


procedure cgl$move_abs(x,y : real); external;

procedure cgl$move_rel(dx,dy : real); external;

procedure cgl$inq_cp(var x,y : real); external;

procedure cgl$line_abs(x,y : real); external;

procedure cgl$line_rel(dx,dy : real); external;

procedure cgl$polyline_abs(var x,y : reals; n : integer); external;

procedure cgl$polyline_rel(var dx,dy : reals; n : integer); external;

procedure cgl$polygon_abs(var x,y : reals; n : integer); external;

procedure cgl$polygon_rel(var dx,dy : reals; n : integer); external;

procedure cgl$rectangle_abs(x,y : real); external;

procedure cgl$rectangle_rel(dx,dy : real); external;

procedure cgl$set_linestyle(n,p,m : integer); external;

procedure cgl$inq_linestyle(var n,p,m : integer); external;

procedure cgl$set_linewidth(dx,dy : real); external;

procedure cgl$inq_linewidth(var dx,dy : real); external;

procedure cgl$txt(s : string; n : integer); external;

procedure cgl$inq_te(n : integer; var dx,dy : real); external;

procedure cgl$set_font(n : integer); external;

procedure cgl$inq_font(var n : integer); external;

procedure cgl$set_charsize(w,h : real); external;

procedure cgl$inq_charsize(var w,h : real); external;

procedure cgl$set_charpath(a,m : integer); external;

procedure cgl$inq_charpath(var a,m : integer); external;

procedure cgl$set_charspace(dx,dy : real); external;

procedure cgl$inq_charspace(var dx,dy : real); external;

procedure cgl$set_charjust(h,v : integer); external;

procedure cgl$inq_charjust(var h,v : integer); external;

procedure cgl$set_charitalic(a : integer); external;

procedure cgl$inq_charitalic(var a : integer); external;

procedure cgl$set_font_size(n,dx,dy : integer); external;

procedure cgl$inq_font_size(var n,dx,dy : integer); external;

procedure cgl$load_char(c : integer; var m : char_matrix); external;

procedure cgl$marker_abs(x,y : real); external;

procedure cgl$marker_rel(dx,dy : real); external;

procedure cgl$polymarker_abs(var x,y : reals; n : integer); external;

procedure cgl$polymarker_rel(var dx,dy : reals; n : integer); external;

procedure cgl$set_marker_symbol(n,c : integer); external;

procedure cgl$inq_marker_symbol(var n,c : integer); external;

procedure cgl$arc_abs(x,y : real; a : integer); external;

procedure cgl$arc_rel(dx,dy : real; a : integer); external;

procedure cgl$curve_abs(var x,y : reals; n,b : integer); external;

procedure cgl$curve_rel(var dx,dy : reals; n,b : integer); external;

procedure cgl$set_writing_index(n : integer); external;

procedure cgl$inq_writing_index(var n : integer); external;

procedure cgl$set_background_index(n : integer); external;

procedure cgl$inq_background_index(var n : integer); external;

procedure cgl$set_color_map(var c : color_array); external;

procedure cgl$inq_color_map(var c : color_array); external;

procedure cgl$set_color_map_entry(n : integer; var c : RGB_array); external;

procedure cgl$inq_color_map_entry(n : integer; var c : RGB_array); external;

procedure cgl$set_writing_planes(n : integer); external;

procedure cgl$inq_writing_planes(var n : integer); external;

procedure cgl$set_writing_mode(n : integer); external;

procedure cgl$inq_writing_mode(var n : integer); external;

procedure cgl$set_primitive_atts(var i : integer_atts; var r : real_atts); external;

procedure cgl$inq_primitive_atts(var i : integer_atts; var r : real_atts); external;

procedure cgl$set_fill_mode(n : integer); external;

procedure cgl$inq_fill_mode(var n : integer); external;

procedure cgl$set_fill_axes(x,y : real); external;

procedure cgl$inq_fill_axes(var x,y : real); external;

procedure cgl$set_fill_char(n,c,wm,hm : integer); external;

procedure cgl$inq_fill_char(var n,c,wm,hm : integer); external;

procedure cgl$set_window(xmin,xmax,ymin,ymax : real); external;

procedure cgl$inq_window(var xmin,xmax,ymin,ymax : real); external;

procedure cgl$set_viewport(xmin,xmax,ymin,ymax : real); external;

procedure cgl$inq_viewport(var xmin,xmax,ymin,ymax : real); external;

procedure cgl$set_window_clipping(n : integer); external;

procedure cgl$inq_window_clipping(var n : integer); external;

procedure cgl$set_origin(n : integer); external;

procedure cgl$inq_origin(var n : integer); external;

procedure cgl$erase_viewport; external;

procedure cgl$scroll(dx,dy : real); external;

procedure cgl$initialize_cgl; external;

procedure cgl$terminate_cgl; external;

procedure cgl$new_frame; external;

procedure cgl$report_error(var f,e : integer); external;

procedure cgl$print(xmin,xmax,ymin,ymax,xoff,yoff : real); external;

procedure cgl$wait(s : real); external;

