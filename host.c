#include <stdio.h>
#include <stdlib.h>
#include "vs100.h"

// csr0 control/status; bit 0 - attention
//    1 interrupt reason
//    2 peripheral event
//    3 function parameter / unibus base, low
//    4 function parameter / unibus base, low
//    5 id
//    7 interrupt vector
static u16 host_csr[8];
static u16 loopback_csr[8];

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

u8 read_b_host_csr(u32 a) {
  fprintf(stderr, "Byte read CSR.\n");
  exit(1);
  return 0;
}

void write_b_host_csr(u32 a, u8 x) {
  fprintf(stderr, "Byte write CSR.\n");
  exit(1);
}

u16 read_w_host_csr(u32 a) {
  int r = (a - 0x480000) >> 1;
  SDL_LockMutex(csr_mutex);
  //fprintf(stderr, "Read HOST CSR%d: %02X\n", r, host_csr[r]);
  u16 x = host_csr[r];
  SDL_UnlockMutex(csr_mutex);
  return x;
}

void write_w_host_csr(u32 a, u16 x) {
  int r = (a - 0x480000) >> 1;
  SDL_LockMutex(csr_mutex);
  //fprintf(stderr, "Write HOST CSR%d: %02X\n", r, x);
  if (fibre_control & 2)
    loopback_csr[r] = x;
  else {
    host_csr[r] = x;
    fibre_csr(r, x);
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

u8 read_b_host_loopback(u32 a) {
  int r = (a - 0x4A0000) >> 1;
  fprintf(stderr, "Read LOOPBACK\n");
  SDL_LockMutex(csr_mutex);
  u16 x = loopback_csr[r];
  SDL_UnlockMutex(csr_mutex);
  if ((a & 1) == 0)
    x >>= 8;
  return x;
}

void write_b_host_loopback(u32 a, u8 x) {
}

DEFAULT_READ_W(host_loopback)
SAME_WRITE_W(host_loopback)

u8 read_b_host_interrupt(u32 a) {
  fprintf(stderr, "Read HOST INTERRUPT\n");
  fibre_int();
  return 0;
}

void write_b_host_interrupt(u32 a, u8 x) {
  fprintf(stderr, "Write HOST INTERRUPT\n");
}

SAME_READ_W(host_interrupt)
SAME_WRITE_W(host_interrupt)

u8 read_b_fibre_control(u32 a) {
  fprintf(stderr, "Read FIBRE_CONTROL: %06X\n", a);
  return 0;
}

void write_b_fibre_control(u32 a, u8 x) {
  fprintf(stderr, "Write FIBRE_CONTROL: %06X %02X\n", a, x);
  if (((fibre_control ^ x) & 1) && (x & 2) == 0)
    fibre_xmit(x & 1);
  fibre_control = x;
}

DEFAULT_READ_W(fibre_control)
DEFAULT_WRITE_W(fibre_control)

u8 read_b_unibus(u32 a) {
  return fibre_read_b(a - 0x080000);
}

void write_b_unibus(u32 a, u8 data) {
  fibre_write_b(a = 0x080000, data);
}

u16 read_w_unibus(u32 a) {
  return fibre_read_w(a - 0x080000);
}

void write_w_unibus(u32 a, u16 data) {
  fibre_write_w(a - 0x080000, data);
}
