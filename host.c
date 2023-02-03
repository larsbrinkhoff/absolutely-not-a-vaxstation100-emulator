#include <stdio.h>
#include "vs100.h"

// csr0 control/status; bit 0 - attention
//    1 interrupt reason
//    2 peripheral event
//    3 function parameter / unibus base, low
//    4 function parameter / unibus base, low
//    5 id
//    7 interrupt vector
static u16 host_csr[8];

// bit 1-0
// 00 - powerup state
// 01 - normal operation
// 10 - electrical loop-back
// 11 - optical loop-back
// bit 2 - force crc error.
static u8 fibre_control;

static SDL_mutex *csr_mutex;

void host_init(void) {
  csr_mutex = SDL_CreateMutex();
}

u8 read_host_csr(u32 a) {
  int r = (a - 0x480000) >> 1;
  SDL_LockMutex(csr_mutex);
  //fprintf(stderr, "Read HOST CSR%d: %02X\n", r, host_csr[r]);
  u16 x = host_csr[r];
  SDL_UnlockMutex(csr_mutex);
  if ((a & 1) == 0)
    x >>= 8;
  return x;
}

void write_host_csr(u32 a, u8 x) {
  static u16 data;
  int r = (a - 0x480000) >> 1;
  SDL_LockMutex(csr_mutex);
  //fprintf(stderr, "Write HOST CSR%d: %02X\n", r, x);
  if (fibre_control & 2) {
    if (a & 1) {
      host_csr[r] &= 0xFF00;
      host_csr[r] |= x;
    } else {
      host_csr[r] &= 0xFF;
      host_csr[r] |= x << 8;
    }
  } else {
    if (a & 1)
      fibre_csr(r, data | x);
    else
      data = x << 8;
  }
  SDL_UnlockMutex(csr_mutex);
  if (fibre_control & 4)
    status_set(0x04);
}

void host_update_csr(u8 r, u16 x) {
  SDL_LockMutex(csr_mutex);
  host_csr[r] = x;
  SDL_UnlockMutex(csr_mutex);
}

u8 read_host_loopback(u32 a) {
  int r = (a - 0x4A0000) >> 1;
  fprintf(stderr, "Read LOOPBACK\n");
  SDL_LockMutex(csr_mutex);
  u16 x = host_csr[r];
  SDL_UnlockMutex(csr_mutex);
  if ((a & 1) == 0)
    x >>= 8;
  return x;
}

void write_host_loopback(u32 a, u8 x) {
}

u8 read_host_interrupt(u32 a) {
  fprintf(stderr, "Read HOST INTERRUPT\n");
  irq_set(5, 0);
  return 0;
}

void write_host_interrupt(u32 a, u8 x) {
  fprintf(stderr, "Write HOST INTERRUPT\n");
}

u8 read_fibre_control(u32 a) {
  fprintf(stderr, "Read FIBRE_CONTROL: %06X\n", a);
  return 0;
}

void write_fibre_control(u32 a, u8 x) {
  fprintf(stderr, "Write FIBRE_CONTROL: %06X %02X\n", a, x);
  if (((fibre_control ^ x) & 1) && (x & 2) == 0)
    fibre_xmit(x & 1);
  fibre_control = x;
}

u8 read_unibus(u32 a) {
  a -= 0x080000;
  u16 x = fibre_read(a & ~1);
  if (a & 1)
    return x & 0xFF;
  else
    return x >> 8;
}

void write_unibus(u32 a, u8 data) {
  a -= 0x080000;
  u16 x = fibre_read(a & ~1);
  if (a & 1)
    x = (x & 0xFF00) | data;
  else
    x = (x & 0x00FF) | (data << 8);
  fibre_write(a & ~1, x);
}
