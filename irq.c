#include "vs100.h"

static int on[8];

void irq_set(int level, int flag) {
  int i;

  //fprintf(stderr, "Interrupt level %d: %s\n", level, flag ? "ON" : "OFF");
  on[level] = flag;

  for (i = 7; i > 0; i--) {
    if (on[i]) {
      mc68000_ipl(i);
      return;
    }
  }
  mc68000_ipl(0);
}
