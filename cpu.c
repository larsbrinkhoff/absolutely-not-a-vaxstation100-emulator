#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include "common/event.h"
#include "common/xsdl.h"
#include "common/opengl.h"
#include "vs100.h"

#define ROM_ADDR 0x180000

#define ADD 001
#define ADC 002
#define SUB 003
#define IOR 004
#define AND 005
#define EOR 006
#define LSL 007
#define ROL 010
#define LSR 011
#define ASR 012
#define ROR 013

#define SR_C      0x0001
#define SR_V      0x0002
#define SR_Z      0x0004
#define SR_N      0x0008
#define SR_X      0x0010
#define SR_S      0x2000
#define SR_T      0x4000
#define FLAG_C    (SR & SR_C)
#define FLAG_V    (SR & SR_V)
#define FLAG_Z    (SR & SR_Z)
#define FLAG_N    (SR & SR_N)
#define FLAG_X    (SR & SR_X)
#define SET_C(F)  if(F) SR |= SR_C; else SR &= ~SR_C
#define SET_V(F)  if(F) SR |= SR_V; else SR &= ~SR_V
#define SET_Z(F)  if(F) SR |= SR_Z; else SR &= ~SR_Z
#define SET_N(F)  if(F) SR |= SR_N; else SR &= ~SR_N
#define SET_X(F)  if(F) SR |= SR_X; else SR &= ~SR_X

#define EXTB(X) ((((u32)(X & 0xFF)) ^ 0x80) - 0x80)
#define EXTW(X) ((((u32)(X & 0xFFFF)) ^ 0x8000) - 0x8000)

#define EA_FIELD   (IRD & 077)
#define EA_R_FIELD (IRD & 7)
#define EA_M_FIELD ((IRD >> 3) & 7)
#define REG_FIELD  ((IRD >> 9) & 7)
#define CC_FIELD   ((IRD >> 8) & 0xE)
#define DREG       dreg[REG_FIELD]
#define AREG       areg[REG_FIELD]
// REG ((IR >> 12) & 7)
// A/D (IR & 0x8000) ? areg[r] : dreg[r];


static u32 trace_pc[10000];
static u32 trace_i = 0;
static int trace_p = 0;
#define TRACE()						\
  do {							\
    trace_pc[trace_i++] = PC-4;				\
    trace_i %= 10000;					\
    if (trace_p)					\
      fprintf(stderr, "TRACE: %06X %04X/%06o %s\n",	\
	      PC-4, IRD, IRD, __func__);		\
  } while(0)

#define UNIMPLEMENTED()						\
  printf("Unimplemented: %s @ %06X.\n", __func__, PC-4);	\
  exit(1)

#define DEFINSN_BW(INSN)			\
  static void insn_##INSN##b(void) {		\
    TRACE();					\
    insn_##INSN(&size_b);			\
  }						\
  static void insn_##INSN##w(void) {		\
    TRACE();					\
    insn_##INSN(&size_w);			\
  }

#define DEFINSN_WL(INSN)			\
  static void insn_##INSN##w(void) {		\
    TRACE();					\
    insn_##INSN(&size_w);			\
  }						\
  static void insn_##INSN##l(void) {		\
    TRACE();					\
    insn_##INSN(&size_l);			\
  }

#define DEFINSN_BWL(INSN)			\
  static void insn_##INSN##b(void) {		\
    TRACE();					\
    insn_##INSN(&size_b);			\
  }						\
  DEFINSN_WL(INSN)

typedef void (*insn_fn)(void);
typedef u8 (*mem_read_b_fn)(u32);
typedef void (*mem_write_b_fn)(u32, u8);
typedef u16 (*mem_read_w_fn)(u32);
typedef void (*mem_write_w_fn)(u32, u16);

static unsigned long long cycles = 0;

static u32 PC;
#define SP areg[7]
static u16 IRC, IR, IRD;
static u16 SR;
static u32 dreg[8];
static u32 areg[8];
static u32 mem_addr;
static u16 mem_data;
static int ipl;
static int vec;
static jmp_buf ex;

static mem_read_b_fn read_b[1024];
static mem_write_b_fn write_b[1024];
static mem_read_w_fn read_w[1024];
static mem_write_w_fn write_w[1024];
//static u8 ram[128*1024];
static u8 ram[16*1024*1024];
static u8 rom[16*1024];
static u32 retry_finite_counter = 0;
static u32 retry_infinite_counter = 0;

static u8 mc6845_addr;
static u8 mc6845_reg[18];

SDL_mutex *event_mutex;
SDL_mutex *ipl_mutex;

static void insn_illegal(void);

struct s {
  int opsize;
  const char *suffix;
  u32 mask, sign;
  u32 (*read_ea)(void);
  u32 (*read_imm)(void);
  void (*modify_ea)(u32);
  void (*write_ea)(u32);
  u32 (*alu)(int, u32, u32);
};

static void add_cycles(int n) {
  cycles += n;
}

static void mem_region(u32 address, u32 size,
		       mem_read_b_fn rb, mem_write_b_fn wb,
		       mem_read_w_fn rw, mem_write_w_fn ww) {
  int i;
  address >>= 14;
  size += (1 << 14) - 1;
  size >>= 14;
  for (i = 0; i < size; i++) {
    read_b[address + i] = rb;
    write_b[address + i] = wb;
    read_w[address + i] = rw;
    write_w[address + i] = ww;
  }
}

static void mem_read_b(void) {
  mem_addr &= 0xFFFFFF;
  mem_data = read_b[mem_addr >> 14](mem_addr);
  add_cycles(4);
}

static void mem_write_b(void) {
  mem_addr &= 0xFFFFFF;
  write_b[mem_addr >> 14](mem_addr, mem_data);
  add_cycles(4);
}

static u32 mem_read_l(u32 a);
static int test_n;

static void mem_read_w(void) {
  if (mem_addr & 1) {
    //printf("Address error: %06X\n", mem_addr);
    u32 saved = mem_addr;
    PC = mem_read_l(0x00000C);
    mem_addr = saved;
    mem_data = 0;
    areg[7] -= 14;
    longjmp(ex, 1);
    //exit(1);
  }
  mem_addr &= 0xFFFFFF;
  mem_data = read_w[mem_addr >> 14](mem_addr);
  add_cycles(4);
}

static void mem_write_w(void) {
  if (mem_addr & 1) {
    printf("Address error: %06X\n", mem_addr);
    exit(1);
  }
  mem_addr &= 0xFFFFFF;
  write_w[mem_addr >> 14](mem_addr, mem_data);
  add_cycles(4);
}

static u32 mem_read_l(u32 a) {
  mem_addr = a;
  mem_read_w();
  u32 x = mem_data;
  x <<= 16;
  mem_addr += 2;
  mem_read_w();
  x |= mem_data;
  mem_addr -= 2;
  return x;
}

static void mem_write_l(u32 a, u32 x) {
  mem_data = x >> 16;
  mem_addr = a;
  mem_write_w();
  mem_data = x & 0xFFFF;
  mem_addr += 2;
  mem_write_w();
  mem_addr -= 2;
}

static void push(u16 x) {
  areg[7] -= 2;
  mem_data = x;
  mem_addr = areg[7];
  mem_write_w();
}

static u16 pop(void) {
  mem_addr = areg[7];
  areg[7] += 2;
  mem_read_w();
  return mem_data;
}

static void fetch(void) {
  IR = IRC;
  mem_addr = PC;
  mem_read_w();
  IRC = mem_data;
  PC += 2;
}

static void exception(int vector, u16 sr) {
  SR &= ~SR_T;
  SR |= SR_S;
  PC -= 4;
  //fprintf(stderr, "Exception %d, push %04X %08X\n", vector, sr, PC);
  push(PC & 0xFFFF);
  push(PC >> 16);
  push(sr);
  mem_addr = vector << 2;
  mem_read_w();
  PC = mem_data << 16;
  mem_addr += 2;
  mem_read_w();
  PC |= mem_data;
  fetch();
  fetch();
}

void mc68000_ipl(int level) {
  SDL_LockMutex(ipl_mutex);
  ipl = level;
  vec = 24 + level;
  SDL_UnlockMutex(ipl_mutex);
}

static void interrupt(void) {
  u16 sr = SR;
  SR &= ~0x0700;
  SR |= ipl << 8;
  //fprintf(stderr, "Interrupt level %d taken\n", ipl);
  exception(vec, sr);
}

static void compute_ea(int size) {
  int r = EA_R_FIELD;
  if (size == 1 && r == 7)
    size = 2;
  switch(EA_M_FIELD) {
  case 0:
  case 1: return;
  case 2: mem_addr = areg[r];
          return;
  case 3: mem_addr = areg[r];
          areg[r] += size;
          return;
  case 4: areg[r] -= size;
          mem_addr = areg[r];
          return;
  case 5: fetch();
          mem_addr = areg[r] + EXTW(IR);
          return;
  case 6: fetch();
          mem_addr = areg[r] + EXTB(IR);
	  int r = (IR >> 12) & 7;
	  u32 i = (IR & 0x8000) ? areg[r] : dreg[r];
	  if ((IR & 0x800) == 0)
	    i = EXTW(i);
	  mem_addr += i;
          return;
  }
  switch (r) {
  case 0: fetch();
          mem_addr = EXTW(IR);
          return;
  case 1: fetch();
          u32 x = IR;
          x <<= 16;
          fetch();
          mem_addr = x | IR;
          return;
  case 2: fetch();
          mem_addr = PC - 4 + EXTW(IR);
	  return;
  case 3: fetch();
          mem_addr = PC - 4 + EXTB(IR);
	  int r = (IR >> 12) & 7;
	  u32 i = (IR & 0x8000) ? dreg[r] : areg[r];
	  if (IR & 0x800) i = EXTW(i);
	  mem_addr += i;
          return;
  case 4: return;
  case 5:
  case 6:
  case 7: insn_illegal();
  }
}

static u32 read_b_ea(void) {
  int r = EA_R_FIELD;
  compute_ea(1);
  switch(EA_M_FIELD) {
  case 0: return dreg[r] & 0xFF;
  case 1: insn_illegal(); return 0;
  case 2:
  case 3:
  case 4:
  case 6: add_cycles(2);
  case 5: mem_read_b();
          return mem_data;
  }
  switch (r) {
  case 0:
  case 1:
  case 2:
  case 3: mem_read_b();
	  return mem_data;
  case 4: fetch();
          return IR & 0xFF;
  case 5:
  case 6:
  case 7: insn_illegal(); return 0;
  }
  return 0;
}

static u32 read_b_imm(void) {
  fetch();
  return IR & 0xFF;
}

static void modify_b_ea(u32 x) {
  int r = EA_R_FIELD;
  switch(EA_M_FIELD) {
  case 0: dreg[r] = (dreg[r] & 0xFFFFFF00) | (x & 0xFF);
	  return;
  case 1: insn_illegal(); return;
  case 2:
  case 3:
  case 4:
  case 5:
  case 6: mem_data = x;
          mem_write_b();
          return;
  }
  switch (r) {
  case 0:
  case 1:
  case 2:
  case 3: mem_data = x;
	  mem_write_b();
	  return;
  case 4:
  case 5:
  case 6:
  case 7: insn_illegal(); return;
  }
}

static void write_b_ea(u32 x) {
  compute_ea(1);
  modify_b_ea(x);
}

static u32 read_w_ea(void) {
  int r = EA_R_FIELD;
  compute_ea(2);
  switch(EA_M_FIELD) {
  case 0: return dreg[r] & 0xFFFF;
  case 1: return areg[r] & 0xFFFF;
  case 2:
  case 3:
  case 4:
  case 6: add_cycles(2);
  case 5: mem_read_w();
          return mem_data;
  }
  switch (r) {
  case 0:
  case 1:
  case 2:
  case 3: mem_read_w();
	  return mem_data;
  case 4: fetch();
          return IR;
  case 5:
  case 6:
  case 7: insn_illegal(); return 0;
  }
  return 0;
}

static u32 read_w_imm(void) {
  fetch();
  return IR;
}

static void modify_w_ea(u32 x) {
  int r = EA_R_FIELD;
  switch(EA_M_FIELD) {
  case 0: dreg[r] = (dreg[r] & 0xFFFF0000) | (x & 0xFFFF);
	  return;
  case 1: areg[r] = x;
          return;
  case 2:
  case 3:
  case 4:
  case 5:
  case 6: mem_data = x;
          mem_write_w();
          return;
  }
  switch (r) {
  case 0:
  case 1:
  case 2:
  case 3: mem_data = x;
          mem_write_w();
	  return;
  case 5: insn_illegal(); return;
  case 6: insn_illegal(); return;
  case 7: insn_illegal(); return;
  }
}

static void write_w_ea(u32 x) {
  compute_ea(2);
  modify_w_ea(x);
}

static u32 read_l_ea(void) {
  int r = EA_R_FIELD;
  compute_ea(4);
  switch(EA_M_FIELD) {
  case 0: return dreg[r];
  case 1: return areg[r];
  case 2:
  case 3:
  case 4:
  case 6: add_cycles(2);
  case 5: return mem_read_l(mem_addr);
  }
  switch (r) {
  case 0:
  case 1:
  case 2:
  case 3: return mem_read_l(mem_addr);
  case 4: fetch();
          u32 x = IR;
          fetch();
          return (x << 16) | IR;
  case 5:
  case 6:
  case 7: insn_illegal(); return 0;
  }
  return 0;
}

static u32 read_l_imm(void) {
  fetch();
  u32 x = IR << 16;
  fetch();
  return x | IR;
}

static void modify_l_ea(u32 x) {
  int r = EA_R_FIELD;
  switch(EA_M_FIELD) {
  case 0: dreg[r] = x;
	  return;
  case 1: areg[r] = x;
	  return;
  case 2:
  case 3:
  case 4:
  case 5:
  case 6: mem_write_l(mem_addr, x);
          return;
  }
  switch (r) {
  case 0:
  case 1:
  case 2:
  case 3: mem_write_l(mem_addr, x);
	  return;
  case 4:
  case 5:
  case 6:
  case 7: insn_illegal(); return;
  }
}

static void write_l_ea(u32 x) {
  compute_ea(4);
  modify_l_ea(x);
}

static u32 alub(int op, u32 src, u32 dst) {
  u32 result = 0;
  src &= 0xFF;
  dst &= 0xFF;
  switch (op) {
  case ADD:
    result = dst + src;
    break;
  case ADC:
    result = dst + src + !!FLAG_C;
    break;
  case SUB:
    result = dst - src;
    break;
  case IOR:
    result = dst | src;
    break;
  case AND:
    result = dst & src;
    break;
  case EOR:
    result = dst ^ src;
    break;
  }
  SET_C(result & 0x100);
  result &= 0xFF;
  //V
  SET_Z(result == 0);
  SET_N(result & 0x80);
  //X
  return result;
}

static u32 aluw(int op, u32 src, u32 dst) {
  u32 result = 0;
  src &= 0xFFFF;
  dst &= 0xFFFF;
  switch (op) {
  case ADD:
    result = dst + src;
    SET_V((!(src & 0x8000) && !(dst & 0x8000) && (result & 0x8000)) ||
	  ((src & 0x8000) && (dst & 0x8000) && !(result & 0x8000)));
    break;
  case ADC:
    result = dst + src + !!FLAG_C;
    break;
  case SUB:
    result = dst - src;
    SET_V((((src^dst) & (result^dst)) >> 15) & 1);
    break;
  case IOR:
    result = dst | src;
    break;
  case AND:
    result = dst & src;
    break;
  case EOR:
    result = dst ^ src;
    break;
  }
  SET_C(result & 0x10000);
  result &= 0xFFFF;
  SET_Z(result == 0);
  SET_N(result & 0x8000);
  //X
  if (trace_p)
    fprintf (stderr, "ALU: %04X # %04X -> %04X\n", src, dst, result);
  return result;
}

static u32 alul(int op, u32 src, u32 dst) {
  u32 result = 0;
  u16 sr;
  switch (op) {
  case ADD:
  case ADC:
    result = aluw(op, src, dst);
    sr = SR;
    result |= aluw(ADC, src >> 16, dst >> 16) << 16;
    SR &= sr | ~SR_Z;
    break;
  case SUB:
    result = alul(ADD, -src, dst);
    break;
  case IOR:
    result = aluw(IOR, src, dst);
    sr = SR;
    result |= aluw(IOR, src >> 16, dst >> 16) << 16;
    SR &= sr | ~SR_Z;
    break;
  case AND:
    result = aluw(AND, src, dst);
    sr = SR;
    result |= aluw(AND, src >> 16, dst >> 16) << 16;
    SR &= sr | ~SR_Z;
    break;
  case EOR:
    result = aluw(EOR, src, dst);
    sr = SR;
    result |= aluw(EOR, src >> 16, dst >> 16) << 16;
    SR &= sr | ~SR_Z;
    break;
  }
  return result;
}

static u32 alue(int op, u32 op1, u32 op2) {
  u32 mask = 0xFF; // or 0xFFFF or 0xFFFFFFFF;
  //u32 sign = 0x80; // or 0x8000 or 0x80000000;
  int n = 7; // or 15 or 31;
  u32 result;
  int i;
  switch (op) {
  case LSL:
    result = op1;
    for (i = 0; i < op2; i++)
      result = (result & mask) << 1;
    break;
  case ROL:
    result = op1;
    for (i = 0; i < op2; i++)
      result = ((result & mask) << 1) | ((result >> n) & 1);
    break;
  case LSR:
    result = op1;
    for (i = 0; i < op2; i++)
      result = result >> 1;
    break;
  case ASR:
    result = op1;
    for (i = 0; i < op2; i++)
      result = (result >> 1) | (result & 0x80000000);
    break;
  case ROR:
    result = op1;
    for (i = 0; i < op2; i++)
      result = (result >> 1) | ((result & 1) << n);
    break;
  }
  return result;
}

static const struct s size_b = {
  1,
  "B",
  0xFF,
  0x80,
  read_b_ea,
  read_b_imm,
  modify_b_ea,
  write_b_ea,
  alub
};

static const struct s size_w = {
  2,
  "W",
  0xFFFF,
  0x8000,
  read_w_ea,
  read_w_imm,
  modify_w_ea,
  write_w_ea,
  aluw
};

static const struct s size_l = {
  4,
  "L",
  0xFFFFFFFF,
  0x80000000,
  read_l_ea,
  read_l_imm,
  modify_l_ea,
  write_l_ea,
  alul
};

/*
D0-7
A0-7
PC
IRC IR IRD
SR
USP

0000000000111100 ORI to CCR
0000000001111100 ORI to SR
00000000ssmmmrrr ORI
0000001000111100 ANDI to CCR
0000001001111100 ANDI to SR
00000010ssmmmrrr ANDI
00000100ssmmmrrr SUBI
00000110ssmmmrrr ADDI
0000100000mmmrrr BTST immediate
0000100001mmmrrr BCHG immediate
0000100010mmmrrr BCLR immediate
0000100011mmmrrr BSET immediate
0000101000111100 EORI to CCR
0000101001111100 EORI to SR
00001010ssmmmrrr EORI
00001100ssmmmrrr CMPI
0000rrr100mmmrrr BTST register
0000rrr101mmmrrr BCHG register
0000rrr110mmmrrr BCLR register
0000rrr111mmmrrr BSET register
0000rrr1ss001rrr MOVEP
001srrr001mmmrrr MOVEA
00ssrrrmmmmmmrrr MOVE
0100000011mmmrrr MOVE from SR
01000000ssmmmrrr NEGX
01000010ssmmmrrr CLR
0100010011mmmrrr MOVE to CCR
01000100ssmmmrrr NEG
0100011011mmmrrr MOVE to SR
01000110ssmmmrrr NOT
0100100000mmmrrr NBCD
0100100001000rrr SWAP
0100100001mmmrrr PEA
010010001s000rrr EXT
0100101011111100 ILLEGAL
0100101011mmmrrr TAS
01001010ssmmmrrr TST
010011100100xxxx TRAP
0100111001010rrr LINK
0100111001011rrr UNLK 
010011100110xrrr MOVE USP
0100111001110000 RESET
0100111001110001 NOP
0100111001110010 STOP
0100111001110011 RTE
0100111001110101 RTS
0100111001110110 TRAPV
0100111001110111 RTR
0100111010mmmrrr JSR 
0100111011mmmrrr JMP
01001d001smmmrrr MOVEM
0100rrr111mmmrrr LEA
0100rrr1s0mmmrrr CHK
0101cccc11001rrr DBcc
0101cccc11mmmrrr Scc
0101xxx0ssmmmrrr ADDQ
0101xxx1ssmmmrrr SUBQ
01100000xxxxxxxx BRA
01100001xxxxxxxx BSR
0110ccccxxxxxxxx Bcc
0111rrr0xxxxxxxx MOVEQ
1000rrr011mmmrrr DIVU
1000rrr10000xrrr SBCD
1000rrr111mmmrrr DIVS
1000rrrdssmmmrrr OR
1001rrr1ss00xrrr SUBX
1001rrrdssmmmrrr SUB
1001rrrs11mmmrrr SUBA
1010xxxxxxxxxxxx line-a
1011rrr0ssmmmrrr CMP
1011rrr1ss001rrr CMPM
1011rrr1ssmmmrrr EOR
1011rrrs11mmmrrr CMPA
1100rrr011mmmrrr MULU
1100rrr10000xrrr ABCD
1100rrr111mmmrrr MULS
1100rrr1xx00xrrr EXG
1100rrrdssmmmrrr AND
1101rrr1ss00xrrr ADDX
1101rrrdssmmmrrr ADD
1101rrrs11mmmrrr ADDA
1110rrr0ssx00rrr ASR
1110rrr0ssx01rrr LSR
1110rrr0ssx10rrr ROXR
1110rrr0ssx11rrr ROR
1110rrr1ssx00rrr ASL
1110rrr1ssx01rrr LSL
1110rrr1ssx10rrr ROXL
1110rrr1ssx11rrr ROL
1111xxxxxxxxxxxx line-f
*/

/*
ALU

0000000xxxxxxxxx ORI
0000001xxxxxxxxx ANDI
0000010xxxxxxxxx SUBI
0000011xxxxxxxxx ADDI
0000101xxxxxxxxx EORI
0000110xxxxxxxxx CMPI
01000100xxxxxxxx NEG
01000110xxxxxxxx NOT
0100100000xxxxxx NBCD
0100100xxx000xxx EXT
01001010xxxxxxxx TST
0101xxx0xxxxxxxx ADDQ
0101xxx1xxxxxxxx SUBQ
1000xxx011xxxxxx DIVU
1000xxx10000xxxx SBCD
1000xxx111xxxxxx DIVS
1000xxxxxxxxxxxx OR
1001xxx1xx00xxxx SUBX
1001xxxxxxxxxxxx SUB
1011xxx1xx001xxx CMPM
1011xxx1xxxxxxxx EOR
1011xxxxxxxxxxxx CMP
1100xxx011xxxxxx MULU
1100xxx10000xxxx ABCD
1100xxx111xxxxxx MULS
1100xxxxxxxxxxxx AND
1101xxx1xx00xxxx ADDX
1101xxxxxxxxxxxx ADD
1110xxx0xxx00xxx ASR
1110xxx0xxx01xxx LSR
1110xxx0xxx10xxx ROXR
1110xxx0xxx11xxx ROR
1110xxx1xxx00xxx ASL
1110xxx1xxx01xxx LSL
1110xxx1xxx10xxx ROXL
1110xxx1xxx11xxx ROL
*/

static void insn_add_r(const struct s *size) {
  int r = REG_FIELD;
  u32 src = size->read_ea();
  u32 dst = dreg[r];
  IRD = r;
  size->modify_ea(size->alu(ADD, src, dst));
}

static void insn_add_m(const struct s *size) {
  int r = REG_FIELD;
  u32 src = dreg[r];
  u32 dst = size->read_ea();
  size->modify_ea(size->alu(ADD, src, dst));
}

DEFINSN_BWL(add_r)
DEFINSN_BWL(add_m)

static void insn_addaw(void) {
  TRACE();
  AREG += EXTW(read_w_ea());
}

static void insn_addal(void) {
  TRACE();
  AREG += read_l_ea();
}

#define CHECK_ALUI_EA(i1, i2)                             \
  switch (IRD & 0177) {                                        \
  case 0010: case 0011: case 0012: case 0013:                   \
  case 0014: case 0015: case 0016: case 0017:                   \
  case 0110: case 0111: case 0112: case 0113:                   \
  case 0114: case 0115: case 0116: case 0117:                   \
  case 0072: case 0073: case 0075: case 0076: case 0077:        \
  case 0172: case 0173: case 0175: case 0176: case 0177:        \
    insn_illegal(); return;                                     \
  case 0074: i1(); return;                                      \
  case 0174: i2(); return;                                      \
  }

static void insn_addi(const struct s *size) {
  CHECK_ALUI_EA(insn_illegal, insn_illegal);
  u32 src = size->read_imm();
  u32 dst = size->read_ea();
  size->modify_ea(size->alu(ADD, src, dst));
}
  
DEFINSN_BWL(addi)

static void insn_addq(const struct s *size) {
  u32 src = REG_FIELD;
  u32 dst;
  if ((IRD & 070) == 010)
    dst = areg[EA_R_FIELD];
  else
    dst = size->read_ea();
  if (src == 0)
    src = 8;
  size->modify_ea(size_l.alu(ADD, src, dst));
}

DEFINSN_BWL(addq)

static void insn_and_r(const struct s *size) {
  int r = REG_FIELD;
  u32 src = size->read_ea();
  u32 dst = dreg[r];
  IRD = r;
  size->modify_ea(size->alu(AND, src, dst));
}

static void insn_exg_dd(int r1, int r2) {
  u32 tmp = dreg[r1];
  add_cycles(2);
  dreg[r1] = dreg[r2];
  dreg[r2] = tmp;
}

static void insn_exg_aa(int r1, int r2) {
  u32 tmp = areg[r1];
  add_cycles(2);
  areg[r1] = areg[r2];
  areg[r2] = tmp;
}

static void insn_exg_da(int r1, int r2) {
  u32 tmp = dreg[r1];
  add_cycles(2);
  dreg[r1] = areg[r2];
  areg[r2] = tmp;
}

static void insn_and_m(const struct s *size) {
  int r = REG_FIELD;
  switch (IRD & 0370) {
  case 0100:
    insn_exg_dd(r, EA_R_FIELD);
    return;
  case 0110:
    insn_exg_aa(r, EA_R_FIELD);
    return;
  case 0210:
    insn_exg_da(r, EA_R_FIELD);
    return;
  }
  u32 src = dreg[r];
  u32 dst = size->read_ea();
  size->modify_ea(size->alu(AND, src, dst));
}

DEFINSN_BWL(and_r)
DEFINSN_BWL(and_m)

static void insn_andi_ccr(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_andi_sr(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_andi(const struct s *size) {
  CHECK_ALUI_EA(insn_andi_ccr, insn_andi_sr);
  u32 src = size->read_imm();
  u32 dst = size->read_ea();
  size->modify_ea(size->alu(AND, src, dst));
}

DEFINSN_BWL(andi)
  
static int condition() {
  int jump = 0;
  switch (CC_FIELD) {
  case 0x0: //T
    jump = 1;
    break;
  case 0x2: //HI
    jump = !FLAG_C && !FLAG_Z;
    break;
  case 0x4: //CC
    jump = !FLAG_C;
    break;
  case 0x6: //NE
    jump = !FLAG_Z;
    break;
  case 0x8: //VC
    jump = !FLAG_V;
    break;
  case 0xA: //PL
    jump = !FLAG_N;
    break;
  case 0xC: //GE
    jump = (FLAG_N && FLAG_V) || (!FLAG_N && !FLAG_V);
    break;
  case 0xE: //GT
    jump = !(FLAG_Z || (FLAG_N && !FLAG_V) || (!FLAG_N && FLAG_V));
    break;
  }
  return (IRD & 0x100) ? !jump : jump;
}

static void insn_bcc(void) {
  TRACE();
  u32 a = PC - 2;
  u32 offset = IRD & 0xFF;
  if (offset == 0) {
    fetch();
    offset = EXTW(IR);
  } else
    offset = EXTB(offset);
  if (condition()) {
    add_cycles(2);
    PC = a + offset;
    fetch();
  } else {
    add_cycles(4);
  }
}

static void bchg(u32 src) {
  u32 dst;
  u32 x = 1;
  if (EA_M_FIELD == 0) {
    dst = dreg[EA_R_FIELD];
    if (src < 16)
      add_cycles(2);
    else
      add_cycles(4);
    x <<= src % 32;
    dreg[EA_R_FIELD] = dst ^ x;
  } else {
    dst = read_b_ea();
    x <<= src % 8;
    modify_b_ea(dst ^ x);
  }
  SET_Z((dst & x) == 0);
}

static void insn_bchg(void) {
  TRACE();
  bchg(DREG);
}

static void insn_bchgi(void) {
  TRACE();
  bchg(read_b_imm());
}

static void insn_bclr(void) {
  TRACE();
  u32 dst, src = DREG;
  u32 x = 1;
  if (EA_M_FIELD == 0) {
    dst = dreg[EA_R_FIELD];
    if (src < 16)
      add_cycles(2);
    else
      add_cycles(4);
    x <<= src % 32;
    dreg[EA_R_FIELD] = dst & ~x;
    SET_Z((dst & x) == 0);
  } else {
    dst = read_b_ea();
    x <<= src % 8;
    modify_b_ea(alub(AND, dst, ~x));
    alub(AND, dst, x);
  }
}

static void insn_bclri(void) {
  TRACE();
  u32 src = read_b_imm();
  u32 dst;
  u32 x = 1;
  if ((IRD & 070) == 0) {
    if (src < 16)
      add_cycles(4);
    else
      add_cycles(6);
    dst = dreg[EA_R_FIELD];
    x <<= src % 32;
    dreg[EA_R_FIELD] = dst & ~x;
    SET_Z((dst & x) == 0);
  } else {
    dst = read_b_ea();
    x <<= src % 8;
    modify_b_ea(alub(AND, dst, ~x));
    alub(AND, dst, x);
  }
}

static void insn_bra(void) {
  TRACE();
  u32 a = PC - 2;
  u32 offset = IRD & 0xFF;
  add_cycles(2);
  if (offset == 0) {
    fetch();
    offset = EXTW(IR);
  } else
    offset = EXTB(offset);
  PC = a + offset;
  fetch();
}

static void insn_bset(void) {
  TRACE();
  u32 dst, src = DREG;
  u32 x = 1;
  if (EA_M_FIELD == 0) {
    dst = dreg[EA_R_FIELD];
    if (src < 16)
      add_cycles(2);
    else
      add_cycles(4);
    x <<= src % 32;
    dreg[EA_R_FIELD] = dst | x;
    SET_Z((dst & x) == 0);
  } else {
    dst = read_b_ea();
    x <<= src % 8;
    modify_b_ea(alub(IOR, dst, x));
    alub(AND, dst, x);
  }
}

static void insn_bseti(void) {
  TRACE();
  u32 src = read_b_imm();
  u32 dst;
  u32 x = 1;
  if (EA_M_FIELD == 0) {
    dst = dreg[EA_R_FIELD];
    if (src < 16)
      add_cycles(2);
    else
      add_cycles(4);
    x <<= src % 32;
    dreg[EA_R_FIELD] = dst | x;
    SET_Z((dst & x) == 0);
  } else {
    dst = read_b_ea();
    x <<= src % 8;
    modify_b_ea(alub(IOR, dst, x));
    alub(AND, dst, x);
  }
}

static void insn_bsr(void) {
  TRACE();
  u32 a = PC - 2;
  u32 offset = IRD & 0xFF;
  add_cycles(2);
  if (offset == 0) {
    fetch();
    offset = EXTW(IR);
  } else
    offset = EXTB(offset);
  push(PC - 2);
  push((PC - 2) >> 16);
  PC = a + offset;
  fetch();
}

static void insn_btst(void) {
  TRACE();
  u32 dst, src = DREG;
  u32 x = 1;
  if (EA_M_FIELD == 0) {
    add_cycles(2);
    dst = dreg[EA_R_FIELD];
    src %= 32;
  } else {
    dst = read_b_ea();
    src %= 8;
  }
  SET_Z((dst & (x << src)) == 0);
}

static void insn_btsti(void) {
  TRACE();
  u32 dst, src = read_b_imm();
  u32 x = 1;
  if (EA_M_FIELD == 0) {
    add_cycles(2);
    dst = dreg[EA_R_FIELD];
    src %= 32;
  } else {
    dst = read_b_ea();
    src %= 8;
  }
  SET_Z((dst & (x << src)) == 0);
}

static void insn_chk(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_clr(const struct s *size) {
  size->write_ea(0);
  SET_C(0);
  SET_V(0);
  SET_Z(1);
  SET_N(0);
}

DEFINSN_BWL(clr)

static void insn_cmp(const struct s *size) {
  u32 src = size->read_ea();
  u32 dst = DREG;
  size->alu(SUB, src, dst);
}
  
DEFINSN_BWL(cmp)

static void insn_cmpa(const struct s *size) {
  u32 src, dst;
  switch(PC-4) {
  default:
    src = size->read_ea();
    dst = AREG;
    if (size == &size_w)
      src = EXTW(src);
    break;
  case 0x004784:
  case 0x0047d0:
  case 0x00481e:
  case 0x004882:
  case 0x0048e4:
    src = AREG;
    dst = size->read_ea();
    break;
  }
  alul(SUB, src, dst);
}

DEFINSN_WL(cmpa)

static void insn_cmpi(const struct s *size) {
  CHECK_ALUI_EA(insn_illegal, insn_illegal);
  u32 src = size->read_imm();
  u32 dst = size->read_ea();
  size->alu(SUB, src, dst);
}

DEFINSN_BWL(cmpi)

static void insn_cmpm(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_eor(const struct s *size) {
  u32 src = DREG;
  u32 dst = size->read_ea();
  size->modify_ea(size->alu(EOR, src, dst));
}

DEFINSN_BWL(eor)

static void insn_cmpm_or_eor(void) {
  switch (IRD & 0370) {
  case 0010: case 0110: case 0210:
    insn_cmpm();
    return;
  }
  switch (IRD & 0300) {
  case 0000:
    insn_eorb();
    return;
  case 0100:
    insn_eorw();
    return;
  case 0200:
    insn_eorl();
    return;
  }
}

static void insn_dbcc(void) {
  TRACE();
  int r = EA_R_FIELD;
  add_cycles(2);
  u32 a = PC - 2;
  fetch();
  u32 offset = EXTW(IR);
  if (!condition()) {
    dreg[r] = (dreg[r] & 0xFFFF0000) | ((dreg[r] - 1) & 0xFFFF);
    if ((dreg[r] & 0xFFFF) != 0xFFFF) {
      PC = a + offset;
      fetch();
    }
  }
}

static void insn_scc(void) {
  TRACE();
  write_b_ea(condition() ? 0xFF : 0x00);
}

static void insn_dbcc_or_scc(void) {
  switch (EA_FIELD) {
  case 010: case 011: case 012: case 013:
  case 014: case 015: case 016: case 017:
    insn_dbcc(); return;
  case 072: case 073: case 074: case 075:
  case 076: case 077:
    insn_illegal(); return;
  }
  insn_scc();
}

static void insn_divs(void) {
  TRACE();
  int r = REG_FIELD;
  u16 src = read_w_ea();
  u32 dst = dreg[r];
  dreg[r] = (dst / src) & 0xFFFF;
  dreg[r] |= ((dst % src) & 0xFFFF) << 16;
}

static void insn_divu(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_eori_ccr(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_eori_sr(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_eori(const struct s *size) {
  CHECK_ALUI_EA(insn_eori_ccr, insn_eori_sr);
  u32 src = size->read_imm();
  u32 dst = size->read_ea();
  size->modify_ea(size->alu(EOR, src, dst));
}

DEFINSN_BWL(eori)

static u16 reverse(u16 data)
{
  data = (data & 0xFF00) >> 8 | (data & 0x00FF) << 8;
  data = (data & 0xF0F0) >> 4 | (data & 0x0F0F) << 4;
  data = (data & 0xCCCC) >> 2 | (data & 0x3333) << 2;
  data = (data & 0xAAAA) >> 1 | (data & 0x5555) << 1;
  return data;
}

static void insn_movemw_rm(void) {
  int i;
  TRACE();
  switch(IRD & 070) {
  case 000: case 010: case 030:
    insn_illegal(); return;
  case 070:
    if ((IRD & 6) == 2) {
      insn_illegal();
      return;
    }
  }
  fetch();
  u16 mask = IR;
  compute_ea(0);
  if ((IRD & 070) == 040) {
    mask = reverse(mask);
    for (i = 7; i >= 0; i--)
      if (mask & (1 << (i+8))) {
	areg[EA_R_FIELD] -= 2;
	mem_addr = areg[EA_R_FIELD];
	mem_data = areg[i];
	mem_write_w();
      }
    for (i = 7; i >= 0; i--)
      if (mask & (1 << i)) {
	areg[EA_R_FIELD] -= 2;
	mem_addr = areg[EA_R_FIELD];
	mem_data = dreg[i];
	mem_write_w();
      }
  } else {
    for (i = 0; i < 8; i++)
      if (mask & (1 << i)) {
	if (trace_p)
	  fprintf(stderr, "MOVEM: write D%d<%08X> to %06X\n", i, dreg[i], mem_addr);
	mem_data = dreg[i];
	mem_write_w();
	mem_addr += 2;
      }
    for (i = 0; i < 8; i++)
      if (mask & (1 << (i+8))) {
	if (trace_p)
	  fprintf(stderr, "MOVEM: write A%d to %06X\n", areg[i], mem_addr);
	mem_data = areg[i];
	mem_write_w();
	mem_addr += 2;
      }
  }
}

static void insn_moveml_rm(void) {
  int i;
  TRACE();
  switch(IRD & 070) {
  case 000: case 010: case 030:
    insn_illegal(); return;
  case 070:
    if ((IRD & 6) == 2) {
      insn_illegal();
      return;
    }
  }
  fetch();
  u16 mask = IR;
  compute_ea(0);
  if ((IRD & 070) == 040) {
    mask = reverse(mask);
    for (i = 7; i >= 0; i--)
      if (mask & (1 << (i+8))) {
	areg[EA_R_FIELD] -= 4;
	mem_write_l(areg[EA_R_FIELD], areg[i]);
      }
    for (i = 7; i >= 0; i--)
      if (mask & (1 << i)) {
	areg[EA_R_FIELD] -= 4;
	mem_write_l(areg[EA_R_FIELD], dreg[i]);
      }
  } else {
    for (i = 0; i < 8; i++)
      if (mask & (1 << i)) {
	mem_write_l(mem_addr, dreg[i]);
	mem_addr += 4;
      }
    for (i = 0; i < 8; i++)
      if (mask & (1 << (i+8))) {
	mem_write_l(mem_addr, areg[i]);
	mem_addr += 4;
      }
  }
}

static void insn_movemw_mr(void) {
  int i;
  TRACE();
  switch(IRD & 070) {
  case 000: case 010: case 040:
    insn_illegal(); return;
  }
  fetch();
  u16 mask = IR;
  compute_ea(0);
  if ((IRD & 070) == 030) {
    for (i = 0; i < 8; i++)
      if (mask & (1 << i)) {
	mem_addr = areg[EA_R_FIELD];
	mem_read_w();
	dreg[i] = mem_data;
	areg[EA_R_FIELD] += 2;
      }
    for (i = 0; i < 8; i++)
      if (mask & (1 << (i+8))) {
	mem_addr = areg[EA_R_FIELD];
	mem_read_w();
	areg[i] = mem_data;
	areg[EA_R_FIELD] += 2;
      }
  } else {
    for (i = 0; i < 8; i++)
      if (mask & (1 << i)) {
	mem_read_w();
	dreg[i] = mem_data;
	mem_addr += 2;
      }
    for (i = 0; i < 8; i++)
      if (mask & (1 << (i+8))) {
	mem_read_w();
	areg[i] = mem_data;
	mem_addr += 2;
      }
  }
}

static void insn_moveml_mr(void) {
  int i;
  TRACE();
  switch(IRD & 070) {
  case 000: case 010: case 040:
    insn_illegal(); return;
  }
  fetch();
  u16 mask = IR;
  compute_ea(0);
  if ((IRD & 070) == 030) {
    for (i = 0; i < 8; i++)
      if (mask & (1 << i)) {
	dreg[i] = mem_read_l(areg[EA_R_FIELD]);
	areg[EA_R_FIELD] += 4;
      }
    for (i = 0; i < 8; i++)
      if (mask & (1 << (i+8))) {
	areg[i] = mem_read_l(areg[EA_R_FIELD]);
	areg[EA_R_FIELD] += 4;
      }
  } else {
    for (i = 0; i < 8; i++)
      if (mask & (1 << i)) {
	dreg[i] = mem_read_l(mem_addr);
	mem_addr += 4;
      }
    for (i = 0; i < 8; i++)
      if (mask & (1 << (i+8))) {
	areg[i] = mem_read_l(mem_addr);
	mem_addr += 4;
      }
  }
}

static void insn_extb(void) {
  if ((IRD & 070) != 0) {
    insn_movemw_rm();
    return;
  }

  int r = EA_R_FIELD;
  dreg[r] = (dreg[r] & 0xFFFF0000) | (EXTB(dreg[r]) & 0xFFFF);
}

static void insn_extw(void) {
  if ((IRD & 070) != 0) {
    insn_moveml_rm();
    return;
  }

  int r = EA_R_FIELD;
  dreg[r] = EXTW(dreg[r]);
}

static void insn_illegal(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_illegal_or_tas(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_jmp(void) {
  TRACE();
  switch (IRD & 0177) {
  case 0000: case 0001: case 0002: case 0003:
  case 0004: case 0005: case 0006: case 0007:
  case 0010: case 0011: case 0012: case 0013:
  case 0014: case 0015: case 0016: case 0017:
  case 0030: case 0031: case 0032: case 0033:
  case 0034: case 0035: case 0036: case 0037:
  case 0040: case 0041: case 0042: case 0043:
  case 0044: case 0045: case 0046: case 0047:
  case 0074: case 0075: case 0076: case 0077:
    insn_illegal(); return;
  }
  compute_ea(0);
  PC = mem_addr;
  fetch();
}

static void insn_jsr(void) {
  TRACE();
  switch (IRD & 0177) {
  case 0000: case 0001: case 0002: case 0003:
  case 0004: case 0005: case 0006: case 0007:
  case 0010: case 0011: case 0012: case 0013:
  case 0014: case 0015: case 0016: case 0017:
  case 0030: case 0031: case 0032: case 0033:
  case 0034: case 0035: case 0036: case 0037:
  case 0040: case 0041: case 0042: case 0043:
  case 0044: case 0045: case 0046: case 0047:
  case 0074: case 0075: case 0076: case 0077:
    insn_illegal(); return;
  }
  compute_ea(0);
  u32 x = PC - 2;
  PC = mem_addr;
  fetch();
  push(x);
  push(x >> 16);
}

static void insn_lea(void) {
  TRACE();
  UNIMPLEMENTED();
  //Check ea.
  //compute_ea(0);
  //AREG = mem_addr;
}

static void insn_linea(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_linef(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_trap(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_link(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_unlk(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_move_usp(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_reset(void) {
  TRACE();
  SR = 0x2700;
  SP = mem_read_l(0);
  PC = mem_read_l(4);
  ipl = 0;
}  

static void insn_nop(void) {
  TRACE();
}

static void insn_stop(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_rte(void) {
  TRACE();
  SR = pop();
  PC = pop() << 16;
  PC |= pop();
  fetch();
}

static void insn_rts(void) {
  TRACE();
  PC = pop() << 16;
  PC |= pop();
  fetch();
}

static void insn_trapv(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_rtr(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_misc(void) {
  switch (EA_FIELD) {
  case 000: case 001: case 002: case 003:
  case 004: case 005: case 006: case 007:
  case 010: case 011: case 012: case 013:
  case 014: case 015: case 016: case 017:
            insn_trap(); break;
  case 020: case 021: case 022: case 023:
  case 024: case 025: case 026: case 027:
            insn_link(); break;
  case 030: case 031: case 032: case 033:
  case 034: case 035: case 036: case 037:
            insn_unlk(); break; 
  case 040: case 041: case 042: case 043:
  case 044: case 045: case 046: case 047:
            insn_move_usp(); break;
  case 060: insn_reset(); break;
  case 061: insn_nop(); break;
  case 062: insn_stop(); break;
  case 063: insn_rte(); break;
  case 065: insn_rts(); break;
  case 066: insn_trapv(); break;
  case 067: insn_rtr(); break;
  default: insn_illegal(); break;
  }
}

static void insn_move(const struct s *size) {
  u32 x = size->read_ea();
  u32 old_addr = mem_addr;
  IRD = ((IRD & 0700) >> 3) | ((IRD & 07000) >> 9);
  size->write_ea(x);
  if (trace_p)
    fprintf (stderr, "MOVE: %06X -> %06X : %X\n", old_addr, mem_addr, x);
  SET_C(0);
  SET_V(0);
  SET_Z((mem_data & size->mask) == 0);
  SET_N(mem_data & size->sign);
}

DEFINSN_BWL(move)

static void insn_movea(const struct s *size) {
  AREG = size->read_ea();
}

DEFINSN_WL(movea)

static void insn_move_from_sr(void) {
  TRACE();
  write_w_ea(SR);
}

static void insn_moveq(void) {
  TRACE();
  DREG = EXTB(IRD);
}

static void insn_move_to_ccr(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_move_to_sr(void) {
  TRACE();
  SR = read_w_ea();
  add_cycles(4);
}

static void insn_muls(void) {
  TRACE();
  int r = REG_FIELD;
  s16 src = read_w_ea();
  s16 dst = dreg[r] & 0xFFFF;
  dreg[r] = (s32)src * (s32)dst;
}

static void insn_mulu(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_nbcd(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_neg(const struct s *size) {
  u32 dst = size->read_ea();
  u32 result = size->alu(SUB, dst, 0);
  size->modify_ea(result);
}

DEFINSN_BWL(neg)

static void insn_negx(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_not(const struct s *size) {
  u32 dst = size->read_ea();
  size->modify_ea(size->alu(EOR, 0xFFFFFFFF, dst));
}

DEFINSN_BWL(not)

static void insn_or_r(const struct s *size) {
  int r = REG_FIELD;
  u32 src = size->read_ea();
  u32 dst = dreg[r];
  IRD = r;
  size->modify_ea(size->alu(IOR, src, dst));
}

static void insn_or_m(const struct s *size) {
  u32 src = DREG;
  u32 dst = size->read_ea();
  size->modify_ea(size->alu(IOR, src, dst));
}

DEFINSN_BWL(or_r)
DEFINSN_BWL(or_m)

static void insn_ori_ccr(void) {
  TRACE();
  fetch();
  SR |= IR & 0xFF;
}

static void insn_ori_sr(void) {
  TRACE();
  fetch();
  SR |= IR;
}

static void insn_shiftl_b(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_shiftl_w(void) {
  TRACE();
  int r = EA_R_FIELD;
  int n = REG_FIELD;
  int i;
  if (IRD & 040)
    n = dreg[n] % 64;
  else if (n == 0)
    n = 8;
  add_cycles(2*n + 4);
  u16 x = dreg[r], carry;
  switch (IRD & 030) {
  case 000: //asl
  case 010: //lsl
    for (i = 0; i < n; i++) {
      carry = x & 0x8000;
      x <<= 1;
    }
    break;
  case 020: //roxl
    UNIMPLEMENTED();
  case 030: //rol
    for (i = 0; i < n; i++) {
      carry = x & 0x8000;
      x = (x << 1) | (x >> 15);
    }
    break;
  }
  dreg[r] = (dreg[r] & 0xFFFF0000) | x;
  SET_C(carry);
  SET_Z(x == 0);
  SET_N(x & 0x8000);
}

static void insn_shiftl_l(void) {
  TRACE();
  int r = EA_R_FIELD;
  int n = REG_FIELD;
  int i;
  if (IRD & 040)
    n = dreg[n] % 64;
  else if (n == 0)
    n = 8;
  add_cycles(2*n + 4);
  u32 x = dreg[r], carry;
  switch (IRD & 030) {
  case 000: //asl
  case 010: //lsl
    for (i = 0; i < n; i++) {
      carry = x & 0x80000000;
      x <<= 1;
    }
    break;
  case 020: //roxl
    UNIMPLEMENTED();
  case 030: //rol
    for (i = 0; i < n; i++) {
      carry = x & 0x80000000;
      x = (x << 1) | (x >> 31);
    }
    break;
  }
  dreg[r] = x;
  SET_C(carry);
  SET_Z(x == 0);
  SET_N(x & 0x8000);
}

static void insn_shiftl_m(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_shiftr_b(void) {
  TRACE();
  int r = EA_R_FIELD;
  int n = REG_FIELD;
  int i;
  u8 x, carry;
  if (IRD & 040)
    n = dreg[n] % 64;
  else if (n == 0)
    n = 8;
  x = dreg[r] & 0xFF;
  add_cycles(2*n + 2);
  switch (IRD & 030) {
  case 000: //asr
    for (i = 0; i < n; i++) {
      carry = x & 1;
      x = (x >> 1) | (x & 0x80);
    }
    break;
  case 010: //lsr
    for (i = 0; i < n; i++) {
      carry = x & 1;
      x >>= 1;
    }
    break;
  case 020: //roxr
    UNIMPLEMENTED();
  case 030: //ror
    for (i = 0; i < n; i++) {
      carry = x & 1;
      x = (x >> 1) | (x << 7);
    }
    break;
  }
  dreg[r] = (dreg[r] & 0xFFFFFF00) | x;
  SET_C(carry);
  SET_Z(x == 0);
  SET_N(x & 0x80);
}

static void insn_shiftr_w(void) {
  TRACE();
  int r = EA_R_FIELD;
  int n = REG_FIELD;
  int i;
  u16 x, carry;
  if (IRD & 040)
    n = dreg[n] % 64;
  else if (n == 0)
    n = 8;
  add_cycles(2*n + 2);
  x = dreg[r] & 0xFFFF;
  switch (IRD & 030) {
  case 000: //asr
    for (i = 0; i < n; i++) {
      carry = x & 1;
      x = (x >> 1) | (x & 0x8000);
    }
    break;
  case 010: //lsr
    for (i = 0; i < n; i++) {
      carry = x & 1;
      x >>= 1;
    }
    break;
  case 020: //roxr
    UNIMPLEMENTED();
  case 030: //ror
    for (i = 0; i < n; i++) {
      carry = x & 1;
      x = (x >> 1) | (x << 15);
    }
    break;
  }
  dreg[r] = (dreg[r] & 0xFFFF0000) | x;
  SET_C(carry);
  SET_Z(x == 0);
  SET_N(x & 0x8000);
}

static void insn_shiftr_l(void) {
  TRACE();
  int r = EA_R_FIELD;
  int n = REG_FIELD;
  int i;
  if (IRD & 040)
    n = dreg[n] % 64;
  else if (n == 0)
    n = 8;
  add_cycles(2*n + 4);
  u32 x = dreg[r], carry;
  switch (IRD & 030) {
  case 000: //asr
    for (i = 0; i < n; i++) {
      carry = x & 1;
      x = (x >> 1) | (x & 0x80000000);
    }
    break;
  case 010: //lsr
    for (i = 0; i < n; i++) {
      carry = x & 1;
      x >>= 1;
    }
    break;
  case 020: //roxr
    UNIMPLEMENTED();
  case 030: //ror
    for (i = 0; i < n; i++) {
      carry = x & 1;
      x = (x >> 1) | (x << 31);
    }
    break;
  }
  dreg[r] = x;
  SET_C(carry);
  SET_Z(x == 0);
  SET_N(x & 0x80000000);
}

static void insn_shiftr_m(void) {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_sub(const struct s *size) {
  int r = REG_FIELD;
  u32 src, dst;
  if (PC == 0x3bf8+4)
    fprintf(stderr, "sub %x,%x\n", dreg[2], dreg[1]);
  if (IRD & 0400) {
    src = dreg[r];
    dst = size->read_ea();
  } else {
    src = size->read_ea();
    dst = dreg[r];
    IRD = r;
  }
  size->modify_ea(size->alu(SUB, src, dst));
}

DEFINSN_BWL(sub)

static void insn_subaw(void) {
  TRACE();
  AREG -= EXTW(read_w_ea());
}

static void insn_subal(void) {
  TRACE();
  AREG -= read_l_ea();
}

static void insn_subi(const struct s *size) {
  CHECK_ALUI_EA(insn_illegal, insn_illegal);
  u32 src = size->read_imm();
  u32 dst = size->read_ea();
  size->modify_ea(size->alu(SUB, src, dst));
}
  
DEFINSN_BWL(subi)

static void insn_subq(const struct s *size) {
  u32 src = REG_FIELD;
  u32 dst;
  if ((IRD & 070) == 010)
    dst = areg[EA_R_FIELD];
  else
    dst = size->read_ea();
  if (src == 0)
    src = 8;
  size->modify_ea(size_l.alu(SUB, src, dst));
}

DEFINSN_BWL(subq)

static void insn_swap() {
  int r = EA_R_FIELD;
  dreg[r] = (dreg[r] >> 16) | (dreg[r] << 16);
  SET_C(0);
  SET_V(0);
  SET_Z(dreg[r] == 0);
  SET_Z(dreg[r] & 0x80000000);
}

static void insn_pea() {
  TRACE();
  UNIMPLEMENTED();
}

static void insn_swap_or_pea(void) {
  if((IRD & 0177770) == 044100)
    insn_swap();
  else
    insn_pea();
}

static void insn_tst(const struct s *size) {
  u32 dst = size->read_ea();
  size->alu(SUB, 0, dst);
}

DEFINSN_BWL(tst)

static void insn_ori(const struct s *size) {
  CHECK_ALUI_EA(insn_ori_ccr, insn_ori_sr);
  u32 src = size->read_imm();
  u32 dst = size->read_ea();
  size->modify_ea(size->alu(IOR, src, dst));
}

DEFINSN_BWL(ori)

static insn_fn dispatch[1024] = {
  /* 0000000000 */ insn_orib, insn_oriw, insn_oril, insn_illegal,
  /* 0000xxx100 */ insn_btst, insn_bchg, insn_bclr, insn_bset,
  /* 0000001000 */ insn_andib, insn_andiw, insn_andil, insn_illegal,
  /* 0000xxx100 */ insn_btst, insn_bchg, insn_bclr, insn_bset,
  /* 0000010000 */ insn_subib, insn_subiw, insn_subil, insn_illegal,
  /* 0000xxx100 */ insn_btst, insn_bchg, insn_bclr, insn_bset,
  /* 0000011000 */ insn_addib, insn_addiw, insn_addil, insn_illegal,
  /* 0000xxx100 */ insn_btst, insn_bchg, insn_bclr, insn_bset,
  /* 0000100000 */ insn_btsti, insn_bchgi, insn_bclri, insn_bseti,
  /* 0000xxx100 */ insn_btst, insn_bchg, insn_bclr, insn_bset,
  /* 0000101000 */ insn_eorib, insn_eoriw, insn_eoril, insn_illegal,
  /* 0000xxx100 */ insn_btst, insn_bchg, insn_bclr, insn_bset,
  /* 0000110000 */ insn_cmpib, insn_cmpiw, insn_cmpil, insn_illegal,
  /* 0000xxx100 */ insn_btst, insn_bchg, insn_bclr, insn_bset,
  /* 0000111000 */ insn_cmpib, insn_cmpiw, insn_cmpil, insn_illegal,
  /* 0000xxx100 */ insn_btst, insn_bchg, insn_bclr, insn_bset,
 
  /* 0001xxxxxx */ insn_moveb, insn_illegal, insn_moveb, insn_moveb,
  /* 0001xxxxxx */ insn_moveb, insn_moveb, insn_moveb, insn_moveb,
  /* 0001xxxxxx */ insn_moveb, insn_illegal, insn_moveb, insn_moveb,
  /* 0001xxxxxx */ insn_moveb, insn_moveb, insn_moveb, insn_moveb,
  /* 0001xxxxxx */ insn_moveb, insn_illegal, insn_moveb, insn_moveb,
  /* 0001xxxxxx */ insn_moveb, insn_moveb, insn_moveb, insn_illegal,
  /* 0001xxxxxx */ insn_moveb, insn_illegal, insn_moveb, insn_moveb,
  /* 0001xxxxxx */ insn_moveb, insn_moveb, insn_moveb, insn_illegal,
  /* 0001xxxxxx */ insn_moveb, insn_illegal, insn_moveb, insn_moveb,
  /* 0001xxxxxx */ insn_moveb, insn_moveb, insn_moveb, insn_illegal,
  /* 0001xxxxxx */ insn_moveb, insn_illegal, insn_moveb, insn_moveb,
  /* 0001xxxxxx */ insn_moveb, insn_moveb, insn_moveb, insn_illegal,
  /* 0001xxxxxx */ insn_moveb, insn_illegal, insn_moveb, insn_moveb,
  /* 0001xxxxxx */ insn_moveb, insn_moveb, insn_moveb, insn_illegal,
  /* 0001xxxxxx */ insn_moveb, insn_illegal, insn_moveb, insn_moveb,
  /* 0001xxxxxx */ insn_moveb, insn_moveb, insn_moveb, insn_illegal,

  /* 0010xxxxxx */ insn_movel, insn_moveal, insn_movel, insn_movel,
  /* 0010xxxxxx */ insn_movel, insn_movel, insn_movel, insn_movel,
  /* 0010xxxxxx */ insn_movel, insn_moveal, insn_movel, insn_movel,
  /* 0010xxxxxx */ insn_movel, insn_movel, insn_movel, insn_movel,
  /* 0010xxxxxx */ insn_movel, insn_moveal, insn_movel, insn_movel,
  /* 0010xxxxxx */ insn_movel, insn_movel, insn_movel, insn_illegal,
  /* 0010xxxxxx */ insn_movel, insn_moveal, insn_movel, insn_movel,
  /* 0010xxxxxx */ insn_movel, insn_movel, insn_movel, insn_illegal,
  /* 0010xxxxxx */ insn_movel, insn_moveal, insn_movel, insn_movel,
  /* 0010xxxxxx */ insn_movel, insn_movel, insn_movel, insn_illegal,
  /* 0010xxxxxx */ insn_movel, insn_moveal, insn_movel, insn_movel,
  /* 0010xxxxxx */ insn_movel, insn_movel, insn_movel, insn_illegal,
  /* 0010xxxxxx */ insn_movel, insn_moveal, insn_movel, insn_movel,
  /* 0010xxxxxx */ insn_movel, insn_movel, insn_movel, insn_illegal,
  /* 0010xxxxxx */ insn_movel, insn_moveal, insn_movel, insn_movel,
  /* 0010xxxxxx */ insn_movel, insn_movel, insn_movel, insn_illegal,

  /* 0011xxxxxx */ insn_movew, insn_moveaw, insn_movew, insn_movew,
  /* 0011xxxxxx */ insn_movew, insn_movew, insn_movew, insn_movew,
  /* 0011xxxxxx */ insn_movew, insn_moveaw, insn_movew, insn_movew,
  /* 0011xxxxxx */ insn_movew, insn_movew, insn_movew, insn_movew,
  /* 0011xxxxxx */ insn_movew, insn_moveaw, insn_movew, insn_movew,
  /* 0011xxxxxx */ insn_movew, insn_movew, insn_movew, insn_illegal,
  /* 0011xxxxxx */ insn_movew, insn_moveaw, insn_movew, insn_movew,
  /* 0011xxxxxx */ insn_movew, insn_movew, insn_movew, insn_illegal,
  /* 0011xxxxxx */ insn_movew, insn_moveaw, insn_movew, insn_movew,
  /* 0011xxxxxx */ insn_movew, insn_movew, insn_movew, insn_illegal,
  /* 0011xxxxxx */ insn_movew, insn_moveaw, insn_movew, insn_movew,
  /* 0011xxxxxx */ insn_movew, insn_movew, insn_movew, insn_illegal,
  /* 0011xxxxxx */ insn_movew, insn_moveaw, insn_movew, insn_movew,
  /* 0011xxxxxx */ insn_movew, insn_movew, insn_movew, insn_illegal,
  /* 0011xxxxxx */ insn_movew, insn_moveaw, insn_movew, insn_movew,
  /* 0011xxxxxx */ insn_movew, insn_movew, insn_movew, insn_illegal,

  /* 01000000xx */ insn_negx, insn_negx, insn_negx, insn_move_from_sr,
  /* 0100xxx1xx */ insn_chk, insn_illegal, insn_chk, insn_lea,
  /* 01000010xx */ insn_clrb, insn_clrw, insn_clrl, insn_illegal,
  /* 0100xxx1xx */ insn_chk, insn_illegal, insn_chk, insn_lea,
  /* 01000100xx */ insn_negb, insn_negw, insn_negl, insn_move_to_ccr,
  /* 0100xxx1xx */ insn_chk, insn_illegal, insn_chk, insn_lea,
  /* 01000110xx */ insn_notb, insn_notw, insn_notl, insn_move_to_sr,
  /* 0100xxx1xx */ insn_chk, insn_illegal, insn_chk, insn_lea,
  /* 0100100000 */ insn_nbcd, insn_swap_or_pea, insn_extb, insn_extw,
  /* 0100xxx1xx */ insn_chk, insn_illegal, insn_chk, insn_lea,
  /* 01001010xx */ insn_tstb, insn_tstw, insn_tstl, insn_illegal_or_tas,
  /* 0100xxx1xx */ insn_chk, insn_illegal, insn_chk, insn_lea,
  /* 01001100xx */ insn_illegal, insn_illegal, insn_movemw_mr, insn_moveml_mr,
  /* 0100xxx1xx */ insn_chk, insn_illegal, insn_chk, insn_lea,
  /* 0100111001 */ insn_illegal, insn_misc, insn_jsr, insn_jmp,
  /* 0100xxx1xx */ insn_chk, insn_illegal, insn_chk, insn_lea,

  /* 0101xxx0ss */ insn_addqb, insn_addqw, insn_addql, insn_dbcc_or_scc,
  /* 0101xxx1ss */ insn_subqb, insn_subqw, insn_subql, insn_dbcc_or_scc,
  /* 0101xxx0ss */ insn_addqb, insn_addqw, insn_addql, insn_dbcc_or_scc,
  /* 0101xxx1ss */ insn_subqb, insn_subqw, insn_subql, insn_dbcc_or_scc,
  /* 0101xxx0ss */ insn_addqb, insn_addqw, insn_addql, insn_dbcc_or_scc,
  /* 0101xxx1ss */ insn_subqb, insn_subqw, insn_subql, insn_dbcc_or_scc,
  /* 0101xxx0ss */ insn_addqb, insn_addqw, insn_addql, insn_dbcc_or_scc,
  /* 0101xxx1ss */ insn_subqb, insn_subqw, insn_subql, insn_dbcc_or_scc,
  /* 0101xxx0ss */ insn_addqb, insn_addqw, insn_addql, insn_dbcc_or_scc,
  /* 0101xxx1ss */ insn_subqb, insn_subqw, insn_subql, insn_dbcc_or_scc,
  /* 0101xxx0ss */ insn_addqb, insn_addqw, insn_addql, insn_dbcc_or_scc,
  /* 0101xxx1ss */ insn_subqb, insn_subqw, insn_subql, insn_dbcc_or_scc,
  /* 0101xxx0ss */ insn_addqb, insn_addqw, insn_addql, insn_dbcc_or_scc,
  /* 0101xxx1ss */ insn_subqb, insn_subqw, insn_subql, insn_dbcc_or_scc,
  /* 0101xxx0ss */ insn_addqb, insn_addqw, insn_addql, insn_dbcc_or_scc,
  /* 0101xxx1ss */ insn_subqb, insn_subqw, insn_subql, insn_dbcc_or_scc,

  /* 01100000xx */ insn_bra, insn_bra, insn_bra, insn_bra,
  /* 01100001xx */ insn_bsr, insn_bsr, insn_bsr, insn_bsr,
  /* 0110xxxxxx */ insn_bcc, insn_bcc, insn_bcc, insn_bcc,
  /* 0110xxxxxx */ insn_bcc, insn_bcc, insn_bcc, insn_bcc,
  /* 0110xxxxxx */ insn_bcc, insn_bcc, insn_bcc, insn_bcc,
  /* 0110xxxxxx */ insn_bcc, insn_bcc, insn_bcc, insn_bcc,
  /* 0110xxxxxx */ insn_bcc, insn_bcc, insn_bcc, insn_bcc,
  /* 0110xxxxxx */ insn_bcc, insn_bcc, insn_bcc, insn_bcc,
  /* 0110xxxxxx */ insn_bcc, insn_bcc, insn_bcc, insn_bcc,
  /* 0110xxxxxx */ insn_bcc, insn_bcc, insn_bcc, insn_bcc,
  /* 0110xxxxxx */ insn_bcc, insn_bcc, insn_bcc, insn_bcc,
  /* 0110xxxxxx */ insn_bcc, insn_bcc, insn_bcc, insn_bcc,
  /* 0110xxxxxx */ insn_bcc, insn_bcc, insn_bcc, insn_bcc,
  /* 0110xxxxxx */ insn_bcc, insn_bcc, insn_bcc, insn_bcc,
  /* 0110xxxxxx */ insn_bcc, insn_bcc, insn_bcc, insn_bcc,
  /* 0110xxxxxx */ insn_bcc, insn_bcc, insn_bcc, insn_bcc,

  /* 0111xxx0xx */ insn_moveq, insn_moveq, insn_moveq, insn_moveq,
  /* 0111xxx1xx */ insn_illegal, insn_illegal, insn_illegal, insn_illegal,
  /* 0111xxx0xx */ insn_moveq, insn_moveq, insn_moveq, insn_moveq,
  /* 0111xxx1xx */ insn_illegal, insn_illegal, insn_illegal, insn_illegal,
  /* 0111xxx0xx */ insn_moveq, insn_moveq, insn_moveq, insn_moveq,
  /* 0111xxx1xx */ insn_illegal, insn_illegal, insn_illegal, insn_illegal,
  /* 0111xxx0xx */ insn_moveq, insn_moveq, insn_moveq, insn_moveq,
  /* 0111xxx1xx */ insn_illegal, insn_illegal, insn_illegal, insn_illegal,
  /* 0111xxx0xx */ insn_moveq, insn_moveq, insn_moveq, insn_moveq,
  /* 0111xxx1xx */ insn_illegal, insn_illegal, insn_illegal, insn_illegal,
  /* 0111xxx0xx */ insn_moveq, insn_moveq, insn_moveq, insn_moveq,
  /* 0111xxx1xx */ insn_illegal, insn_illegal, insn_illegal, insn_illegal,
  /* 0111xxx0xx */ insn_moveq, insn_moveq, insn_moveq, insn_moveq,
  /* 0111xxx1xx */ insn_illegal, insn_illegal, insn_illegal, insn_illegal,
  /* 0111xxx0xx */ insn_moveq, insn_moveq, insn_moveq, insn_moveq,
  /* 0111xxx1xx */ insn_illegal, insn_illegal, insn_illegal, insn_illegal,

  /* 1000xxx0xx */ insn_or_rb, insn_or_rw, insn_or_rl, insn_divu,
  /* 1000xxx1xx */ insn_or_mb, insn_or_mw, insn_or_ml, insn_divs,
  /* 1000xxx0xx */ insn_or_rb, insn_or_rw, insn_or_rl, insn_divu,
  /* 1000xxx1xx */ insn_or_mb, insn_or_mw, insn_or_ml, insn_divs,
  /* 1000xxx0xx */ insn_or_rb, insn_or_rw, insn_or_rl, insn_divu,
  /* 1000xxx1xx */ insn_or_mb, insn_or_mw, insn_or_ml, insn_divs,
  /* 1000xxx0xx */ insn_or_rb, insn_or_rw, insn_or_rl, insn_divu,
  /* 1000xxx1xx */ insn_or_mb, insn_or_mw, insn_or_ml, insn_divs,
  /* 1000xxx0xx */ insn_or_rb, insn_or_rw, insn_or_rl, insn_divu,
  /* 1000xxx1xx */ insn_or_mb, insn_or_mw, insn_or_ml, insn_divs,
  /* 1000xxx0xx */ insn_or_rb, insn_or_rw, insn_or_rl, insn_divu,
  /* 1000xxx1xx */ insn_or_mb, insn_or_mw, insn_or_ml, insn_divs,
  /* 1000xxx0xx */ insn_or_rb, insn_or_rw, insn_or_rl, insn_divu,
  /* 1000xxx1xx */ insn_or_mb, insn_or_mw, insn_or_ml, insn_divs,
  /* 1000xxx0xx */ insn_or_rb, insn_or_rw, insn_or_rl, insn_divu,
  /* 1000xxx1xx */ insn_or_mb, insn_or_mw, insn_or_ml, insn_divs,

  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subaw,
  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subal,
  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subaw,
  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subal,
  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subaw,
  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subal,
  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subaw,
  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subal,
  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subaw,
  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subal,
  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subaw,
  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subal,
  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subaw,
  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subal,
  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subaw,
  /* 1001xxxxxx */ insn_subb, insn_subw, insn_subl, insn_subal,

  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,
  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,
  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,
  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,
  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,
  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,
  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,
  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,
  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,
  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,
  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,
  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,
  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,
  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,
  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,
  /* 1010xxxxxx */ insn_linea, insn_linea, insn_linea, insn_linea,

  /* 1011xxx0xx */ insn_cmpb, insn_cmpw, insn_cmpl, insn_cmpaw,
  /* 1011xxx1xx */ insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpal,
  /* 1011xxx0xx */ insn_cmpb, insn_cmpw, insn_cmpl, insn_cmpaw,
  /* 1011xxx1xx */ insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpal,
  /* 1011xxx0xx */ insn_cmpb, insn_cmpw, insn_cmpl, insn_cmpaw,
  /* 1011xxx1xx */ insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpal,
  /* 1011xxx0xx */ insn_cmpb, insn_cmpw, insn_cmpl, insn_cmpaw,
  /* 1011xxx1xx */ insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpal,
  /* 1011xxx0xx */ insn_cmpb, insn_cmpw, insn_cmpl, insn_cmpaw,
  /* 1011xxx1xx */ insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpal,
  /* 1011xxx0xx */ insn_cmpb, insn_cmpw, insn_cmpl, insn_cmpaw,
  /* 1011xxx1xx */ insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpal,
  /* 1011xxx0xx */ insn_cmpb, insn_cmpw, insn_cmpl, insn_cmpaw,
  /* 1011xxx1xx */ insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpal,
  /* 1011xxx0xx */ insn_cmpb, insn_cmpw, insn_cmpl, insn_cmpaw,
  /* 1011xxx1xx */ insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpm_or_eor, insn_cmpal,

  /* 1100xxx0xx */ insn_and_rb, insn_and_rw, insn_and_rl, insn_mulu,
  /* 1100xxx1xx */ insn_and_mb, insn_and_mw, insn_and_ml, insn_muls,
  /* 1100xxx0xx */ insn_and_rb, insn_and_rw, insn_and_rl, insn_mulu,
  /* 1100xxx1xx */ insn_and_mb, insn_and_mw, insn_and_ml, insn_muls,
  /* 1100xxx0xx */ insn_and_rb, insn_and_rw, insn_and_rl, insn_mulu,
  /* 1100xxx1xx */ insn_and_mb, insn_and_mw, insn_and_ml, insn_muls,
  /* 1100xxx0xx */ insn_and_rb, insn_and_rw, insn_and_rl, insn_mulu,
  /* 1100xxx1xx */ insn_and_mb, insn_and_mw, insn_and_ml, insn_muls,
  /* 1100xxx0xx */ insn_and_rb, insn_and_rw, insn_and_rl, insn_mulu,
  /* 1100xxx1xx */ insn_and_mb, insn_and_mw, insn_and_ml, insn_muls,
  /* 1100xxx0xx */ insn_and_rb, insn_and_rw, insn_and_rl, insn_mulu,
  /* 1100xxx1xx */ insn_and_mb, insn_and_mw, insn_and_ml, insn_muls,
  /* 1100xxx0xx */ insn_and_rb, insn_and_rw, insn_and_rl, insn_mulu,
  /* 1100xxx1xx */ insn_and_mb, insn_and_mw, insn_and_ml, insn_muls,
  /* 1100xxx0xx */ insn_and_rb, insn_and_rw, insn_and_rl, insn_mulu,
  /* 1100xxx1xx */ insn_and_mb, insn_and_mw, insn_and_ml, insn_muls,

  /* 1101xxxxxx */ insn_add_rb, insn_add_rw, insn_add_rl, insn_addaw,
  /* 1101xxxxxx */ insn_add_mb, insn_add_mw, insn_add_ml, insn_addal,
  /* 1101xxxxxx */ insn_add_rb, insn_add_rw, insn_add_rl, insn_addaw,
  /* 1101xxxxxx */ insn_add_mb, insn_add_mw, insn_add_ml, insn_addal,
  /* 1101xxxxxx */ insn_add_rb, insn_add_rw, insn_add_rl, insn_addaw,
  /* 1101xxxxxx */ insn_add_mb, insn_add_mw, insn_add_ml, insn_addal,
  /* 1101xxxxxx */ insn_add_rb, insn_add_rw, insn_add_rl, insn_addaw,
  /* 1101xxxxxx */ insn_add_mb, insn_add_mw, insn_add_ml, insn_addal,
  /* 1101xxxxxx */ insn_add_rb, insn_add_rw, insn_add_rl, insn_addaw,
  /* 1101xxxxxx */ insn_add_mb, insn_add_mw, insn_add_ml, insn_addal,
  /* 1101xxxxxx */ insn_add_rb, insn_add_rw, insn_add_rl, insn_addaw,
  /* 1101xxxxxx */ insn_add_mb, insn_add_mw, insn_add_ml, insn_addal,
  /* 1101xxxxxx */ insn_add_rb, insn_add_rw, insn_add_rl, insn_addaw,
  /* 1101xxxxxx */ insn_add_mb, insn_add_mw, insn_add_ml, insn_addal,
  /* 1101xxxxxx */ insn_add_rb, insn_add_rw, insn_add_rl, insn_addaw,
  /* 1101xxxxxx */ insn_add_mb, insn_add_mw, insn_add_ml, insn_addal,

  /* 1110xxx0xx */ insn_shiftr_b, insn_shiftr_w, insn_shiftr_l, insn_shiftr_m,
  /* 1110xxx1xx */ insn_shiftl_b, insn_shiftl_w, insn_shiftl_l, insn_shiftl_m,
  /* 1110xxx0xx */ insn_shiftr_b, insn_shiftr_w, insn_shiftr_l, insn_shiftr_m,
  /* 1110xxx1xx */ insn_shiftl_b, insn_shiftl_w, insn_shiftl_l, insn_shiftl_m,
  /* 1110xxx0xx */ insn_shiftr_b, insn_shiftr_w, insn_shiftr_l, insn_shiftr_m,
  /* 1110xxx1xx */ insn_shiftl_b, insn_shiftl_w, insn_shiftl_l, insn_shiftl_m,
  /* 1110xxx0xx */ insn_shiftr_b, insn_shiftr_w, insn_shiftr_l, insn_shiftr_m,
  /* 1110xxx1xx */ insn_shiftl_b, insn_shiftl_w, insn_shiftl_l, insn_shiftl_m,
  /* 1110xxx0xx */ insn_shiftr_b, insn_shiftr_w, insn_shiftr_l, insn_shiftr_m,
  /* 1110xxx1xx */ insn_shiftl_b, insn_shiftl_w, insn_shiftl_l, insn_shiftl_m,
  /* 1110xxx0xx */ insn_shiftr_b, insn_shiftr_w, insn_shiftr_l, insn_shiftr_m,
  /* 1110xxx1xx */ insn_shiftl_b, insn_shiftl_w, insn_shiftl_l, insn_shiftl_m,
  /* 1110xxx0xx */ insn_shiftr_b, insn_shiftr_w, insn_shiftr_l, insn_shiftr_m,
  /* 1110xxx1xx */ insn_shiftl_b, insn_shiftl_w, insn_shiftl_l, insn_shiftl_m,
  /* 1110xxx0xx */ insn_shiftr_b, insn_shiftr_w, insn_shiftr_l, insn_shiftr_m,
  /* 1110xxx1xx */ insn_shiftl_b, insn_shiftl_w, insn_shiftl_l, insn_shiftl_m,

  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef,
  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef,
  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef,
  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef,
  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef,
  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef,
  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef,
  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef,
  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef,
  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef,
  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef,
  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef,
  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef,
  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef,
  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef,
  /* 1111xxxxxx */ insn_linef, insn_linef, insn_linef, insn_linef
};

void reset(void) {
  insn_reset();
  fetch();
  fetch();
}

void execute(void) {
#if 0
  if (PC-4 == 0x116c)
    trace_p = 1;
#endif
  IRD = IR;
  dispatch[IRD >> 6]();
  fetch();
}

static void step(void) {
  unsigned long long c0 = cycles;
  execute();
  //fprintf(stderr, "Cycles: %llu (%llu)\n", cycles - c0, cycles);
  SDL_LockMutex(event_mutex);
  events(cycles - c0);
  SDL_UnlockMutex(event_mutex);
  SDL_LockMutex(ipl_mutex);
  if (ipl == 7 || ipl > ((SR >> 8) & 7))
    interrupt();
  SDL_UnlockMutex(ipl_mutex);
}

static void init_rom(const char *file) {
  FILE *f = fopen(file, "rb");
  ssize_t n;
  n = fread(rom, 1, sizeof rom, f);
  if (n != sizeof rom)
    exit(1);
  fclose(f);
  memcpy(ram, rom, 8);
}

static u8 read_b_bus_error(u32 a) {
  printf("Bus error: %06X\n", a);
  retry_finite_counter++;
  retry_infinite_counter++;
  return 0;
}

static void write_b_bus_error(u32 a, u8 x) {
  printf("Bus Error: %06X\n", a);
  retry_finite_counter++;
  retry_infinite_counter++;
}

SAME_READ_W(bus_error)
SAME_WRITE_W(bus_error)

u8 read_b_ram(u32 a) {
  return ram[a];
}

void write_b_ram(u32 a, u8 x) {
  ram[a] = x;
}

DEFAULT_READ_W(ram)
DEFAULT_WRITE_W(ram)

u8 read_b_rom(u32 a) {
  return rom[a - 0x180000];
}

void write_b_rom(u32 a, u8 x) {
  printf("Write to ROM.\n");
  exit(1);
}

DEFAULT_READ_W(rom)
SAME_WRITE_W(rom)

static u8 read_b_retry_finite(u32 a) {
  fprintf(stderr, "Read RETRY_FINITE: %06X.\n", a);
  retry_finite_counter = 0;
  return 0;
}

static void write_b_retry_finite(u32 a, u8 x) {
  fprintf(stderr, "Write RETRY_FINITE: %06X %02X\n", a, x);
}

SAME_READ_W(retry_finite)
SAME_WRITE_W(retry_finite)

static u8 read_b_retry_infinite(u32 a) {
  fprintf(stderr, "Read RETRY_INFINITE: %06X.\n", a);
  retry_infinite_counter = 0;
  return 0;
}

static void write_b_retry_infinite(u32 a, u8 x) {
  fprintf(stderr, "Write RETRY_INFINITE: %06X %02X\n", a, x);
}

SAME_READ_W(retry_infinite);
SAME_WRITE_W(retry_infinite);

static u8 read_b_vsync(u32 a) {
  irq_set(6, 0);
  return 0;
}

static void write_b_vsync(u32 a, u8 x) {
}

static u8 read_b_crt_controller(u32 a) {
  switch (a) {
  case 01: return mc6845_addr; break;
  case 03: return mc6845_reg[mc6845_addr]; break;
  }
  return 0;
}

static void write_b_crt_controller(u32 a, u8 x) {
  switch (a) {
  case 01: mc6845_addr = x; break;
  case 03: mc6845_reg[mc6845_addr] = x; break;
  }
}

static u8 read_b_leds(u32 a) {
  return 0;
}

static void write_b_leds(u32 a, u8 x) {
  fprintf(stderr, "LED %c%c%c%c%c\n",
	  (x & 0x01) ? '.' : 'R',  // Red 4
	  (x & 0x02) ? '.' : 'R',  // Red 3
	  (x & 0x04) ? '.' : 'R',  // Red 2
	  (x & 0x08) ? '.' : 'R',  // Red 1
	  (x & 0x10) ? '-' : 'G'); // Green
}

static u8 read_b_io(u32 a) {
  switch (a & 0xFE) {
  case 0x00: case 0x02: case 0x04: case 0x06:
    return read_b_keyboard(a & 7);
  case 0x20: case 0x22: case 0x24: case 0x26:
    return read_b_tablet(a & 7);
  case 0x40:
    return read_b_fibre_control(a & 1);
  case 0x60:
    return read_b_mouse(a & 1);
  case 0x80:
    return read_b_leds(a & 1);
  case 0xA0: case 0xA2:
    return read_b_crt_controller(a & 3);
  case 0xC0:
    return read_b_status(a & 1);
  case 0xE0:
    return read_b_vsync(a & 1);
  default:
    return read_b_bus_error(a);
  }
}

static void write_b_io(u32 a, u8 x) {
  switch (a & 0xFE) {
  case 0x00: case 0x02: case 0x04: case 0x06:
    write_b_keyboard(a & 7, x); return;
  case 0x20: case 0x22: case 0x24: case 0x26:
    write_b_tablet(a & 7, x); return;
  case 0x40:
    write_b_fibre_control(a, x); return;
  case 0x60:
    write_b_bus_error(a, x); return;
  case 0x80:
    write_b_leds(a & 1, x); return;
  case 0xA0: case 0xA2:
    write_b_crt_controller(a & 3, x); return;
  case 0xC0:
    write_b_status(a & 1, x); return;
  case 0xE0:
    write_b_vsync(a & 1, x); return;
  default:
    write_b_bus_error(a, x); return;
  }
}

static u16 read_w_io(u32 a) {
  switch (a & 0xFE) {
  case 0x00: case 0x02: case 0x04: case 0x06:
    return read_b_keyboard(a & 7);
  case 0x20: case 0x22: case 0x24: case 0x26:
    return read_b_tablet(a & 7);
  case 0x40:
    return read_b_fibre_control(a & 1);
  case 0x60:
    return read_w_mouse(a & 1);
  case 0x80:
    return read_b_leds(a & 1);
  case 0xA0: case 0xA2:
    return read_b_crt_controller(a & 3);
  case 0xC0:
    return read_b_status(a & 1);
  case 0xE0:
    return read_b_vsync(a & 1);
  default:
    return read_w_bus_error(a);
  }
}

static void write_w_io(u32 a, u16 x) {
  fprintf(stderr, "Write word to I/O region.\n");
  exit(1);
}

#define DEF_REGION(START, SIZE, DEVICE)		\
  mem_region(START, SIZE,			\
	     read_b_##DEVICE, write_b_##DEVICE,	\
	     read_w_##DEVICE, write_w_##DEVICE)

static void init_regions(void) {
  DEF_REGION(0x000000, 16*1024*1024, bus_error);
  DEF_REGION(0x000000, 128*1024, ram);
  DEF_REGION(0x080000, 256*1024, unibus);
  DEF_REGION(0x0C0000,        2, retry_finite);
  DEF_REGION(0x0E0000,        2, retry_infinite);
  DEF_REGION(0x100000, 512*1024, fb);
  DEF_REGION(0x180000,  16*1024, rom);
  DEF_REGION(0x280000,        2, bba_control);
  DEF_REGION(0x300000,      512, bba_scratchpad);
  DEF_REGION(0x480000,       16, host_csr);
  DEF_REGION(0x4A0000,       16, host_loopback);
  DEF_REGION(0x4C0000,        2, host_interrupt);
  DEF_REGION(0x800000,     0xE2, io);
}

static void vsync_callback(void);
static EVENT(vsync_event, vsync_callback);

static void vsync_callback(void) {
  static Uint32 then = 0;
  static Uint32 ms, now;
  extern void refresh (void);
  refresh();
  now = SDL_GetTicks();
  ms = now - then;
  if (ms < 17) {
    SDL_Delay(17 - ms);
    now = SDL_GetTicks();
  }
  then = now;
  irq_set(6, 1);
  SDL_LockMutex(event_mutex);
  add_event(10000000/60, &vsync_event);
  SDL_UnlockMutex(event_mutex);
}

static int cputhread(void *arg) {
  init_regions();
  init_rom("rom/dpm/ROM");
  reset();
  SDL_LockMutex(event_mutex);
  add_event (10000000/60, &vsync_event);
  SDL_UnlockMutex(event_mutex);
  for (;;) {
    step();
  }
  return 0;
}

static void check_insn(int n) {
  extern u32 initial[][18];
  extern u32 final[][18];
  extern u32 iram[][100];
  extern u32 fram[][100];
  extern u16 prefetch[][2];
  int i;

  fprintf(stderr, "Test %d\n", n);

  for (i = 0; i < 8; i++) {
    dreg[i] = initial[n][i];
    areg[i] = initial[n][i+8];
  }
  SR = initial[n][16];
  PC = initial[n][17];
  IR = prefetch[n][0];
  IRC = prefetch[n][1];
  for (i = 1; i < 1 + 2*iram[n][0];) {
    u32 a = iram[n][i++];
    u8 x = iram[n][i++];
    ram[a] = x;
  }

  if (setjmp(ex) == 0) {
    PC += 4;
    execute();
    PC -= 4;
  }

  for (i = 0; i < 8; i++) {
    if (dreg[i] != final[n][i])
      fprintf(stderr, "D%i is %08X, not %08X\n", i, dreg[i], final[n][i]);
    if (areg[i] != final[n][i+8])
      fprintf(stderr, "A%i is %08X, not %08X\n", i, areg[i], final[n][i+8]);
  }
  if (SR != final[n][16])
    fprintf(stderr, "SR is %04X, not %04X\n", SR, final[n][16]);
  if (PC != final[n][17])
    fprintf(stderr, "PC is %06X, not %06X\n", PC, final[n][17]);
}

static void check(void) {
  extern int tests;
  int i;
  mem_region(0, 16*1024*1024,
	     read_b_ram, write_b_ram,
	     read_w_ram, write_w_ram);
  for (i = 0; i < tests; i++)
    check_insn(test_n = i);
}

int main(void) {
  check();
  return 0;

  sdl_init("VAXstation 100", 1, 0);
  //init_opengl();

  event_mutex = SDL_CreateMutex();
  ipl_mutex = SDL_CreateMutex();
  host_init();
  fibre_init();
  status_init();
  fibre_connect("localhost", 54321);

  if (0)
    ddt ();
  else
    SDL_CreateThread(cputhread, "VS100: Motorola 68000",  NULL);
  sdl_loop();

  return 0;
}
