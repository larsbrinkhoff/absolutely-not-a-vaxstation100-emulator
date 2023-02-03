#include "vs100.h"

static u8 scratchpad[512];

u8 read_bba_scratchpad(u32 a) {
  a -= 0x240000;
  return scratchpad[a];
}

void write_bba_scratchpad(u32 a, u8 x) {
  a -= 0x240000;
  scratchpad[a] = x;
}

u8 read_bba_clear(u32 a) {
  irq_set(4, 0);
  return 0;
}

void write_bba_clear(u32 a, u8 x) {
}

u8 read_bba_go(u32 a) {
  return 0;
}

void write_bba_go(u32 a, u8 x) {
}
