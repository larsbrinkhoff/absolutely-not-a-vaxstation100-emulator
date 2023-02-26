#include "vs100.h"

static u8 scratchpad[512];

u8 read_b_bba_scratchpad(u32 a) {
  a -= 0x240000;
  return scratchpad[a];
}

void write_b_bba_scratchpad(u32 a, u8 x) {
  a -= 0x240000;
  scratchpad[a] = x;
}

DEFAULT_READ_W(bba_scratchpad)
DEFAULT_WRITE_W(bba_scratchpad)

u8 read_b_bba_clear(u32 a) {
  irq_set(4, 0);
  return 0;
}

void write_b_bba_clear(u32 a, u8 x) {
}

SAME_READ_W(bba_clear)
SAME_WRITE_W(bba_clear)

u8 read_b_bba_go(u32 a) {
  return 0;
}

void write_b_bba_go(u32 a, u8 x) {
}

SAME_READ_W(bba_go)
SAME_WRITE_W(bba_go)
