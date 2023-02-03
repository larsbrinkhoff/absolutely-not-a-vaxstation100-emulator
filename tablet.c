#include <stdio.h>
#include "vs100.h"

#include "mc2661.c"

u8 read_b_tablet(u32 a) {
  u8 x = mc2661_read(a);
  return x;
}

void write_b_tablet(u32 a, u8 x) {
  mc2661_write(a, x);
}

static void mc2661_receive(u8 d) {
}
