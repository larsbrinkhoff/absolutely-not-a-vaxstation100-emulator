#include "vs100.h"
#include "common/event.h"

static u16 scratchpad[256];

static void callback(void);
static EVENT(bba_event, callback);

static void callback(void) {
  write_w_fb(0x12000C, 0x1555);
  write_w_fb(0x12000E, 0x8000);
  write_w_fb(0x120010, 0x2AAA);
  write_w_fb(0x120094, 0x2AAA);
  write_w_fb(0x120096, 0x0000);
  write_w_fb(0x120098, 0x1555);
  irq_set(4, 1);
}

static void bba_go(void) {
  SDL_LockMutex(event_mutex);
  fprintf(stderr, "BBA: command %04X\n", scratchpad[0]);
  add_event (1000, &bba_event);
  SDL_UnlockMutex(event_mutex);
}

u8 read_b_bba_control(u32 a) {
  return 0;
}

void write_b_bba_control(u32 a, u8 x) {
  fprintf(stderr, "BBA CONTROL: %02x\n", x);
  if (x == 0)
    irq_set(4, 0);
  else if (x == 1)
    bba_go();
  else
    ;
}

SAME_READ_W(bba_control)
SAME_WRITE_W(bba_control)

u8 read_b_bba_scratchpad(u32 a) {
  a -= 0x300000;
  u16 x = scratchpad[a >> 1];
  if (a & 1)
    x &= 0xFF;
  else
    x >>= 8;
  fprintf(stderr, "BBA SCRATCHPAD: read byte %03X %02X\n", a, x);
  return x;
}

void write_b_bba_scratchpad(u32 a, u8 x) {
  a -= 0x300000;
  fprintf(stderr, "BBA SCRATCHPAD: write byte %03X %02X\n", a, x);
  u16 xx = scratchpad[a >> 1];
  if (a & 1)
    xx = (xx & 0xFF00) | x;
  else
    xx = (xx & 0xFF) | (x << 8);
  scratchpad[a] = xx;
}

u16 read_w_bba_scratchpad(u32 a) {
  a -= 0x300000;
  u16 x = scratchpad[a >> 1];
  fprintf(stderr, "BBA SCRATCHPAD: read word %03X %04X\n", a, x);
  return x;
}

void write_w_bba_scratchpad(u32 a, u16 x) {
  a -= 0x300000;
  fprintf(stderr, "BBA SCRATCHPAD: write word %03X %04X\n", a, x);
  scratchpad[a >> 1] = x;
}
