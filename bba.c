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

#define COMMAND_SOURCE    0x0001
#define COMMAND_MASK      0x0002
#define COMMAND_LEFT      0x0004
#define COMMAND_UP        0x0008
#define COMMAND_TILE      0x0010
#define COMMAND_UNKNOWN   0x0020

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
  }
}

static u32 address(int x, u16 offset) {
  u32 a = scratchpad[x] << 16;
  a |= scratchpad[x+1];
  a += (offset / 8) & ~1U;
  return a;
}

static void add(int x, u32 a) {
  u32 sum = scratchpad[x] << 16;
  sum += scratchpad[x+1] + a;
  scratchpad[x] = sum >> 16;
  scratchpad[x+1] = sum & 0xFFFF;
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

static void copy_line(u32 src_a) {
  u32 sign = (scratchpad[0] & COMMAND_LEFT) ? -1 : 1;
  u16 src_x = scratchpad[SRC_X];
  u16 dst_x = scratchpad[DST_X];
  u16 msk_x = scratchpad[MSK_X];
  u16 msk_w = scratchpad[MSK_W];
  do {
    u16 offset = src_x;
    u16 src = mem_read(src_a + ((offset / 8) & ~1U));
    u16 msk = 1;
    //fprintf(stderr, "BBA: src %04X\n", src);
    src >>= offset % 16;
    //fprintf(stderr, "BBA: src shifted %04X\n", src);
    if (scratchpad[0] & COMMAND_MASK) {
      offset = msk_x;
      msk = mem_read(address(MSK_A, offset));
      //fprintf(stderr, "BBA: msk, a %06X %06X, o %d\n", address(MSK_A, 0), address(MSK_A, offset), offset);
      //fprintf(stderr, "BBA: msk %04X\n", msk);
      msk >>= offset % 16;
      //fprintf(stderr, "BBA: msk shifted %04X\n", msk);
      msk_x += sign;
    }
    offset = dst_x;
    u16 dst = mem_read(address(DST_A, offset));
    //fprintf(stderr, "BBA: dst %04X\n", dst);
    if (msk & 1) {
      msk = 1 << (offset % 16);
      //fprintf(stderr, "BBA: dst shifted %04X\n", dst >> (offset % 16));
      //fprintf(stderr, "BBA: out msk %04X\n", msk);
      dst = (dst & ~msk) | (function (src, dst >> (offset % 16)) << (offset % 16));
    }
    fprintf(stderr, "BBA: out %04X @ %06X\n", dst, address(DST_A, offset));
    mem_write(address(DST_A, offset), dst);
    src_x += sign;
    if (scratchpad[0] & COMMAND_TILE)
      src_x %= 16;
    dst_x += sign;
    msk_w--;
  } while(msk_w != 0);
}

static void copy_bitmap(void) {
  u32 sign = (scratchpad[0] & COMMAND_UP) ? -1 : 1;
  u32 src_stride = sign * scratchpad[SRC_STR];
  u32 dst_stride = sign * scratchpad[DST_STR];
  u32 msk_stride = (scratchpad[0] & COMMAND_MASK) ? sign * scratchpad[MSK_STR] : 0;
  u32 src_a = address(SRC_A, 0);
  do {
    copy_line(src_a);
    src_a += src_stride;
    add(DST_A, dst_stride);
    add(MSK_A, msk_stride);
    scratchpad[MSK_H]--;
  } while (scratchpad[MSK_H] != 0);
}

static void copy_tile(void) {
  u32 sign = (scratchpad[0] & COMMAND_UP) ? -1 : 1;
  u32 dst_stride = scratchpad[DST_STR];
  u32 msk_stride = (scratchpad[0] & COMMAND_MASK) ? sign * scratchpad[MSK_STR] : 0;
  u32 src_a = address(TILE_A, 0);
  u32 i = 0;
  do {
    copy_line(src_a + i);
    i = (i + 2) % 32;
    add(DST_A, dst_stride);
    add(MSK_A, msk_stride);
    scratchpad[MSK_H]--;
  } while (scratchpad[MSK_H] != 0);
}

static void callback(void) {
  if (scratchpad[0] & 0x0020)
    ;
  else if (scratchpad[0] & COMMAND_TILE)
    copy_tile();
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
