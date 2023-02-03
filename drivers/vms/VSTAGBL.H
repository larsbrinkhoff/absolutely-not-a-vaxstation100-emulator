 
/*** MODULE $VSTAGBL ***/
/*                                                                          */
/*++                                                                        */
/* FACILITY:                                                                */
/*   VAX WORKSTATIONS                                                       */
/*                                                                          */
/* ABSTRACT:                                                                */
/*                                                                          */
/*  This file contains the predefined symbols given in the manual for the   */
/*  VAXstation Programmer's Library. Only those symbols which do NOT define */
/*  VSTA error message symbols are defined here.                            */
/*                                                                          */
/* ENVIRONMENT:                                                             */
/*   VAX workstation: 780, 750, 730 running VMS with at least one VAXstation */
/*   graphics subsystem.                                                    */
/*                                                                          */
/*                                                                          */
/* RENDITION SYMBOLS                                                        */
/*                                                                          */
#define VSTA$M_REND_BOLD 1
#define VSTA$M_REND_ITALICS 2
#define VSTA$M_REND_UNDERSCORE 4
#define VSTA$M_REND_BLINK 8
#define VSTA$M_REND_REVERSE 16
#define VSTA$M_REND_EXTRA 224
#define VSTA$K_REND_BLOCK_SIZE 1        /*LENGTH OF DATA BLOCK              */
struct REND_BITS {
    unsigned VSTA$V_REND_BOLD : 1;      /*BOLD RENDITION                    */
    unsigned VSTA$V_REND_ITALICS : 1;   /*ITALICS RENDITION                 */
    unsigned VSTA$V_REND_UNDERSCORE : 1; /*UNDERSCORE RENDITION             */
    unsigned VSTA$V_REND_BLINK : 1;     /*BLINK RENDITION                   */
    unsigned VSTA$V_REND_REVERSE : 1;   /*REVERSE VIDEO RENDITION           */
    unsigned VSTA$V_REND_EXTRA : 3;     /*FOR FUTURE DEC ABUSE              */
    } ;
/*                                                                          */
#define VSTA$K_NONE -1                  /* MEASURE TEXT SPECIAL             */
/*                                                                          */
/* FIELD FORMATS                                                            */
/*                                                                          */
#define VSTA$K_FF_LEFT 0
#define VSTA$K_FF_RIGHT 1
#define VSTA$K_FF_CENTER 2
/*                                                                          */
/* SDA OBJECT PROTECTION                                                    */
/*                                                                          */
#define VSTA$K_UNPROTECTED -1
#define VSTA$K_DEFAULT_PROTECTION 65295
/*                                                                          */
/* VIRTUAL KEYBOARD TRANSLATION TABLE IDS AND TIA CONFORMANCE LEVELS        */
/*                                                                          */
/* NOTE: MAKE SURE THE CONSTANT BELOW REFLECTS THE MAXIMUM VALID TRANSLATION */
/*       TABLE NUMBER WHEN ADDING TRANSLATION TABLES. OTHERWISE, YOUR NEW   */
/*	 TABLE WILL BE IGNORED. TABLES THAT END IN _TYP ARE TYPEWRITER      */
/*	 TRANSLATION TABLES AND TABLES THAT END IN _DP ARE DATA PROCESSING  */
/*	 TRANSLATON TABLES. THE NAMES OF THE TABLES CORRESPOND TO THE       */
/*	 HARDWARE KEYBOARD OF THAT LANGUAGE.                                */
/*                                                                          */
/* NOTE: TABLES 	1.)LK201-CB = LK201-CP                              */
/*			2.)LK201-CM = LK201-CF                              */
/*                                                                          */
#define VSTA$K_TT_DECMS_ENGLISH 0       /*DEC MULTINATIONAL ENGLISH         */
#define VSTA$K_LK201_CA 0               /*DEC MULTINATIONAL ENGLISH(0)      */
#define VSTA$K_LK201_CC_TYP 1           /*CANADIAN (FRENCH) TYPEWRITER(1)   */
#define VSTA$K_LK201_CC_DP 2            /*CANADIAN (FRENCH) DATA PRO.(2)    */
#define VSTA$K_LK201_CD_TYP 3           /*DANISH TYPEWRITER(3)              */
#define VSTA$K_LK201_CD_DP 4            /*DANISH DATA PRO.(4)               */
#define VSTA$K_LK201_CE_TYP 5           /*BRITISH TYPEWRITER(5)             */
#define VSTA$K_LK201_CE_DP 6            /*BRITISH DATA PRO.(6)              */
#define VSTA$K_LK201_CF_TYP 7           /*FINNISH TYPEWRITER(7)             */
#define VSTA$K_LK201_CF_DP 8            /*FINNISH DATA PRO.(8)              */
#define VSTA$K_LK201_CG_TYP 9           /*GERMAN/AUSTRIAN TYPEWRITER(9)     */
#define VSTA$K_LK201_CG_DP 10           /*GERMAN/AUSTRIAN DATA PRO.(10)     */
#define VSTA$K_LK201_CH_TYP 11          /*DUTCH TYPEWRITER(11)              */
#define VSTA$K_LK201_CH_DP 12           /*DUTCH DATA PRO.(12)               */
#define VSTA$K_LK201_CI_TYP 13          /*ITALIAN TYPEWRITER(13)            */
#define VSTA$K_LK201_CI_DP 14           /*ITALIAN DATA PRO.(14)             */
#define VSTA$K_LK201_CK_TYP 15          /*FRENCH/SWISS TYPEWRITER(15)       */
#define VSTA$K_LK201_CK_DP 16           /*FRENCH/SWISS DATA PRO.(16)        */
#define VSTA$K_LK201_CL_TYP 17          /*GERMAN/SWISS TYPEWRITER(17)       */
#define VSTA$K_LK201_CL_DP 18           /*GERMAN/SWISS DATA PRO.(18)        */
#define VSTA$K_LK201_CN_TYP 19          /*NORWEGIAN TYPEWRITER(19)          */
#define VSTA$K_LK201_CN_DP 20           /*NORWEGIAN DATA PRO.(20)           */
#define VSTA$K_LK201_CP_TYP 21          /*FRENCH/BELGIUM TYPEWRITER(21)     */
#define VSTA$K_LK201_CP_DP 22           /*FRENCH/BELGIUM DATA PRO.(22)      */
#define VSTA$K_LK201_CS_TYP 23          /*SPANISH TYPEWRITER(23)            */
#define VSTA$K_LK201_CS_DP 24           /*SPANISH DATA PRO. (24)            */
#define VSTA$K_LK201_CM_TYP 25          /*SWEDISH TYPEWRITER(7)             */
#define VSTA$K_LK201_CM_DP 26           /*SWEDISH DATA PRO.(8)              */
#define VSTA$K_LK201_CB_TYP 27          /*FLEMISH TYPEWRITER(21)            */
#define VSTA$K_LK201_CB_DP 28           /*FLEMISH DATA PRO.(22)             */
#define VSTA$K_TT_MAX 28                /*MAX. VALID TRAN. TABLE OFFSET     */
#define VSTA$K_TT_UNENCODED -1          /*UNENCODED KEYBOARD FOR VKB        */
/*                                                                          */
/* NRC constants. This list is ORDER DEPENDENT. Any new NRCs must be added  */
/* at the end (as the tables need be added to the ACP as well).             */
/*                                                                          */
#define VSTA$K_NRC_ASCII 0
#define VSTA$K_NRC_UK 1
#define VSTA$K_NRC_FRENCH 2
#define VSTA$K_NRC_FRCAN 3
#define VSTA$K_NRC_NORDAN 4
#define VSTA$K_NRC_FINNISH 5
#define VSTA$K_NRC_GERMAN 6
#define VSTA$K_NRC_DUTCH 7
#define VSTA$K_NRC_ITALIAN 8
#define VSTA$K_NRC_SWISS 9
#define VSTA$K_NRC_SWEDISH 10
#define VSTA$K_NRC_SPANISH 11
#define VSTA$K_NRC_MULTINATIONAL 12
/*                                                                          */
#define VSTA$K_VKB_LEVEL_1 64
#define VSTA$K_VKB_LEVEL_2 128
/*                                                                          */
/* VIRTUAL KEYBOARD MODE BIT DEFINITIONS                                    */
/* NOTE: THESE BITS MUST CORRESPOND TO THE BIT DEFINITIONS IN VSVKB.SDL FOR */
/*	 KEYBOARD STATE WITH RESPECT TO ORDER AND PADDING.                  */
/*                                                                          */
#define VSTA$M_LEVEL 960
#define VSTA$M_EIGHTBIT 1024
#define VSTA$M_KEYPAD 2048
#define VSTA$M_CURSOR_KEY 4096
#define VSTA$M_VT52 8192
#define VSTA$M_NEW_LINE 16384
#define VSTA$M_EXTRA 32768
#define VSTA$K_BLOCK_SIZE 2             /*LENGTH OF DATA BLOCK              */
struct VKB_MODE_BITS {
    unsigned VSTA$V_RESERVED : 6;       /*RESERVED VKB STATE BITS           */
    unsigned VSTA$V_LEVEL : 4;          /*VKB LEVEL 1/2 CONFORMANCE         */
    unsigned VSTA$V_EIGHTBIT : 1;       /*VKB NATIVE EIGHT-BIT/SEVEN-BIT    */
    unsigned VSTA$V_KEYPAD : 1;         /*VKB KEYPAD APPLICATION MODE       */
    unsigned VSTA$V_CURSOR_KEY : 1;     /*VKB CURSOR KEY MODE               */
    unsigned VSTA$V_VT52 : 1;           /*VKB VT52 MODE                     */
    unsigned VSTA$V_NEW_LINE : 1;       /*VKB NEW-LINE MODE                 */
    unsigned VSTA$V_EXTRA : 1;          /*FOR FUTURE DEC ABUSE              */
    } ;
/*                                                                          */
/*                                                                          */
/*                                                                          */
/*  TEKTRONYX CHARACTERISTICS SYMBOLS                                       */
/*                                                                          */
/*                                                                          */
#define VSTA$K_TEK4014_GT_STRAP 96
#define VSTA$K_TEK4014_GT_CREOT 96
#define VSTA$K_TEK4014_GT_CR 64
#define VSTA$K_TEK4014_GT_NONE 0
#define VSTA$K_TEK4014_AUTO_CR_STRAP 128
#define VSTA$K_TEK4014_AUTO_CR_LF 128
#define VSTA$K_TEK4014_NO_AUTO_CR_LF 0
#define VSTA$K_TEK4014_AUTO_LF_STRAP 256
#define VSTA$K_TEK4014_AUTO_LF_CR 256
#define VSTA$K_TEK4014_NO_AUTO_LF_CR 0
#define VSTA$K_TEK4014_DEL_LOY_STRAP 512
#define VSTA$K_TEK4014_DEL_LOY 512
#define VSTA$K_TEK4014_DEL_NOT_LOY 0
/*                                                                          */
/*                                                                          */
/*  DEFINE THE GLOBAL NATIVE GRAPHICS SYMBOLS NEXT                          */
/*                                                                          */
/*	                                                                    */
#define VSTA$K_COPY_AREA 0
#define VSTA$K_DRAW_CURVE 1
#define VSTA$K_PRINT_TEXT 2
#define VSTA$K_FILL_AREA 3
#define VSTA$K_FLOOD_AREA 4
#define VSTA$K_MOVE_TEXT 5
#define VSTA$K_BACKGROUND 6
#define VSTA$K_NOOP 7
#define VSTA$K_MOVE_OBJECT 8
#define VSTA$K_LOAD_CURSOR 9
#define VSTA$K_GETRCS 10
#define VSTA$K_LAST_OPCODE 11
#define VSTA$K_OPCODE_TYPES 10
#define VSTA$K_READ 0
#define VSTA$K_WRITE 1
#define VSTA$K_DEVICE_BITPLANES 1
#define VSTA$K_NATIVE_GRAPHICS 1
#define VSTA$K_SRC_CONST 0
#define VSTA$K_SRC_BITMAP 1
#define VSTA$K_SRC_VD 2
#define VSTA$K_SRC_HT_BITMAP 3
#define VSTA$K_SRC_HT_VD 4
#define VSTA$K_SRC_FONT_BITMAP 5
#define VSTA$K_SRC_DEFINED_FONT 6
#define VSTA$K_SRC_PRIVATE_FONT 7
#define VSTA$K_SRC_LAST_TYPE 8
#define VSTA$K_SRC_TYPES 7
/*                                                                          */
/* Define old symbol for source bitmap just so stale sources continue to    */
/* compile.                                                                 */
/*                                                                          */
#define VSTA$K_SRC_BM 1
#define VSTA$K_MSK_NONE 0
#define VSTA$K_MSK_RECTANGLE 1
#define VSTA$K_MSK_BITMAP 2
#define VSTA$K_MSK_FONT_BITMAP 3
#define VSTA$K_MSK_VD 4
#define VSTA$K_MSK_DEFINED_FONT 5
#define VSTA$K_MSK_PRIVATE_FONT 6
#define VSTA$K_MSK_LAST_TYPE 7
#define VSTA$K_MSK_TYPES 6
#define VSTA$K_DST_BITMAP 0
#define VSTA$K_DST_VD 1
#define VSTA$K_DST_LAST_TYPE 2
#define VSTA$K_DST_TYPES 1
#define VSTA$K_DST_UPDATE 0
#define VSTA$K_DST_NO_UPDATE 1
#define VSTA$K_DST_LAST_UPD_TYPE 2
#define VSTA$K_DST_UPD_TYPES 1
#define VSTA$K_MAP_IDENTITY 0
#define VSTA$K_MAP_S_LITERAL 1
#define VSTA$K_MAP_SD_LITERAL 2
#define VSTA$K_MAP_SOURCE 3
#define VSTA$K_MAP_SOURCEDEST 4
#define VSTA$K_MAP_LAST_TYPE 5
#define VSTA$K_MAP_BLACK 0
#define VSTA$K_MAP_SRC_AND_DST 1
#define VSTA$K_MAP_SRC_AND_NOTDST 2
#define VSTA$K_MAP_SRC 3
#define VSTA$K_MAP_NOTSRC_AND_DST 4
#define VSTA$K_MAP_DST 5
#define VSTA$K_MAP_SRC_XOR_DST 6
#define VSTA$K_MAP_SRC_OR_DST 7
#define VSTA$K_MAP_NOTSRC_AND_NOTDST 8
#define VSTA$K_MAP_NOT_SRCXORDST 9
#define VSTA$K_MAP_NOTDST 10
#define VSTA$K_MAP_SRC_OR_NOTDST 11
#define VSTA$K_MAP_NOTSRC 12
#define VSTA$K_MAP_NOTSRC_OR_DST 13
#define VSTA$K_MAP_NOTSRC_OR_NOTDST 14
#define VSTA$K_MAP_WHITE 15
#define VSTA$K_MAP_TYPES 4
#define VSTA$K_PTN_SINGLE_SRC 0
#define VSTA$K_PTN_ALTERN_SRC 1
#define VSTA$K_PTN_IDENT 2
#define VSTA$K_PTN_LAST_TYPE 3
#define VSTA$K_PTN_TYPES 2
#define VSTA$K_PTN_UPDATE 0
#define VSTA$K_PTN_NO_UPDATE 1
#define VSTA$K_PTN_LAST_UPD_TYPE 2
#define VSTA$K_PTN_UPD_TYPES 1
#define VSTA$K_TXT_8BITS 0
#define VSTA$K_TXT_16BITS 1
#define VSTA$K_TXT_LAST_TYPE 2
#define VSTA$K_TXT_TYPES 1
#define VSTA$K_NO_EFN 0
#define VSTA$K_NO_AST 0
#define VSTA$K_NO_ASTPRM 0
/*                                                                          */
/* MOUSE BUTTON MASKS                                                       */
/*                                                                          */
#define VSTA$K_LEFT_MOUSE_BUTTON 4
#define VSTA$K_MIDDLE_MOUSE_BUTTON 2
#define VSTA$K_RIGHT_MOUSE_BUTTON 1
#define VSTA$K_SELECT_BUTTON 4
/*                                                                          */
/* RESTRICTIONS ON SDA OBJECT DIMENSIONS                                    */
/*                                                                          */
#define VSTA$K_MAX_WINDOW_HEIGHT 824    /*MAX. ALLOWED WINDOW HEIGHT        */
#define VSTA$K_MAX_WINDOW_WIDTH 1064    /*MAX. ALLOWED WINDOW WIDTH         */
#define VSTA$K_MAX_SYS_WINDOW_HEIGHT 864 /*MAX. ALLOWED WINDOW HEIGHT       */
#define VSTA$K_MAX_SYS_WINDOW_WIDTH 1088 /*MAX. ALLOWED WINDOW WIDTH        */
#define VSTA$K_MAX_VD_AREA 940032       /*MAX. VD AREA (1088 X 864)         */
/*                                                                          */
/* SELECTABILITY ATTRIBUTES (PASSED TO VSTA$SET_REGION_SELECTABLE)          */
/*                                                                          */
#define VSTA$K_SEL_TEXT 0               /* APPROPRIATE FOR TEXT             */
#define VSTA$K_SEL_AREA 1               /* APPROPRIATE FOR SOLID AREAS      */
#define VSTA$K_SEL_REVERSE 2            /* REVERSE VIDEO                    */
/*                                                                          */
/* OEM-MODE VBDRIVER FUNCTION CODES AND MODIFIERS FOR APPLICATION PROGRAMS  */
/*                                                                          */
/* NOTE: THE CONSTANTS DEFINED BELOW MUST BE EQUIVALENT TO THOSE DEFINED    */
/*	 IN THE VBDRIVER SYMBOL DEFINITION FILES (VSTADEF). ANY CHANGES     */
/*	 MUST BE REFLECTED IN BOTH PLACES.                                  */
/*                                                                          */
#define IO$_VSTA_BUTTON 23              /*SAME AS IO$_VB_BUTTON             */
#define IO$M_VSTA_EXIT_IDLE 128         /*SAME AS IO$M_VB_EXIT_IDLE         */
#define IO$_VSTA_FIBER 24               /*SAME AS IO$_VB_FIBER              */
#define IO$M_VSTA_LINK_AST 128          /*SAME AS IO$M_VB_LINK_AST          */
