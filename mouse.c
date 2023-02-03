#include <stdio.h>
#include "vs100.h"

static u8 mx = 0;
static u8 my = 0;

u8 read_b_mouse(u32 a) {
  u8 x;
  if (a & 1)
    x = mx;
  else
    x = my;
  return x;
}

void write_b_mouse(u32 a, u8 x) {
}

DEFAULT_READ_W(mouse)
SAME_WRITE_W(mouse)

void mouse_motion (int x, int y) {
  mx += x;
  my -= y;
}

static void button (u8 mask, int pressed) {
  if (pressed)
    status_clear(mask);
  else
    status_set(mask);
}

void mouse_button_left (int pressed) {
  button(0x20, pressed);
}

void mouse_button_middle (int pressed) {
  button(0x40, pressed);
}

void mouse_button_right (int pressed) {
  button(0x80, pressed);
}
