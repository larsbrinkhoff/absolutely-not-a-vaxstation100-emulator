 
MODULE VSTAGBL ;
 
[HIDDEN] TYPE	(**** Pre-declared data types ****)
	$BYTE = [BYTE] -128..127;
	$WORD = [WORD] -32768..32767;
	$QUAD = [QUAD,UNSAFE] RECORD
		L0:UNSIGNED; L1:INTEGER; END;
	$OCTA = [OCTA,UNSAFE] RECORD
		L0,L1,L2:UNSIGNED; L3:INTEGER; END;
	$UBYTE = [BYTE] 0..255;
	$UWORD = [WORD] 0..65535;
	$UQUAD = [QUAD,UNSAFE] RECORD
		L0,L1:UNSIGNED; END;
	$UOCTA = [OCTA,UNSAFE] RECORD
		L0,L1,L2,L3:UNSIGNED; END;
	$PACKED_DEC = [BIT(4),UNSAFE] 0..15;
	$DEFTYP = [UNSAFE] INTEGER;
	$DEFPTR = [UNSAFE] ^$DEFTYP;
	$BOOL = [BIT(1),UNSAFE] BOOLEAN;
	$BIT2 = [BIT(2),UNSAFE] 0..3;
	$BIT3 = [BIT(3),UNSAFE] 0..7;
	$BIT4 = [BIT(4),UNSAFE] 0..15;
	$BIT5 = [BIT(5),UNSAFE] 0..31;
	$BIT6 = [BIT(6),UNSAFE] 0..63;
	$BIT7 = [BIT(7),UNSAFE] 0..127;
	$BIT8 = [BIT(8),UNSAFE] 0..255;
	$BIT9 = [BIT(9),UNSAFE] 0..511;
	$BIT10 = [BIT(10),UNSAFE] 0..1023;
	$BIT11 = [BIT(11),UNSAFE] 0..2047;
	$BIT12 = [BIT(12),UNSAFE] 0..4095;
	$BIT13 = [BIT(13),UNSAFE] 0..8191;
	$BIT14 = [BIT(14),UNSAFE] 0..16383;
	$BIT15 = [BIT(15),UNSAFE] 0..32767;
	$BIT16 = [BIT(16),UNSAFE] 0..65535;
	$BIT17 = [BIT(17),UNSAFE] 0..131071;
	$BIT18 = [BIT(18),UNSAFE] 0..262143;
	$BIT19 = [BIT(19),UNSAFE] 0..524287;
	$BIT20 = [BIT(20),UNSAFE] 0..1048575;
	$BIT21 = [BIT(21),UNSAFE] 0..2097151;
	$BIT22 = [BIT(22),UNSAFE] 0..4194303;
	$BIT23 = [BIT(23),UNSAFE] 0..8388607;
	$BIT24 = [BIT(24),UNSAFE] 0..16777215;
	$BIT25 = [BIT(25),UNSAFE] 0..33554431;
	$BIT26 = [BIT(26),UNSAFE] 0..67108863;
	$BIT27 = [BIT(27),UNSAFE] 0..134217727;
	$BIT28 = [BIT(28),UNSAFE] 0..268435455;
	$BIT29 = [BIT(29),UNSAFE] 0..536870911;
	$BIT30 = [BIT(30),UNSAFE] 0..1073741823;
	$BIT31 = [BIT(31),UNSAFE] 0..2147483647;
	$BIT32 = [BIT(32),UNSAFE] UNSIGNED;
 
(*** MODULE $VSTAGBL ***)
 
(*                                                                          *)
(*++                                                                        *)
(* FACILITY:                                                                *)
(*   VAX WORKSTATIONS                                                       *)
(*                                                                          *)
(* ABSTRACT:                                                                *)
(*                                                                          *)
(*  This file contains the predefined symbols given in the manual for the   *)
(*  VAXstation Programmer's Library. Only those symbols which do NOT define *)
(*  VSTA error message symbols are defined here.                            *)
(*                                                                          *)
(* ENVIRONMENT:                                                             *)
(*   VAX workstation: 780, 750, 730 running VMS with at least one VAXstation *)
(*   graphics subsystem.                                                    *)
(*                                                                          *)
(*                                                                          *)
(* RENDITION SYMBOLS                                                        *)
(*                                                                          *)
 
CONST	VSTA$M_REND_BOLD = 1;
	VSTA$M_REND_ITALICS = 2;
	VSTA$M_REND_UNDERSCORE = 4;
	VSTA$M_REND_BLINK = 8;
	VSTA$M_REND_REVERSE = 16;
	VSTA$M_REND_EXTRA = 224;
	VSTA$K_REND_BLOCK_SIZE = 1;     (*LENGTH OF DATA BLOCK              *)
 
TYPE	REND_BITS = RECORD
	    VSTA$V_REND_BOLD : [POS(0)] $BOOL; (*BOLD RENDITION             *)
	    VSTA$V_REND_ITALICS : [POS(1)] $BOOL; (*ITALICS RENDITION       *)
	    VSTA$V_REND_UNDERSCORE : [POS(2)] $BOOL; (*UNDERSCORE RENDITION *)
	    VSTA$V_REND_BLINK : [POS(3)] $BOOL; (*BLINK RENDITION           *)
	    VSTA$V_REND_REVERSE : [POS(4)] $BOOL; (*REVERSE VIDEO RENDITION *)
	    VSTA$V_REND_EXTRA : [POS(5)] $BIT3; (*FOR FUTURE DEC ABUSE      *)
	END;
 
(*                                                                          *)
 
CONST	VSTA$K_NONE = -1;               (* MEASURE TEXT SPECIAL             *)
 
(*                                                                          *)
(* FIELD FORMATS                                                            *)
(*                                                                          *)
 
CONST	VSTA$K_FF_LEFT = 0;
	VSTA$K_FF_RIGHT = 1;
	VSTA$K_FF_CENTER = 2;
 
(*                                                                          *)
(* SDA OBJECT PROTECTION                                                    *)
(*                                                                          *)
 
CONST	VSTA$K_UNPROTECTED = -1;
	VSTA$K_DEFAULT_PROTECTION = 65295;
 
(*                                                                          *)
(* VIRTUAL KEYBOARD TRANSLATION TABLE IDS AND TIA CONFORMANCE LEVELS        *)
(*                                                                          *)
(* NOTE: MAKE SURE THE CONSTANT BELOW REFLECTS THE MAXIMUM VALID TRANSLATION *)
(*       TABLE NUMBER WHEN ADDING TRANSLATION TABLES. OTHERWISE, YOUR NEW   *)
(*	 TABLE WILL BE IGNORED. TABLES THAT END IN _TYP ARE TYPEWRITER      *)
(*	 TRANSLATION TABLES AND TABLES THAT END IN _DP ARE DATA PROCESSING  *)
(*	 TRANSLATON TABLES. THE NAMES OF THE TABLES CORRESPOND TO THE       *)
(*	 HARDWARE KEYBOARD OF THAT LANGUAGE.                                *)
(*                                                                          *)
(* NOTE: TABLES 	1.)LK201-CB = LK201-CP                              *)
(*			2.)LK201-CM = LK201-CF                              *)
(*                                                                          *)
 
CONST	VSTA$K_TT_DECMS_ENGLISH = 0;    (*DEC MULTINATIONAL ENGLISH         *)
	VSTA$K_LK201_CA = 0;            (*DEC MULTINATIONAL ENGLISH(0)      *)
	VSTA$K_LK201_CC_TYP = 1;        (*CANADIAN (FRENCH) TYPEWRITER(1)   *)
	VSTA$K_LK201_CC_DP = 2;         (*CANADIAN (FRENCH) DATA PRO.(2)    *)
	VSTA$K_LK201_CD_TYP = 3;        (*DANISH TYPEWRITER(3)              *)
	VSTA$K_LK201_CD_DP = 4;         (*DANISH DATA PRO.(4)               *)
	VSTA$K_LK201_CE_TYP = 5;        (*BRITISH TYPEWRITER(5)             *)
	VSTA$K_LK201_CE_DP = 6;         (*BRITISH DATA PRO.(6)              *)
	VSTA$K_LK201_CF_TYP = 7;        (*FINNISH TYPEWRITER(7)             *)
	VSTA$K_LK201_CF_DP = 8;         (*FINNISH DATA PRO.(8)              *)
	VSTA$K_LK201_CG_TYP = 9;        (*GERMAN/AUSTRIAN TYPEWRITER(9)     *)
	VSTA$K_LK201_CG_DP = 10;        (*GERMAN/AUSTRIAN DATA PRO.(10)     *)
	VSTA$K_LK201_CH_TYP = 11;       (*DUTCH TYPEWRITER(11)              *)
	VSTA$K_LK201_CH_DP = 12;        (*DUTCH DATA PRO.(12)               *)
	VSTA$K_LK201_CI_TYP = 13;       (*ITALIAN TYPEWRITER(13)            *)
	VSTA$K_LK201_CI_DP = 14;        (*ITALIAN DATA PRO.(14)             *)
	VSTA$K_LK201_CK_TYP = 15;       (*FRENCH/SWISS TYPEWRITER(15)       *)
	VSTA$K_LK201_CK_DP = 16;        (*FRENCH/SWISS DATA PRO.(16)        *)
	VSTA$K_LK201_CL_TYP = 17;       (*GERMAN/SWISS TYPEWRITER(17)       *)
	VSTA$K_LK201_CL_DP = 18;        (*GERMAN/SWISS DATA PRO.(18)        *)
	VSTA$K_LK201_CN_TYP = 19;       (*NORWEGIAN TYPEWRITER(19)          *)
	VSTA$K_LK201_CN_DP = 20;        (*NORWEGIAN DATA PRO.(20)           *)
	VSTA$K_LK201_CP_TYP = 21;       (*FRENCH/BELGIUM TYPEWRITER(21)     *)
	VSTA$K_LK201_CP_DP = 22;        (*FRENCH/BELGIUM DATA PRO.(22)      *)
	VSTA$K_LK201_CS_TYP = 23;       (*SPANISH TYPEWRITER(23)            *)
	VSTA$K_LK201_CS_DP = 24;        (*SPANISH DATA PRO. (24)            *)
	VSTA$K_LK201_CM_TYP = 25;       (*SWEDISH TYPEWRITER(7)             *)
	VSTA$K_LK201_CM_DP = 26;        (*SWEDISH DATA PRO.(8)              *)
	VSTA$K_LK201_CB_TYP = 27;       (*FLEMISH TYPEWRITER(21)            *)
	VSTA$K_LK201_CB_DP = 28;        (*FLEMISH DATA PRO.(22)             *)
	VSTA$K_TT_MAX = 28;             (*MAX. VALID TRAN. TABLE OFFSET     *)
	VSTA$K_TT_UNENCODED = -1;       (*UNENCODED KEYBOARD FOR VKB        *)
 
(*                                                                          *)
(* NRC constants. This list is ORDER DEPENDENT. Any new NRCs must be added  *)
(* at the end (as the tables need be added to the ACP as well).             *)
(*                                                                          *)
 
CONST	VSTA$K_NRC_ASCII = 0;
	VSTA$K_NRC_UK = 1;
	VSTA$K_NRC_FRENCH = 2;
	VSTA$K_NRC_FRCAN = 3;
	VSTA$K_NRC_NORDAN = 4;
	VSTA$K_NRC_FINNISH = 5;
	VSTA$K_NRC_GERMAN = 6;
	VSTA$K_NRC_DUTCH = 7;
	VSTA$K_NRC_ITALIAN = 8;
	VSTA$K_NRC_SWISS = 9;
	VSTA$K_NRC_SWEDISH = 10;
	VSTA$K_NRC_SPANISH = 11;
	VSTA$K_NRC_MULTINATIONAL = 12;
 
(*                                                                          *)
 
CONST	VSTA$K_VKB_LEVEL_1 = 64;
	VSTA$K_VKB_LEVEL_2 = 128;
 
(*                                                                          *)
(* VIRTUAL KEYBOARD MODE BIT DEFINITIONS                                    *)
(* NOTE: THESE BITS MUST CORRESPOND TO THE BIT DEFINITIONS IN VSVKB.SDL FOR *)
(*	 KEYBOARD STATE WITH RESPECT TO ORDER AND PADDING.                  *)
(*                                                                          *)
 
CONST	VSTA$M_LEVEL = 960;
	VSTA$M_EIGHTBIT = 1024;
	VSTA$M_KEYPAD = 2048;
	VSTA$M_CURSOR_KEY = 4096;
	VSTA$M_VT52 = 8192;
	VSTA$M_NEW_LINE = 16384;
	VSTA$M_EXTRA = 32768;
	VSTA$K_BLOCK_SIZE = 2;          (*LENGTH OF DATA BLOCK              *)
 
TYPE	VKB_MODE_BITS = RECORD
	    VSTA$V_RESERVED : [POS(0)] $BIT6; (*RESERVED VKB STATE BITS     *)
	    VSTA$V_LEVEL : [POS(6)] $BIT4; (*VKB LEVEL 1/2 CONFORMANCE      *)
	    VSTA$V_EIGHTBIT : [POS(10)] $BOOL; (*VKB NATIVE EIGHT-BIT/SEVEN-BIT *)
	    VSTA$V_KEYPAD : [POS(11)] $BOOL; (*VKB KEYPAD APPLICATION MODE  *)
	    VSTA$V_CURSOR_KEY : [POS(12)] $BOOL; (*VKB CURSOR KEY MODE      *)
	    VSTA$V_VT52 : [POS(13)] $BOOL; (*VKB VT52 MODE                  *)
	    VSTA$V_NEW_LINE : [POS(14)] $BOOL; (*VKB NEW-LINE MODE          *)
	    VSTA$V_EXTRA : [POS(15)] $BOOL; (*FOR FUTURE DEC ABUSE          *)
	END;
 
(*                                                                          *)
(*                                                                          *)
(*                                                                          *)
(*  TEKTRONYX CHARACTERISTICS SYMBOLS                                       *)
(*                                                                          *)
(*                                                                          *)
 
CONST	VSTA$K_TEK4014_GT_STRAP = 96;
	VSTA$K_TEK4014_GT_CREOT = 96;
	VSTA$K_TEK4014_GT_CR = 64;
	VSTA$K_TEK4014_GT_NONE = 0;
	VSTA$K_TEK4014_AUTO_CR_STRAP = 128;
	VSTA$K_TEK4014_AUTO_CR_LF = 128;
	VSTA$K_TEK4014_NO_AUTO_CR_LF = 0;
	VSTA$K_TEK4014_AUTO_LF_STRAP = 256;
	VSTA$K_TEK4014_AUTO_LF_CR = 256;
	VSTA$K_TEK4014_NO_AUTO_LF_CR = 0;
	VSTA$K_TEK4014_DEL_LOY_STRAP = 512;
	VSTA$K_TEK4014_DEL_LOY = 512;
	VSTA$K_TEK4014_DEL_NOT_LOY = 0;
 
(*                                                                          *)
(*                                                                          *)
(*  DEFINE THE GLOBAL NATIVE GRAPHICS SYMBOLS NEXT                          *)
(*                                                                          *)
(*	                                                                    *)
 
CONST	VSTA$K_COPY_AREA = 0;
	VSTA$K_DRAW_CURVE = 1;
	VSTA$K_PRINT_TEXT = 2;
	VSTA$K_FILL_AREA = 3;
	VSTA$K_FLOOD_AREA = 4;
	VSTA$K_MOVE_TEXT = 5;
	VSTA$K_BACKGROUND = 6;
	VSTA$K_NOOP = 7;
	VSTA$K_MOVE_OBJECT = 8;
	VSTA$K_LOAD_CURSOR = 9;
	VSTA$K_GETRCS = 10;
	VSTA$K_LAST_OPCODE = 11;
	VSTA$K_OPCODE_TYPES = 10;
	VSTA$K_READ = 0;
	VSTA$K_WRITE = 1;
	VSTA$K_DEVICE_BITPLANES = 1;
	VSTA$K_NATIVE_GRAPHICS = 1;
	VSTA$K_SRC_CONST = 0;
	VSTA$K_SRC_BITMAP = 1;
	VSTA$K_SRC_VD = 2;
	VSTA$K_SRC_HT_BITMAP = 3;
	VSTA$K_SRC_HT_VD = 4;
	VSTA$K_SRC_FONT_BITMAP = 5;
	VSTA$K_SRC_DEFINED_FONT = 6;
	VSTA$K_SRC_PRIVATE_FONT = 7;
	VSTA$K_SRC_LAST_TYPE = 8;
	VSTA$K_SRC_TYPES = 7;
 
(*                                                                          *)
(* Define old symbol for source bitmap just so stale sources continue to    *)
(* compile.                                                                 *)
(*                                                                          *)
 
CONST	VSTA$K_SRC_BM = 1;
	VSTA$K_MSK_NONE = 0;
	VSTA$K_MSK_RECTANGLE = 1;
	VSTA$K_MSK_BITMAP = 2;
	VSTA$K_MSK_FONT_BITMAP = 3;
	VSTA$K_MSK_VD = 4;
	VSTA$K_MSK_DEFINED_FONT = 5;
	VSTA$K_MSK_PRIVATE_FONT = 6;
	VSTA$K_MSK_LAST_TYPE = 7;
	VSTA$K_MSK_TYPES = 6;
	VSTA$K_DST_BITMAP = 0;
	VSTA$K_DST_VD = 1;
	VSTA$K_DST_LAST_TYPE = 2;
	VSTA$K_DST_TYPES = 1;
	VSTA$K_DST_UPDATE = 0;
	VSTA$K_DST_NO_UPDATE = 1;
	VSTA$K_DST_LAST_UPD_TYPE = 2;
	VSTA$K_DST_UPD_TYPES = 1;
	VSTA$K_MAP_IDENTITY = 0;
	VSTA$K_MAP_S_LITERAL = 1;
	VSTA$K_MAP_SD_LITERAL = 2;
	VSTA$K_MAP_SOURCE = 3;
	VSTA$K_MAP_SOURCEDEST = 4;
	VSTA$K_MAP_LAST_TYPE = 5;
	VSTA$K_MAP_BLACK = 0;
	VSTA$K_MAP_SRC_AND_DST = 1;
	VSTA$K_MAP_SRC_AND_NOTDST = 2;
	VSTA$K_MAP_SRC = 3;
	VSTA$K_MAP_NOTSRC_AND_DST = 4;
	VSTA$K_MAP_DST = 5;
	VSTA$K_MAP_SRC_XOR_DST = 6;
	VSTA$K_MAP_SRC_OR_DST = 7;
	VSTA$K_MAP_NOTSRC_AND_NOTDST = 8;
	VSTA$K_MAP_NOT_SRCXORDST = 9;
	VSTA$K_MAP_NOTDST = 10;
	VSTA$K_MAP_SRC_OR_NOTDST = 11;
	VSTA$K_MAP_NOTSRC = 12;
	VSTA$K_MAP_NOTSRC_OR_DST = 13;
	VSTA$K_MAP_NOTSRC_OR_NOTDST = 14;
	VSTA$K_MAP_WHITE = 15;
	VSTA$K_MAP_TYPES = 4;
	VSTA$K_PTN_SINGLE_SRC = 0;
	VSTA$K_PTN_ALTERN_SRC = 1;
	VSTA$K_PTN_IDENT = 2;
	VSTA$K_PTN_LAST_TYPE = 3;
	VSTA$K_PTN_TYPES = 2;
	VSTA$K_PTN_UPDATE = 0;
	VSTA$K_PTN_NO_UPDATE = 1;
	VSTA$K_PTN_LAST_UPD_TYPE = 2;
	VSTA$K_PTN_UPD_TYPES = 1;
	VSTA$K_TXT_8BITS = 0;
	VSTA$K_TXT_16BITS = 1;
	VSTA$K_TXT_LAST_TYPE = 2;
	VSTA$K_TXT_TYPES = 1;
	VSTA$K_NO_EFN = 0;
	VSTA$K_NO_AST = 0;
	VSTA$K_NO_ASTPRM = 0;
 
(*                                                                          *)
(* MOUSE BUTTON MASKS                                                       *)
(*                                                                          *)
 
CONST	VSTA$K_LEFT_MOUSE_BUTTON = 4;
	VSTA$K_MIDDLE_MOUSE_BUTTON = 2;
	VSTA$K_RIGHT_MOUSE_BUTTON = 1;
	VSTA$K_SELECT_BUTTON = 4;
 
(*                                                                          *)
(* RESTRICTIONS ON SDA OBJECT DIMENSIONS                                    *)
(*                                                                          *)
 
CONST	VSTA$K_MAX_WINDOW_HEIGHT = 824; (*MAX. ALLOWED WINDOW HEIGHT        *)
	VSTA$K_MAX_WINDOW_WIDTH = 1064; (*MAX. ALLOWED WINDOW WIDTH         *)
	VSTA$K_MAX_SYS_WINDOW_HEIGHT = 864; (*MAX. ALLOWED WINDOW HEIGHT    *)
	VSTA$K_MAX_SYS_WINDOW_WIDTH = 1088; (*MAX. ALLOWED WINDOW WIDTH     *)
	VSTA$K_MAX_VD_AREA = 940032;    (*MAX. VD AREA (1088 X 864)         *)
 
(*                                                                          *)
(* SELECTABILITY ATTRIBUTES (PASSED TO VSTA$SET_REGION_SELECTABLE)          *)
(*                                                                          *)
 
CONST	VSTA$K_SEL_TEXT = 0;            (* APPROPRIATE FOR TEXT             *)
	VSTA$K_SEL_AREA = 1;            (* APPROPRIATE FOR SOLID AREAS      *)
	VSTA$K_SEL_REVERSE = 2;         (* REVERSE VIDEO                    *)
 
(*                                                                          *)
(* OEM-MODE VBDRIVER FUNCTION CODES AND MODIFIERS FOR APPLICATION PROGRAMS  *)
(*                                                                          *)
(* NOTE: THE CONSTANTS DEFINED BELOW MUST BE EQUIVALENT TO THOSE DEFINED    *)
(*	 IN THE VBDRIVER SYMBOL DEFINITION FILES (VSTADEF). ANY CHANGES     *)
(*	 MUST BE REFLECTED IN BOTH PLACES.                                  *)
(*                                                                          *)
 
CONST	IO$_VSTA_BUTTON = 23;           (*SAME AS IO$_VB_BUTTON             *)
	IO$M_VSTA_EXIT_IDLE = 128;      (*SAME AS IO$M_VB_EXIT_IDLE         *)
	IO$_VSTA_FIBER = 24;            (*SAME AS IO$_VB_FIBER              *)
	IO$M_VSTA_LINK_AST = 128;       (*SAME AS IO$M_VB_LINK_AST          *)
 
END.
