#include "xsdl.h"
#include "vs100.h"

static struct draw data;
static uint32_t rgb[1088 * 864];
float curvature = 0.1;
int quick = 1;
int updated = 1;

static u8 frame_buffer[512*1024];
static uint32_t color[] = {
  0xFF000000,
  0xFFFFFFFF
};

u8 read_b_fb(u32 a) {
  return frame_buffer[a - 0x100000];
}

void write_b_fb(u32 a, u8 x) {
  int i;
  a -= 0x100000;
  frame_buffer[a] = x;
  a ^= 1;
  a *= 8;
  if (a >= 1088*864)
    return;
  updated = 1;
  for (i = 0; i < 8; i++) {
    rgb[a++] = color[x & 1];
    x >>= 1;
  }
}

DEFAULT_READ_W(fb)
DEFAULT_WRITE_W(fb)

void refresh (void)
{
  if (updated) {
    data.pixels = rgb;
    sdl_present (&data);
    updated = 0;
  }
}

void reset_video (void)
{
  memset(rgb, 0xFF, sizeof rgb);
  refresh ();
}

void reset_render (void *x)
{
  free(x);
}

uint8_t *render_video (uint8_t *dest, int c, int wide, int scroll, void *x)
{
  return 0;
}
