MODULE vsta$cgl_driver;
{-----------------------------------------------------------------------------
!
!  DRIVER.PRG - CGL device interface emitting Vaxstation Gidis.
!
-----------------------------------------------------------------------------}

%include 'VSTA$LIBRARY:VSCGLDEF'

[global] procedure G$iron(var command : G$instr_type); forward;

function G$get_ptr : G$impure_ptr; external;
procedure G$write; external;
procedure G$print(i : integer); external;
procedure G$crlf; external;

procedure G$iron;
  {(var command : G$instr_type)}

const

{The GIDIS op-codes..}

  gidis_position_op 			= 1;	{x,y}
  gidis_position_push_op 		= 2;
  gidis_position_pop_op 		= 3;
  gidis_vector_op 			= 4;	{x,y}
  gidis_vector_pop_op 			= 5;
  gidis_screen_erase_op 		= 6;
  gidis_screen_addressing_op 		= 7;	{x,y}
  gidis_screen_offset_op 		= 8;	{x,y}
  gidis_select_background_color_op 	= 9;	{n}
  gidis_select_writing_color_op 	= 10;	{n}
  gidis_set_color_map_op 		= 11;	{map,address,R,G,B,M}
  gidis_set_writing_mode_op 		= 12;	{mode}
  gidis_set_pixel_size_op 		= 13;	{x,y}
  gidis_line_texture_op 		= 14;	{length,pattern,multiplier}
  gidis_area_texture_op 		= 15;	{alphabet,character,x,y}
  gidis_fill_to_X_op 			= 16;	{x}
  gidis_fill_to_Y_op 			= 17;	{y}
  gidis_fill_to_XY_op 			= 18;	{x,y}
  gidis_fill_off_op 			= 19;
  gidis_flood_op 			= 20;	{<GONE>}
  gidis_circum_arc_op 			= 21;	{x,y,angle}
  gidis_center_arc_op 			= 22;	{x,y,angle}
  gidis_curve_begin_open_op 		= 23;
  gidis_curve_begin_closed_op 		= 24;
  gidis_curve_continue_op 		= 25;	{x,y}
  gidis_curve_end_op 			= 26;
  gidis_plane_select_op 		= 27;	{n}
  gidis_swap_top_of_stack_op 		= 28;
  gidis_character_op 			= 29;	{character}
  gidis_reserved_30_op 			= 30;
  gidis_cell_cursor_movement_op 	= 31;	{dx,dy}
  gidis_cell_storage_size_op 		= 32;	{x,y,extent}
  gidis_cell_unit_size_op 		= 33;	{dx,dy}
  gidis_report_cell_standard_op 	= 34;
  gidis_cell_display_size_op 		= 35;	{dx,dy}
  gidis_cell_rotation_op 		= 36;	{angle}
  gidis_cell_italic_op 			= 37;	{angle}
  gidis_save_position_op 		= 38;	{register}
  gidis_restore_position_op 		= 39;	{register}
  gidis_cursor_style_op 		= 40;	{type}
  gidis_select_alphabet_op 		= 41;	{number}
  gidis_load_alphabet_op 		= 42;	{character,16X16 bits}
  gidis_reserved_43_op 			= 43;
  gidis_initialize_op 			= 44;
  gidis_wait_op 			= 45;	{ticks}
  gidis_save_state_op 			= 46;	{mask}
  gidis_restore_state_op 		= 47;	{mask}
  gidis_report_position_op 		= 48;
  gidis_reserved_49_op 			= 49;
  gidis_reserved_50_op 			= 50;
  gidis_screen_print_op 		= 51;	{x,y,x,y,x,y}
  gidis_set_clipping_region_op		= 52;	{x,y,x,y}

  relative_x				= 256;	{x is relative}
  relative_y				= 512;	{y is relative}

var
  code	: G$gidis_op;
  ida	: G$impure_ptr;
  i	: integer;


  procedure insert(word : integer);
    {put a word in the buffer for output}

  begin
    with ida^ do begin
      if G$buffer_count = G$IO_BUFFER_LENGTH
	then G$write;				{buffer full - write it}
      G$buffer_count:= G$buffer_count + 1;	{next free word}
      G$buffer[G$buffer_count]:= word;		{in it goes}
      if G$debug
	then G$print(word)
    end
  end;



begin
  ida:= G$get_ptr;

  with command do begin
  
    case G$instr of

      G$position:

	code:= gidis_position_op;

      G$report_position:

	code:= gidis_report_position_op;

      G$vector:

	code:= gidis_vector_op;

      G$character:

	code:= gidis_character_op;

      G$arc:

	code:= gidis_circum_arc_op;

      G$curve_open:

	code:= gidis_curve_begin_open_op;

      G$curve_closed:

	code:= gidis_curve_begin_closed_op;

      G$curve_continue:

	code:= gidis_curve_continue_op;

      G$curve_end:

	code:= gidis_curve_end_op;

      G$set_writing_index:

	code:= gidis_select_writing_color_op;

      G$set_background_index:

	code:= gidis_select_background_color_op;

      G$set_color_map:

	code:= gidis_set_color_map_op;

      G$set_writing_planes:

	code:= gidis_plane_select_op;

      G$set_writing_mode:

	code:= gidis_set_writing_mode_op;

      G$set_linestyle:

	code:= gidis_line_texture_op;

      G$set_linewidth:

	code:= gidis_set_pixel_size_op;

      G$set_fill_off:

	code:= gidis_fill_off_op;

      G$set_fill_x:

	code:= gidis_fill_to_X_op;

      G$set_fill_y:

	code:= gidis_fill_to_Y_op;

      G$set_fill_point:

	code:= gidis_fill_to_XY_op;

      G$set_fillstyle:

	code:= gidis_area_texture_op;

      G$set_alphabet:

	code:= gidis_select_alphabet_op;

      G$set_storage_size:

	code:= gidis_cell_storage_size_op;

      G$load_cell:

	code:= gidis_load_alphabet_op;

      G$set_unit_size:

	code:= gidis_cell_unit_size_op;

      G$set_display_size:

	code:= gidis_cell_display_size_op;

      G$set_angle:

	code:= gidis_cell_rotation_op;

      G$set_space:

	code:= gidis_cell_cursor_movement_op;

      G$set_italic:

	code:= gidis_cell_italic_op;

      G$initialize:

	code:= gidis_initialize_op;

      G$set_screen_address:

	code:= gidis_screen_addressing_op;

      G$screen_erase:

	code:= gidis_screen_erase_op;

      G$scroll:

	code:= gidis_screen_offset_op;

      G$hardcopy:

	code:= gidis_screen_print_op;

      G$delay:

	code:= gidis_wait_op;

      G$set_clipping_region:

	code:= gidis_set_clipping_region_op

    end;

    insert(code);				{the opcode}
    for i:= 1 to G$parameter_count do
      insert(G$parameter_list[i]);		{then the parameters}
    if ida^.G$debug and (code <> gidis_report_position_op)
      then G$crlf				{new debug line}
  end
end;



END.
