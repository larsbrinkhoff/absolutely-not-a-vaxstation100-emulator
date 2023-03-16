#include "vs100.h"
#include "common/event.h"

#define SRC_A      (0x002>>1)
#define SRC_X      (0x006>>1)
#define SRC_STR    (0x008>>1)
#define MSK_A      (0x00A>>1)
#define MSK_X      (0x00E>>1)
#define MSK_STR    (0x010>>1)
#define DST_A      (0x012>>1)
#define DST_X      (0x016>>1)
#define DST_STR    (0x018>>1)
#define MSK_W      (0x01A>>1)
#define MSK_H      (0x01C>>1)
#define FUNC       (0x01E>>1)
#define TILE_A     (0x020>>1)
#define LINE_A     (0x026>>1)
#define LINE_Y     (0x02C>>1)
#define LINE_X     (0x02E>>1)
#define LINE_STR   (0x032>>1)
#define C_SRC_A    (0x04E>>1)
#define C_SRC_X    (0x052>>1)
#define C_SRC_STR  (0x054>>1)
#define C_MSK_A    (0x056>>1)
#define C_MSK_X    (0x05A>>1)
#define C_MSK_STR  (0x05C>>1)
#define C_DST_A    (0x05E>>1)
#define C_DST_X    (0x062>>1)
#define C_DST_STR  (0x064>>1)
#define C_MSK_W    (0x066>>1)
#define C_MSK_H    (0x068>>1)
#define C_FUNC     (0x06A>>1)

#define COMMAND_SOURCE    0x0001
#define COMMAND_MASK      0x0002
#define COMMAND_LEFT      0x0004
#define COMMAND_UP        0x0008
#define COMMAND_TILE      0x0010
#define COMMAND_CURSOR    0x0020
#define COMMAND_LINE    0x0040

static u16 scratchpad[256];

static void callback(void);
static EVENT(bba_event, callback);

static u16 mem_read(u32 a) {
  switch (a >> 16) {
  case 0x00: case 0x01:
    return read_w_ram(a);
  case 0x08: case 0x09: case 0x0A: case 0x0B:
    return read_w_unibus(a);
  case 0x10: case 0x11: case 0x12: case 0x13:
  case 0x14: case 0x15: case 0x16: case 0x17:
    return read_w_fb(a);
  case 0x18:
    return read_w_rom(a);
  default:
    //NXM
    return 0;
  }
}

static void mem_write(u32 a, u16 x) {
  switch (a >> 16) {
  case 0x00: case 0x01:
    write_w_ram(a, x); break;
  case 0x08: case 0x09: case 0x0A: case 0x0B:
    write_w_unibus(a, x); break;
  case 0x10: case 0x11: case 0x12: case 0x13:
  case 0x14: case 0x15: case 0x16: case 0x17:
    write_w_fb(a, x); break;
  case 0x18:
    write_w_rom(a, x); break;
  default:
    //NXM
    ;
  }
}

static u32 address(int x, u16 offset) {
  u32 a = scratchpad[x] << 16;
  a |= scratchpad[x+1];
  a += (offset / 8) & ~1U;
  return a;
}

#if 0
#define FUNC(N, F)  static u16 func_##N(u16 src, u16 dst) { return F; }
FUNC(0000, 0)
FUNC(0001, src & dst)
FUNC(0010, src & ~dst)
FUNC(0011, src)
FUNC(0100, ~src & dst)
FUNC(0101, dst)
FUNC(0110, src ^ dst)
FUNC(0111, src | dst)
FUNC(1000, ~(src | dst))
FUNC(1001, ~(src ^ dst))
FUNC(1010, ~dst)
FUNC(1011, src | ~dst)
FUNC(1100, ~src)
FUNC(1101, ~src | dst)
FUNC(1110, ~(src & dst))
FUNC(1111, ~0U)

src = (src & msk) | (dst & ~msk);
dst = func(src, dst);
#endif

static u16 function(u16 src, u16 dst) {
  src &= 1;
  dst &= 1;
  src = 2 - 2*src;
  dst = 1 - 1*dst;
  return (scratchpad[FUNC] >> (src + dst)) & 1;
}

static void copy_line(u32 src_a, u32 msk_a, u32 dst_a, int reg) {
  u32 sign = (scratchpad[0] & COMMAND_LEFT) ? -1 : 1;
  u16 src_x = scratchpad[SRC_X + reg];
  u16 msk_x = scratchpad[MSK_X + reg];
  u16 dst_x = scratchpad[DST_X + reg];
  u16 msk_w = scratchpad[MSK_W + reg];
  while(msk_w != 0) {
    u16 offset;
    u16 src = 0;
    u16 msk = 1;
    if (scratchpad[0] & (COMMAND_SOURCE|COMMAND_TILE)) {
      offset = src_x;
      src = mem_read(src_a + ((offset / 8) & ~1U));
      src >>= offset % 16;
      src_x += sign;
      if (scratchpad[0] & COMMAND_TILE)
        src_x %= 16;
    }
    if (scratchpad[0] & COMMAND_MASK) {
      offset = msk_x;
      msk = mem_read(msk_a + ((offset / 8) & ~1U));
      msk >>= offset % 16;
      msk_x += sign;
      if (scratchpad[0] & COMMAND_TILE)
        msk_x %= 16;
    }
    offset = dst_x;
    u16 dst = mem_read(dst_a + ((offset / 8) & ~1U));
    if (msk & 1) {
      msk = 1 << (offset % 16);
      dst = (dst & ~msk) | (function (src, dst >> (offset % 16)) << (offset % 16));
    }
    fprintf(stderr, "BBA: out %04X @ %06X\n", dst, dst_a + ((offset / 8) & ~1U));
    mem_write(dst_a + ((offset / 8) & ~1U), dst);
    dst_x += sign;
    msk_w--;
  }
}

static void copy_bitmap(void) {
  u32 sign = (scratchpad[0] & COMMAND_UP) ? -1 : 1;
  u32 src_stride = sign * scratchpad[SRC_STR];
  u32 dst_stride = sign * scratchpad[DST_STR];
  u32 msk_stride = (scratchpad[0] & COMMAND_MASK) ? sign * scratchpad[MSK_STR] : 0;
  u32 src_a = address(SRC_A, 0);
  u32 msk_a = address(MSK_A, 0);
  u32 dst_a = address(DST_A, 0);
  u16 msk_h = scratchpad[MSK_H];
  while (msk_h != 0) {
    copy_line(src_a, msk_a, dst_a, 0);
    src_a += src_stride;
    msk_a += msk_stride;
    dst_a += dst_stride;
    msk_h--;
  }
}

static void copy_tile(void) {
  u32 sign = (scratchpad[0] & COMMAND_UP) ? -1 : 1;
  u32 dst_stride = scratchpad[DST_STR];
  u32 msk_stride = (scratchpad[0] & COMMAND_MASK) ? sign * scratchpad[MSK_STR] : 0;
  u32 src_a = address(TILE_A, 0);
  u32 msk_a = address(MSK_A, 0);
  u32 dst_a = address(DST_A, 0);
  u16 msk_h = scratchpad[MSK_H];
  u32 i = 0;
  while (msk_h != 0) {
    copy_line(src_a + i, msk_a, dst_a, 0);
    i = (i + 2) % 32;
    msk_a += msk_stride;
    dst_a += dst_stride;
    msk_h--;
  }
}

static void copy_cursor(void) {
  u32 sign = (scratchpad[0] & COMMAND_UP) ? -1 : 1;
  u32 src_stride = sign * scratchpad[C_SRC_STR];
  u32 dst_stride = sign * scratchpad[C_DST_STR];
  u32 msk_stride = (scratchpad[0] & COMMAND_MASK) ? sign * scratchpad[C_MSK_STR] : 0;
  u32 src_a = address(C_SRC_A, 0);
  u32 msk_a = address(C_MSK_A, 0);
  u32 dst_a = address(C_DST_A, 0);
  u16 msk_h = scratchpad[C_MSK_H];
  while (msk_h != 0) {
    copy_line(src_a, msk_a, dst_a, 0x04C>>1);
    src_a += src_stride;
    msk_a += msk_stride;
    dst_a += dst_stride;
    msk_h--;
  }
}

static void point(int x, int y) {
  u32 a = address(LINE_A, 0);
  a += y * scratchpad[LINE_STR];
  u16 dst = mem_read(a + ((x / 8) & ~1U));
  dst |= 1 << (x % 16);
  mem_write(a + ((x / 8) & ~1U), dst);
}

#define ABS(_X) ((_X) >= 0 ? (_X) : -(_X))
#define SIGN(_X) ((_X) >= 0 ? 1 : -1)

static void xline(int x, int y, int x2, int dx, int dy) {
  int ix = SIGN(dx);
  int iy = SIGN(dy);
  int ay;
  dx = ABS(dx);
  dy = ABS(dy);
  ay = dy/2;
  for (;;) {
    point(x, y);
    if (x == x2)
      break;
    if (ay > 0) {
      y += iy;
      ay -= dx;
    }
    ay += dy;
    x += ix;
  }
}
  
static void yline(int x, int y, int y2, int dx, int dy) {
  int ix = SIGN(dx);
  int iy = SIGN(dy);
  int ax;
  dx = ABS(dx);
  dy = ABS(dy);
  ax = dx/2;
  for (;;) {
    point(x, y);
    if (y == y2)
      break;
    if (ax > 0) {
      x += ix;
      ax -= dy;
    }
    ax += dx;
    y += iy;
  }
}

static void draw_line(void)
{
  u16 x1 = scratchpad[DST_X];
  u16 x2 = x1 + scratchpad[LINE_X];
  u16 y1 = 0;
  u16 y2 = scratchpad[LINE_Y];
  int dx = (int)x2 - (int)x1;
  int dy = (int)y2 - (int)y1;
  if (ABS(dx) > ABS(dy))
    xline(x1, y1, x2, dx, dy);
  else
    yline(x1, y1, y2, dx, dy);
}


static void callback(void) {
  if (scratchpad[0] & COMMAND_CURSOR)
    copy_cursor();
  else if (scratchpad[0] & COMMAND_TILE)
    copy_tile();
  else if (scratchpad[0] & COMMAND_LINE)
    draw_line();
  else if (scratchpad[0] & COMMAND_SOURCE)
    copy_bitmap();
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
  scratchpad[a>>1] = xx;
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
