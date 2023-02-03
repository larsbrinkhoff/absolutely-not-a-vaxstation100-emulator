{-----------------------------------------------------------------------------
!
!  DEFS.PRG - CGL data declarations and Vaxstation Gidis function declarations.
!    Retained segments are held in a disc work file.
!    (file should be copied to CGL.PAS in build for inclusion in all modules)
!
-----------------------------------------------------------------------------}

{$noindexcheck}					{skip these run time checks..}
{$nopointercheck}
{$norangecheck}
{$nostackcheck}

const

{the following are all device DEPENDENT and are set for Vaxstation gidis}


  G$FONT_0_EXTENT		=      255;	
  G$FONT_0_PIXEL_WIDTH		=	12;
  G$FONT_0_PIXEL_HEIGHT		=	10;
  G$MAX_FONT			=	 3;
  G$FONT_ARRAY_LAST_ELEMENT	=	11;	{make this n * (MAX_FONT+1)-1}
  G$FONT_ENTRY_SIZE		=	 3;	{n = size of each font entry}
  G$TOTAL_FONT_MEMORY		=     4000;	{bytes}
  G$MAX_CHAR_PIXEL_SIZE		=	16;

  G$MIN_COLOR_INDEX		=	 0;	{first address in color map}
  G$MAX_COLOR_INDEX		=	16;	{last address in color map}
  G$COLOR_MAP_ARRAY_SIZE	=	24;	{make this n * no. of indices}
  G$COLOR_MAP_ENTRY_SIZE	=	 3;	{n = size of each index entry}
  G$COLOR_MAP_NUMBER		=	 0;	{if there's only one}
  G$MIN_COLOR_VALUE		=	 0;	{RGB values}
  G$MAX_COLOR_VALUE		=	16;
  G$PLANE_SELECT_MIN_VALUE	=	 0;	{plane number combos}
  G$PLANE_SELECT_MAX_VALUE	=	 7;

  G$MIN_WRITING_MODE		=	 0;
  G$MAX_WRITING_MODE		=	 9;

  G$FIXED_MARKER_SYMBOLS	=	 5;

  G$FIXED_LINE_STYLES		=	 9;
  G$LINE_STYLE_STANDARD_MULTIPLIER=	 2;

  G$TICKS_PER_SECOND		=	60;	{for wait function}

{the CGL function numbers..}

{NOTE: the list order must correspond with the dispatch table in ENTER}

  FNG$NULL			=	 0;

  FNG$MA			=	 1;	{moves}
  FNG$MR			=	 2;
  FNG$ICP			=	 3;

  FNG$LA			=	 4;	{lines}
  FNG$LR			=	 5;
  FNG$PLA			=	 6;
  FNG$PLR			=	 7;
  FNG$PGA			=	 8;
  FNG$PGR			=	 9;
  FNG$RA			=	10;
  FNG$RR			=	11;
  FNG$SLS			=	12;
  FNG$ILS			=	13;
  FNG$SLW			=	14;
  FNG$ILW			=	15;

  FNG$T				=	16;	{text}
  FNG$ITE			=	17;
  FNG$SFO			=	18;
  FNG$IFO			=	19;
  FNG$SCS			=	20;
  FNG$ICS			=	21;
  FNG$SCA			=	22;
  FNG$ICA			=	23;
  FNG$SCM			=	24;
  FNG$ICM			=	25;
  FNG$SCJ			=	26;
  FNG$ICJ			=	27;
  FNG$SCI			=	28;
  FNG$ICI			=	29;
  FNG$SFS			=	30;
  FNG$IFS			=	31;
  FNG$LDC			=	32;

  FNG$MRA			=	33;	{markers}
  FNG$MRR			=	34;
  FNG$PMRA			=	35;
  FNG$PMRR			=	36;
  FNG$SMS			=	37;
  FNG$IMS			=	38;

  FNG$AA			=	39;	{curves}
  FNG$AR			=	40;
  FNG$CA			=	41;
  FNG$CR			=	42;

  FNG$CRS			=	43;	{segments}
  FNG$EXS			=	44;
  FNG$IOS			=	45;
  FNG$CLS			=	46;
  FNG$DLS			=	47;
  FNG$DLAS			=	48;
  FNG$RNS			=	49;
  FNG$SGV			=	50;
  FNG$IGV			=	51;
  FNG$SSV			=	52;
  FNG$ISV			=	53;
  FNG$SGA			=	54;
  FNG$IGA			=	55;
  FNG$SSA			=	56;
  FNG$ISA			=	57;
  FNG$SSS			=	58;
  FNG$ISS			=	59;

  FNG$SWI			=	60;	{atts}
  FNG$IWI			=	61;
  FNG$SBI			=	62;
  FNG$IBI			=	63;
  FNG$SMP			=	64;
  FNG$IMP			=	65;
  FNG$SMPI			=	66;
  FNG$IMPI			=	67;
  FNG$SWP			=	68;
  FNG$IWP			=	69;
  FNG$SWM			=	70;
  FNG$IWM			=	71;
  FNG$SPA			=	72;
  FNG$IPA			=	73;

  FNG$SFM			=	74;	{fill}
  FNG$IFM			=	75;
  FNG$SFA			=	76;
  FNG$IFA			=	77;
  FNG$SFC			=	78;
  FNG$IFC			=	79;

  FNG$SW			=	80;	{view}
  FNG$IW			=	81;
  FNG$SV			=	82;
  FNG$IV			=	83;
  FNG$SC			=	84;
  FNG$IC			=	85;
  FNG$SO			=	86;
  FNG$IO			=	87;
  FNG$EV			=	88;
  FNG$SCRL			=	89;

  FNG$INIT			=	90;	{control}
  FNG$EXIT			=	91;
  FNG$NF			=	92;
  FNG$RMRE			=	93;
  FNG$PRNT			=	94;
  FNG$WAIT			=	95;

  G$MAX_PARAMETERS		=	17;	{max GIDIS words in one call}
  G$MAX_SEGMENTS		=      128;	{max number of segments}
  G$MAX_REALS			=    16383;	{max elements in real array}
  G$IO_BUFFER_LENGTH	 	=      256;	{QIO buffer size (words)}
  G$ATTRIBUTE_ISIZE		=	19;	{integers in attributes list}
  G$ATTRIBUTE_RSIZE		=	 8;	{reals in attributes list}
  G$DPB_LENGTH			=	12;	{Directive Parameter Block}

{ From the RMS V1.8 manual, the FAB length looks to be 50 bytes and the RAB
  length 41 bytes.  However, who knows, this may change.
  Hence the safety margin...}

  G$FAB_LENGTH			=	60;	{file access block (bytes)}
  G$RAB_LENGTH			=	50;	{record access block (bytes)}
  G$BLOCK_SIZE			=      255;	{disc block (words)}

  G$LEFT			=	 0;	{indices in edge arrays}
  G$RIGHT			=	 2;
  G$BOTTOM			=	 1;
  G$TOP				=	 3;

  G$ON				=	 1;	{switch settings}
  G$OFF				=	 0;

  G$TRANSPARENT			=	 0;	{codes for writing modes}
  G$TRANSPARENT_NEGATE		=	 1;
  G$COMPLEMENT			=	 2;
  G$COMPLEMENT_NEGATE		=	 3;
  G$OVERLAY			=	 4;
  G$OVERLAY_NEGATE		=	 5;
  G$REPLACE			=	 6;
  G$REPLACE_NEGATE		=	 7;
  G$ERASE			=	 8;
  G$ERASE_NEGATE		=	 9;

  G$TO_X			=	 1;	{fill mode codes}
  G$TO_Y			=	 2;
  G$TO_POINT			=	 3;

  G$VISIBLE			=	 1;	{visibility codes}
  G$INVISIBLE			=	 0;
  G$HIGHLIGHTED			=	 1;	{highlighting codes}
  G$NON_HIGHLIGHTED		=	 0;

  G$BOTTOM_LEFT			=	 0;	{origin codes}
  G$TOP_LEFT			=	 1;
  G$TOP_RIGHT			=	 2;
  G$BOTTOM_RIGHT		=	 3;

{DEFINE THE MAXIMUM INTEGER FOR A 16 BIT MACHINE}

  G$16BIT_MAXINT		=	 32767;


type

  G$parameter_range	= 0..G$MAX_PARAMETERS;
  G$gidis_op		= 0..255;
  G$16_bits		= 0..65535;
  G$screen_edges	= array [0..3] of integer;
  G$window_edges	= array [0..3] of real;
  G$transformation_info	= array [0..5] of real;
  G$origin_info		= array [0..1] of boolean;
  G$font_info		= array [0..G$FONT_ARRAY_LAST_ELEMENT] of integer;
  G$char_attributes	= (G$alphabet, G$dimension, G$direction, G$slant);
  G$text_string		= packed array [1..G$16BIT_MAXINT] of char;
  G$parameters		= array [1..G$MAX_PARAMETERS] of [word] G$16_bits;
  G$reals		= array [1..G$MAX_REALS] of real;
  G$char_matrix		= array [1..G$MAX_CHAR_PIXEL_SIZE] of [word] G$16_bits;
  G$RGB_values		= array [1..G$COLOR_MAP_ENTRY_SIZE] of integer;
  G$RGB_array		= array [1..G$COLOR_MAP_ARRAY_SIZE] of integer;
  G$directive		= array [1..G$DPB_LENGTH] of integer;
  G$fab			= array [1..G$FAB_LENGTH] of char;
  G$rab			= array [1..G$RAB_LENGTH] of char;
  G$block		= array [0..G$BLOCK_SIZE] of integer;
  G$io_buffer		= array [1..G$IO_BUFFER_LENGTH] of [word] G$16_bits;
  G$marker_symbols	= array [1..G$FIXED_MARKER_SYMBOLS] of integer;
  G$line_styles		= array [1..G$FIXED_LINE_STYLES] of G$16_bits;
  G$integer_attributes	= array [1..G$ATTRIBUTE_ISIZE] of integer;
  G$real_attributes	= array [1..G$ATTRIBUTE_RSIZE] of real;
  G$attributes_lists	= record
    G$list_1		: G$integer_attributes;
    G$list_2		: G$real_attributes
  end;

{the driver op-codes..}

  G$opcode		= (	G$position,
				G$report_position,
				G$vector,
				G$character,
				G$arc,
				G$curve_open,
				G$curve_closed,
				G$curve_continue,
				G$curve_end,
				G$set_writing_index,
				G$set_background_index,
				G$set_color_map,
				G$set_writing_planes,
				G$set_writing_mode,
				G$set_linestyle,
				G$set_linewidth,
				G$set_fill_off,
				G$set_fill_x,
				G$set_fill_y,
				G$set_fill_point,
				G$set_fillstyle,
				G$set_alphabet,
				G$set_storage_size,
				G$load_cell,
				G$set_unit_size,
				G$set_display_size,
				G$set_angle,
				G$set_space,
				G$set_italic,
				G$initialize,
				G$set_screen_address,
				G$screen_erase,
				G$scroll,
				G$hardcopy,
				G$delay,
				G$set_clipping_region	);


{a display command..}

  G$instr_type		= record
    G$instr 		: G$opcode;
    G$parameter_count	: G$parameter_range;
    G$parameter_list	: G$parameters
  end;

{user's impure data area..}

  G$impure_ptr		= ^G$impure_area;

  G$impure_area		= record

{*** DO NOT MOVE THE FOLLOWING BLOCK OF DATA OR CHANGE ITS ORDER!! ***}
{..code in 'enter' and 'dio' depends on this being like it is..}

    G$fwdlnk			: integer;	{forward link in DB}
    G$bwdlnk			: integer;	{backward link in DB}
    G$channel			: integer;	{channel for this device}
    G$current_function		: integer;
    G$vstafiller		: array [1..4] of integer;
    G$initialized,				{TRUE if initialized}
    G$debug			: boolean;	{	 debugging 2*.5=1}
    G$function_number,
    G$error_number,				{error logging info}
    G$buffer_count		: integer;	{words in io buffer 3*1=3}
    G$buffer			: G$io_buffer;	{		   64*1=64}
    G$screen_top,
    G$screen_bottom,
    G$screen_left,
    G$screen_right		: integer;


{the remainder can be moved around at will - but do a COMPLETE rebuild}

  {general internal state info..}
    G$text_justified,				{TRUE if text to be justified}
    G$set_for_markers				{	 text attributes set}
				: boolean;			{2*.5=1}

    G$current_x_position,
    G$current_y_position,
    G$line_width,
    G$line_height,
    G$fill_x,
    G$fill_y,
    G$char_width,
    G$char_height,
    G$char_marker_width,
    G$char_marker_height,
    G$char_width_spacing,
    G$char_height_spacing
				: real;				{12*2=24}

    G$marker_number,
    G$marker_symbol,
    G$writing_index,
    G$background_index,
    G$writing_planes,
    G$writing_mode,
    G$line_style_number,
    G$line_style_pattern,
    G$line_style_multiplier,
    G$fill_mode,
    G$fill_font,
    G$fill_char,
    G$fill_char_width_multiplier,
    G$fill_char_height_multiplier,
    G$current_font_index,
    G$font_memory_left,
    G$char_physical_width,
    G$char_physical_height,
    G$char_unit_width,
    G$char_unit_height,
    G$char_width_mirrored,
    G$char_height_mirrored,
    G$char_path,
    G$char_rotation_mode,
    G$char_italic,
    G$char_horizontal_justification,
    G$char_vertical_justification,
    G$clipping,
    G$origin
				: integer;			{29*1=29}

  {transformation values and constants}
    G$screen			: G$screen_edges;		{4*1=4}
    G$window,
    G$viewport			: G$window_edges;		{8*2=16}
    G$transformation_constant	: G$transformation_info;	{6*2=12}
    G$corner			: G$origin_info;		{2*.5=1}

  {values affected by new window/viewport/origin}
    G$screen_char_width,
    G$screen_char_height,
    G$screen_char_width_spacing,
    G$screen_char_height_spacing,
    G$screen_line_width,
    G$screen_line_height
				: integer;			{6*1=6}
  {odds and ends}
    G$text_attributes		: set of G$char_attributes;	{1*.5=1}
    G$color_map_array		: G$RGB_array;			{24*1=24}
    G$font_array		: G$font_info;			{12*1=12}

						{total less segments = }

  {segment information}
    G$seg_open,
    G$seg_file_open,
    G$extending_seg		: boolean;
    G$seg_attributes,
    G$saved_attributes		: G$attributes_lists;		{35*2=70}
    G$seg_visibility,
    G$seg_count,
    G$seg_name,
    G$seg_length,
    G$seg_block_number,
    G$seg_block_count		: integer;
    G$work_file_fab		: G$fab;
    G$work_file_rab		: G$rab;
    G$seg_io_buffer		: G$block;			{256*1=256}
  end;

						{total with segments = }
