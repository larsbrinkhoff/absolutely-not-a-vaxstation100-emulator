#include <SDL.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <sys/select.h>
#include "vs100.h"
#include "event.h"

static struct termios saved_termios;
static FILE *output;

static void (*normal_table[]) (void);
static void (*altmode_table[]) (void);
static void (*double_altmode_table[]) (void);

#define NBKPT (8+1)
static int trace;
static int breakpoints[NBKPT+1];
static int prefix = -1;
static int infix = -1;
static int *accumulator = &prefix;
static int dot = 0;
static void (**dispatch) (void) = normal_table;
static void (*typeout) (u8 data);
static int radix = 16;
static int type, operand;
static int crlf;
static int clear;
static char ch;
static u16 pc;

static void altmode (void)
{
  dispatch = altmode_table;
  clear = 0;
}

static void double_altmode (void)
{
  dispatch = double_altmode_table;
  clear = 0;
}

static void breakpoint (void)
{
  int i;
  if (prefix == -1) {
    if (infix != -1)
      breakpoints[infix] = -1;
    return;
  }
  if (infix != -1) {
    breakpoints[infix] = prefix;
    return;
  }
  for (i = 1; i < NBKPT; i++) {
    if (breakpoints[i] == -1) {
      breakpoints[i] = prefix;
      return;
    }
  }
  fprintf (output, "TOO MANY PTS? ");
}

static void clear_breakpoints (void)
{
  int i;
  for (i = 0; i < NBKPT+1; i++)
    breakpoints[i] = -1;
}

static void number (void)
{
  if (ch >= '0' && ch <= '9')
    ch -= '0';
  else if (ch >= 'A' && ch <= 'F')
    ch += -'A' + 10;
  else
    ch += -'a' + 10;
  if (*accumulator == -1)
    *accumulator = ch;
  else
    *accumulator = 16 * *accumulator + ch;
  clear = 0;
}

static void symbolic (u8 data)
{
#if 0
  fprintf (output, "%s", dis[data].name);
  switch (type) {
  case 0: break;
  case 1: fprintf (output, "%02X", memory[operand]); break;
  case 2: fprintf (output, "%02X%02X", memory[operand+1], memory[operand]); break;
  }
#endif
  fprintf (output, "   ");
}

static void equals (void)
{
  int digit;
  if (prefix == -1)
    return;
  digit = prefix % radix;
  prefix /= radix;
  if (prefix > 0)
    equals ();
  fprintf (output, "%X", digit);
}

static void constant (u8 data)
{
#if 0
  prefix = memory[dot];
#endif
  equals ();
}

static void carriagereturn (void)
{
#if 0
  if (prefix != -1)
    memory[dot] = prefix;
#endif
}

static void slash (void)
{
  if (prefix != -1)
    dot = prefix;
  operand = dot + 1;
#if 0
  type = dis[memory[dot]].type;
  fprintf (output, "   ");
  typeout (memory[dot]);
#endif
  fprintf (output, "   ");
  crlf = 0;
}

static void linefeed (void)
{
  carriagereturn ();
#if 0
  if (typeout == symbolic)
    dot += dis[memory[dot]].type + 1;
  else
    dot++;
#endif
  prefix = dot;
  fprintf (output, "\r\n%04X/", prefix);
  slash ();
}

static void tab (void)
{
  carriagereturn ();
#if 0
  prefix = memory[dot + 1] | memory[dot + 2] << 8;
#endif
  fprintf (output, "\r\n%04X/", prefix);
  slash ();
}

static u16 previous (u16 addr)
{
#if 0
  if (dis[memory[addr - 3]].type == 2)
    return addr - 3;
  else if (dis[memory[addr - 2]].type == 1)
    return addr - 2;
  else
    return addr - 1;
#endif
}

static void caret (void)
{
  carriagereturn ();
  if (typeout == symbolic)
    dot = previous (dot);
  else
    dot--;
  prefix = dot;
  fprintf (output, "\r\n%04X/", prefix);
  slash ();
}

static void temporarily (void (*mode) (u8), void (*fn) (void))
{
  void (*saved) (u8) = typeout;
  typeout = mode;
  fn ();
  typeout = saved;
}

static void rbracket (void)
{
  temporarily (constant, slash);
}

static void lbracket (void)
{
  temporarily (symbolic, slash);
}

static void control_c (void)
{
  fputs ("\r\n", output);
}

static void control_g (void)
{
  fputs (" QUIT? ", output);
}

static void control_t (void)
{
  trace = !trace;
}

static void control_e (void)
{
  fprintf (output, "\r\n");
  print_events (output);
}

static int control_z (void)
{
  struct timeval tv;
  fd_set fds;
  FD_ZERO (&fds);
  FD_SET (fileno (stdin), &fds);
  tv.tv_sec = tv.tv_usec = 0;
  if (select (1, &fds, NULL, NULL, &tv) > 0) {
    int c = getchar ();
    if (c == 007 || c == 032) {
      fputs ("^Z\r\n", output);
      return 1;
    }
  }
  return 0;
}

static void stop (u16 addr)
{
  breakpoints[0] = addr;
#if 0
  jump (addr);
#endif
}

static void stopped (char *x)
{
  fprintf (output, "%04X%s", pc, x);
  operand = pc + 1;
  breakpoints[0] = -1;
#if 0
  type = dis[memory[pc]].type;
  symbolic (memory[pc]);
#endif
  crlf = 0;
}

static void step (void)
{
#if 0
  unsigned long long previous = get_cycles ();
  u8 insn = memory[pc];
  u16 start = pc;

  jump (pc);
  pc = execute ();
  events (get_cycles () - previous);
#endif
}

static void proceed (void)
{
  int n, i;

  fprintf (output, "\r\n");
  fflush (output);

  for (n = 1;; n++) {
    step ();
    for (i = 0; i < NBKPT+1; i++) {
      if (pc == breakpoints[i]) {
        if (i > 0)
          fprintf (output, "$%dB; ", i);
        stopped (">>");
        return;
      }
    }
    if (control_z ()) {
      stopped (")   ");
      return;
    }
  }
}

static void go (void)
{
#if 0
  if (prefix == -1)
    jump (pc = starta);
  else
    jump (pc = prefix);
#endif
  proceed ();
}

static void oneproceed (void)
{
  fprintf (output, "\r\n");
  fflush (output);
  step ();
  stopped (">>");
}

static void next (void)
{
#if 0
  breakpoints[NBKPT] = pc + 1 + dis[memory[pc]].type;
#endif
  proceed ();
  breakpoints[NBKPT] = -1;
}

static void rubout (void)
{
}

static void error (void)
{
  fprintf (output, " OP? ");
}

static char buffer[100];

static char *line (void)
{
  char *p = buffer;
  char c;

  for (;;) {
    c = getchar();
    if (c == 015)
      return buffer;
    *p++ = c;
    fputc (c, output);
  }
}

static void load (void)
{
  char *file;
  u16 offset = 0;
  FILE *f;

  fputc (' ', output);
  file = line ();
  f = fopen (file, "rb");
  if (f == NULL) {
    fprintf (output, "\r\n%s - file not found", file);
    return;
  }
  if (prefix != -1)
    offset = prefix;
#if 0
  if (dispatch == altmode_table)
    memset (memory, 0, 0x10000);
  if (fread (memory + offset, 1, 0x10000 - offset, f) <= 0)
    fprintf (output, "\r\n%s - error reading file", file);
  fclose (f);
  if (prefix == 0x100) {
    void bdos_out (u8 port, u8 data);
    register_port (0xFF, NULL, bdos_out);
    memory[0] = 0x76;
    memory[5] = 0xD3;
    memory[6] = 0xFF;
    memory[7] = 0xC9;
  }
#endif
}

static void dump (void)
{
  char *file;
  u16 offset = 0;
  FILE *f;

  fputc (' ', output);
  file = line ();
  f = fopen (file, "wb");
  if (f == NULL) {
    fprintf (output, "\r\n%s - error opening file\r\n", file);
    return;
  }
  if (prefix != -1)
    offset = prefix;
#if 0
  if (fwrite (memory + offset, 1, 0x10000 - offset, f) <= 0)
    fprintf (output, "\r\n%s - error writing file\r\n", file);
#endif
  fclose (f);
}

static void zero (void)
{
  u16 offset = 0;
  if (prefix != -1)
    offset = prefix;
#if 0
  memset (memory, offset, 0x10000 - offset);
#endif
}

static void login (void)
{
  fprintf (output, "Welcome!\r\n");
}

static void logout (void)
{
  tcsetattr (fileno (stdin), TCSAFLUSH, &saved_termios);
  fprintf (output, "\r\n");
  exit (0);
}

static void period (void)
{
  prefix = dot;
  clear = 0;
}

static void altmode_period (void)
{
  prefix = pc;
  clear = 0;
}

static void altmode_s (void)
{
  typeout = symbolic;
}

static void altmode_c (void)
{
  typeout = constant;
}

static void altmode_d (void)
{
  radix = 10;
  typeout = constant;
}

static void altmode_o (void)
{
  radix = 8;
  typeout = constant;
}

static void altmode_h (void)
{
  radix = 16;
  typeout = constant;
}

static void space (void)
{
}

static void listj (void)
{
  fprintf (output, "* CPU\r\n");
  fprintf (output, "  BBA\r\n");
  fprintf (output, "  KBD\r\n");
}

static void colon (void)
{
#if 0
  char *command = line ();
  if (strncasecmp (command, "cortyp", 6) == 0)
    cortyp (command + 6);
  else if (strncasecmp (command, "corprt", 6) == 0)
    corprt ();
  else if (strncasecmp (command, "corblk", 6) == 0)
    corblk (command + 6);
#endif
}

static void (*normal_table[]) (void) = {
  error,                  //^@
  error,                  //^A
  error,                  //^B
  control_c,              //^C
  error,                  //^D
  control_e,              //^E
  error,                  //^F
  control_g,              //^G
  error,                  //^H
  tab,                    //^I
  linefeed,               //^J
  error,
  //control_k,              //^K
  error,                  //^L
  carriagereturn,         //^M
  oneproceed,             //^N
  error,                  //^O
  error,                  //^P
  error,                  //^Q
  error,                  //^R
  error,                  //^S
  control_t,              //^T
  error,                  //^U
  error,                  //^V
  error,                  //^W
  error,                  //^X
  error,                  //^Y
  error,                  //^Z
  altmode,                //^[
  error,                  //control-backslash
  error,                  //^]
  error,                  //^^
  error,                  //^_
  space,                  // 
  error,                  //!
  error,                  //"
  error,                  //#
  error,                  //$
  error,                  //%
  error,                  //&
  error,                  //'
  error,                  //(
  error,                  //)
  error,                  //*
  error,                  //+
  error,                  //,
  error,                  //-
  period,                 //.
  slash,                  ///
  number,                 //0
  number,                 //1
  number,                 //2
  number,                 //3
  number,                 //4
  number,                 //5
  number,                 //6
  number,                 //7
  number,                 //8
  number,                 //9
  colon,                  //:
  error,                  //;
  error,                  //<
  equals,                 //=
  error,                  //>
  error,                  //?
  error,                  //@
  number,                 //A
  number,                 //B
  number,                 //C
  number,                 //D
  number,                 //E
  number,                 //F
  error,                  //G
  error,                  //H
  error,                  //I
  error,                  //J
  error,                  //K
  error,                  //L
  error,                  //M
  error,                  //N
  error,                  //O
  error,                  //P
  error,                  //Q
  error,                  //R
  error,                  //S
  error,                  //T
  error,                  //U
  error,                  //V
  error,                  //W
  error,                  //X
  error,                  //Y
  error,                  //Z
  rbracket,               //[
  error,                  //backslash
  lbracket,               //]
  caret,                  //^
  error,                  //_
  error,                  //`
  number,                 //a
  number,                 //b
  number,                 //c
  number,                 //d
  number,                 //e
  number,                 //f
  error,                  //g
  error,                  //h
  error,                  //i
  error,                  //j
  error,                  //k
  error,                  //l
  error,                  //m
  error,                  //n
  error,                  //o
  error,                  //p
  error,                  //q
  error,                  //r
  error,                  //s
  error,                  //t
  error,                  //u
  error,                  //v
  error,                  //w
  error,                  //x
  error,                  //y
  error,                  //z
  error,                  //{
  error,                  //|
  error,                  //}
  error,                  //~
  rubout,                 //^?
};

static void (*altmode_table[]) (void) = {
  error,                  //^@
  error,                  //^A
  error,                  //^B
  error,                  //^C
  error,                  //^D
  error,                  //^E
  error,                  //^F
  error,                  //^G
  error,                  //^H
  error,                  //^I
  error,                  //^J
  error,                  //^K
  error,                  //^L
  error,                  //^M
  next,                   //^N
  error,                  //^O
  error,                  //^P
  error,                  //^Q
  error,                  //^R
  error,                  //^S
  error,                  //^T
  error,                  //^U
  error,                  //^V
  error,                  //^W
  error,                  //^X
  error,                  //^Y
  error,                  //^Z
  double_altmode,         //^[
  error,                  //control-backslash
  error,                  //^]
  error,                  //^^
  error,                  //^_
  error,                  // 
  error,                  //!
  error,                  //"
  error,                  //#
  error,                  //$
  error,                  //%
  error,                  //&
  error,                  //'
  error,                  //(
  error,                  //)
  error,                  //*
  error,                  //+
  error,                  //,
  error,                  //-
  altmode_period,         //.
  error,                  ///
  error,                  //0
  error,                  //1
  error,                  //2
  error,                  //3
  error,                  //4
  error,                  //5
  error,                  //6
  error,                  //7
  error,                  //8
  error,                  //9
  error,                  //:
  error,                  //;
  error,                  //<
  error,                  //=
  error,                  //>
  error,                  //?
  error,                  //@
  error,                  //A
  breakpoint,             //B
  altmode_c,              //C
  altmode_d,              //D
  error,                  //E
  error,                  //F
  go,                     //G
  altmode_h,              //H
  error,                  //I
  error,                  //J
  error,                  //K
  load,                   //L
  error,                  //M
  error,                  //N
  altmode_o,              //O
  proceed,                //P
  error,                  //Q
  error,                  //R
  altmode_s,              //S
  error,                  //T
  login,                  //U
  error,                  //V
  error,                  //W
  error,                  //X
  dump,                   //Y
  error,                  //Z
  error,                  //[
  error,                  //backslash
  error,                  //]
  error,                  //^
  error,                  //_
  error,                  //`
  error,                  //a
  breakpoint,             //b
  altmode_c,              //c
  altmode_d,              //d
  error,                  //e
  error,                  //f
  go,                     //g
  altmode_h,              //h
  error,                  //i
  error,                  //j
  error,                  //k
  load,                   //L
  error,                  //m
  error,                  //n
  altmode_o,              //o
  proceed,                //p
  error,                  //q
  error,                  //r
  altmode_s,              //s
  error,                  //t
  login,                  //u
  error,                  //v
  error,                  //w
  error,                  //x
  dump,                   //y
  error,                  //z
  error,                  //{
  error,                  //|
  error,                  //}
  error,                  //~
  error,                  //^?
};

static void (*double_altmode_table[]) (void) = {
  error,                  //^@
  error,                  //^A
  error,                  //^B
  error,                  //^C
  error,                  //^D
  error,                  //^E
  error,                  //^F
  error,                  //^G
  error,                  //^H
  error,                  //^I
  error,                  //^J
  error,                  //^K
  error,                  //^L
  error,                  //^M
  error,                  //^N
  error,                  //^O
  error,                  //^P
  error,                  //^Q
  error,                  //^R
  error,                  //^S
  error,                  //^T
  error,                  //^U
  error,                  //^V
  error,                  //^W
  error,                  //^X
  error,                  //^Y
  error,                  //^Z
  error,                  //^[
  error,                  //control-backslash
  error,                  //^]
  error,                  //^^
  error,                  //^_
  error,                  // 
  error,                  //!
  error,                  //"
  error,                  //#
  error,                  //$
  error,                  //%
  error,                  //&
  error,                  //'
  error,                  //(
  error,                  //)
  error,                  //*
  error,                  //+
  error,                  //,
  error,                  //-
  error,                  //.
  error,                  ///
  error,                  //0
  error,                  //1
  error,                  //2
  error,                  //3
  error,                  //4
  error,                  //5
  error,                  //6
  error,                  //7
  error,                  //8
  error,                  //9
  error,                  //:
  error,                  //;
  error,                  //<
  error,                  //=
  error,                  //>
  error,                  //?
  error,                  //@
  error,                  //A
  clear_breakpoints,      //B
  error,                  //C
  error,                  //D
  error,                  //E
  error,                  //F
  error,                  //G
  error,                  //H
  error,                  //I
  error,                  //J
  error,                  //K
  load,                   //L
  error,                  //M
  error,                  //N
  error,                  //O
  error,                  //P
  error,                  //Q
  error,                  //R
  error,                  //S
  error,                  //T
  logout,                 //U
  listj,                  //V
  error,                  //W
  error,                  //X
  dump,                   //Y
  zero,                   //Z
  error,                  //[
  error,                  //backslash
  error,                  //]
  error,                  //^
  error,                  //_
  error,                  //`
  error,                  //a
  clear_breakpoints,      //b
  error,                  //c
  error,                  //d
  error,                  //e
  error,                  //f
  error,                  //g
  error,                  //h
  error,                  //i
  error,                  //j
  error,                  //k
  load,                   //l
  error,                  //m
  error,                  //n
  error,                  //o
  error,                  //p
  error,                  //q
  error,                  //r
  error,                  //s
  error,                  //t
  logout,                 //u
  listj,                  //v
  error,                  //w
  error,                  //x
  dump,                   //y
  zero,                   //z
  error,                  //{
  error,                  //|
  error,                  //}
  error,                  //~
  error,                  //^?
};

static void cbreak (void)
{
  struct termios t;

  if (tcgetattr (fileno (stdin), &t) == -1)
    return;

  saved_termios = t;
  t.c_lflag &= ~(ICANON | ECHO);
  t.c_lflag |= ISIG;
  t.c_iflag &= ~ICRNL;
  t.c_cc[VMIN] = 1;
  t.c_cc[VTIME] = 0;

  atexit (logout);

  if (tcsetattr (fileno (stdin), TCSAFLUSH, &t) == -1)
    return;
}

static void echo (char c)
{
  if (c == 015)
    ;
  else if (c == 033)
    fprintf (output, "$");
  else if (c < 32)
    fprintf (output, "^%c", c + '@');
  else if (c == 0177)
    fprintf (output, "^?");
  else
    fprintf (output, "%c", c);
  fflush (output);
}

static void key (char c)
{
  void (**before) (void) = dispatch;
  if (c & -128)
    return;
  echo (c);
  clear = 1;
  crlf = 1;
  ch = c;
  dispatch[(int)c] ();
  if (dispatch == before)
    dispatch = normal_table;
  if (clear) {
    prefix = -1;
    infix = -1;
    accumulator = &prefix;
    if (crlf)
      fprintf (output, "\r\n");
  }
  fflush (output);
}

static int thread (void *arg)
{
  for (;;)
    key (getchar ());
  return 0;
}

void ddt (void)
{
  output = stdout;
  cbreak ();
  trace = 0;
  //halt = stop;
  typeout = symbolic;
  radix = 16;
  prefix = infix = -1;
  clear_breakpoints ();
  SDL_CreateThread (thread, "VS100: DDT", NULL);
}
