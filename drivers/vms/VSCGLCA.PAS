{
%include file for OMSI PASCAL calls to CGL

 NOTE: the parameters are pushed backwards to facilitate building an R5
       argument list on the stack
}

%include cgltypes;			{pick up type declarations}

procedure G$0(
						fn : integer); external;
procedure G$1(var p1 : integer;
						fn : integer); external;
procedure G$2(var p2,p1 : real;
						fn : integer); external;
procedure G$3(var p3 : integer; var p2,p1 : reals;
						fn : integer); external;
procedure G$4(var p3,p2,p1 : integer;
						fn : integer); external;
procedure G$5(var p2,p1 : integer;
						fn : integer); external;
procedure G$6(var p4,p3,p2,p1 : real;
						fn : integer); external;
procedure G$7(var p3 : integer; var p2,p1 : real;
						fn : integer); external;
procedure G$8(var p2 : integer; var p1 : string;
						fn : integer); external;
procedure G$9(var p4,p3 : integer; var p2,p1 : reals;
						fn : integer); external;
procedure G$10(var p4,p3,p2,p1 : integer;
						fn : integer); external;
procedure G$11(var p3,p2 : real; var p1 : integer;
						fn : integer); external;
procedure G$12(var p1 : real;
						fn : integer); external;
procedure G$13(var p2 : char_matrix; var p1 : integer;
						fn : integer); external;
procedure G$14(var p1 : color_array;
						fn : integer); external;
procedure G$15(var p2 : RGB_array; var p1 : integer;
						fn : integer); external;
procedure G$16(var p6,p5,p4,p3,p2,p1 : real;
						fn : integer); external;
procedure G$17(var p2 : real_atts; var p1 : integer_atts;
						fn : integer); external;

procedure move_abs(x,y : real);

begin
  G$2(y,x,1)
end;


procedure move_rel(dx,dy : real);

begin
  G$2(dy,dx,2)
end;


procedure inq_cp(var x,y : real);

begin
  G$2(y,x,3)
end;


procedure line_abs(x,y : real);

begin
  G$2(y,x,4)
end;


procedure line_rel(dx,dy : real);

begin
  G$2(dy,dx,5)
end;


procedure polyline_abs(var x,y : reals; n : integer);

begin
  G$3(n,y,x,6)
end;


procedure polyline_rel(var dx,dy : reals; n : integer);

begin
  G$3(n,dy,dx,7)
end;


procedure polygon_abs(var x,y : reals; n : integer);

begin
  G$3(n,y,x,8)
end;


procedure polygon_rel(var dx,dy : reals; n : integer);

begin
  G$3(n,dy,dx,9)
end;


procedure rectangle_abs(x,y : real);

begin
  G$2(y,x,10)
end;


procedure rectangle_rel(dx,dy : real);

begin
  G$2(dy,dx,11)
end;


procedure set_linestyle(n,p,m : integer);

begin
  G$4(m,p,n,12)
end;


procedure inq_linestyle(var n,p,m : integer);

begin
  G$4(m,p,n,13)
end;


procedure set_linewidth(dx,dy : real);

begin
  G$2(dy,dx,14)
end;


procedure inq_linewidth(var dx,dy : real);

begin
  G$2(dy,dx,15)
end;

procedure txt(s : string; n : integer);

begin
  G$8(n,s,16)
end;


procedure inq_te(n : integer; var dx,dy : real);

begin
  G$11(dy,dx,n,17)
end;


procedure set_font(n : integer);

begin
  G$1(n,18)
end;


procedure inq_font(var n : integer);

begin
  G$1(n,19)
end;


procedure set_charsize(w,h : real);

begin
  G$2(h,w,20)
end;


procedure inq_charsize(var w,h : real);

begin
  G$2(h,w,21)
end;


procedure set_charpath(a,m : integer);

begin
  G$5(m,a,22)
end;


procedure inq_charpath(var a,m : integer);

begin
  G$5(m,a,23)
end;


procedure set_charspace(dx,dy : real);

begin
  G$2(dy,dx,24)
end;


procedure inq_charspace(var dx,dy : real);

begin
  G$2(dy,dx,25)
end;


procedure set_charjust(h,v : integer);

begin
  G$5(v,h,26)
end;


procedure inq_charjust(var h,v : integer);

begin
  G$5(v,h,27)
end;


procedure set_charitalic(a : integer);

begin
  G$1(a,28)
end;


procedure inq_charitalic(var a : integer);

begin
  G$1(a,29)
end;


procedure set_font_size(n,dx,dy : integer);

begin
  G$4(dy,dx,n,30)
end;


procedure inq_font_size(var n,dx,dy : integer);

begin
  G$4(dy,dx,n,31)
end;


procedure load_char(c : integer; var m : char_matrix);

begin
  G$13(m,c,32)
end;

procedure marker_abs(x,y : real);

begin
  G$2(y,x,33)
end;


procedure marker_rel(dx,dy : real);

begin
  G$2(dy,dx,34)
end;


procedure polymarker_abs(var x,y : reals; n : integer);

begin
  G$3(n,y,x,35)
end;


procedure polymarker_rel(var dx,dy : reals; n : integer);

begin
  G$3(n,dy,dx,36)
end;


procedure set_marker_symbol(n,c : integer);

begin
  G$5(c,n,37)
end;


procedure inq_marker_symbol(var n,c : integer);

begin
  G$5(c,n,38)
end;

procedure arc_abs(x,y : real; a : integer);

begin
  G$7(a,y,x,39)
end;


procedure arc_rel(dx,dy : real; a : integer);

begin
  G$7(a,dy,dx,40)
end;


procedure curve_abs(var x,y : reals; n,b : integer);

begin
  G$9(b,n,y,x,41)
end;


procedure curve_rel(var dx,dy : reals; n,b : integer);

begin
  G$9(b,n,dy,dx,42)
end;

procedure set_writing_index(n : integer);

begin
  G$1(n,60)
end;


procedure inq_writing_index(var n : integer);

begin
  G$1(n,61)
end;


procedure set_background_index(n : integer);

begin
  G$1(n,62)
end;


procedure inq_background_index(var n : integer);

begin
  G$1(n,63)
end;


procedure set_color_map(var c : color_array);

begin
  G$14(c,64)
end;


procedure inq_color_map(var c : color_array);

begin
  G$14(c,65)
end;


procedure set_color_map_entry(n : integer; var c : RGB_array);

begin
  G$15(c,n,66)
end;


procedure inq_color_map_entry(n : integer; var c : RGB_array);

begin
  G$15(c,n,67)
end;


procedure set_writing_planes(n : integer);

begin
  G$1(n,68)
end;


procedure inq_writing_planes(var n : integer);

begin
  G$1(n,69)
end;


procedure set_writing_mode(n : integer);

begin
  G$1(n,70)
end;


procedure inq_writing_mode(var n : integer);

begin
  G$1(n,71)
end;


procedure set_primitive_atts(var i : integer_atts; var r : real_atts);

begin
  G$17(r,i,72)
end;


procedure inq_primitive_atts(var i : integer_atts; var r : real_atts);

begin
  G$17(r,i,73)
end;

procedure set_fill_mode(n : integer);

begin
  G$1(n,74)
end;


procedure inq_fill_mode(var n : integer);

begin
  G$1(n,75)
end;


procedure set_fill_axes(x,y : real);

begin
  G$2(y,x,76)
end;


procedure inq_fill_axes(var x,y : real);

begin
  G$2(y,x,77)
end;


procedure set_fill_char(n,c,wm,hm : integer);

begin
  G$10(hm,wm,c,n,78)
end;


procedure inq_fill_char(var n,c,wm,hm : integer);

begin
  G$10(hm,wm,c,n,79)
end;

procedure set_window(xmin,xmax,ymin,ymax : real);

begin
  G$6(ymax,ymin,xmax,xmin,80)
end;


procedure inq_window(var xmin,xmax,ymin,ymax : real);

begin
  G$6(ymax,ymin,xmax,xmin,81)
end;


procedure set_viewport(xmin,xmax,ymin,ymax : real);

begin
  G$6(ymax,ymin,xmax,xmin,82)
end;


procedure inq_viewport(var xmin,xmax,ymin,ymax : real);

begin
  G$6(ymax,ymin,xmax,xmin,83)
end;


procedure set_window_clipping(n : integer);

begin
  G$1(n,84)
end;


procedure inq_window_clipping(var n : integer);

begin
  G$1(n,85)
end;


procedure set_origin(n : integer);

begin
  G$1(n,86)
end;


procedure inq_origin(var n : integer);

begin
  G$1(n,87)
end;


procedure erase_viewport;

begin
  G$0(88)
end;


procedure scroll(dx,dy : real);

begin
  G$2(dy,dx,89)
end;

procedure initialize_cgl;

begin
  G$0(90)
end;


procedure terminate_cgl;

begin
  G$0(91)
end;


procedure new_frame;

begin
  G$0(92)
end;


procedure report_error(var f,e : integer);

begin
  G$5(e,f,93)
end;


procedure print(xmin,xmax,ymin,ymax,xoff,yoff : real);

begin
  G$16(yoff,xoff,ymax,ymin,xmax,xmin,94)
end;


procedure wait(s : real);

begin
  G$12(s,95)
end;
