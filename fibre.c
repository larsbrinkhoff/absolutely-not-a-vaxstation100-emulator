#include <stdio.h>
#include <unistd.h>
#include "vs100.h"

//Sender: V=VS100, H=Host.
#define FIBRE_XMIT_ON    1  //VH No data.
#define FIBRE_XMIT_OFF   2  //VH No data.
#define FIBRE_INT        3  //VH No data.
#define FIBRE_CSR        4  //VH 8-bit number, 16-bit data.
#define FIBRE_READ8      5  //V  32-bit address.
#define FIBRE_READ16     6  //V  32-bit address.
#define FIBRE_DATA       7  // H 16-bit data.
#define FIBRE_NXM        8  // H No data.
#define FIBRE_WRITE8     9  //V  32-bit address, 8-bit data.
#define FIBRE_WRITE16    10 //V  32-bit address, 16-bit data.

#define MEM_WAIT  0
#define MEM_DATA  1
#define MEM_NXM  -1
static int mem_flag;
static u16 mem_data;
static SDL_mutex *mutex;
static SDL_cond *cond;

static const char *host;
static int port;

static void link_up(void) {
  fprintf(stderr, "FIBRE: Link up.\n");
  status_set(0x10);
}

static void link_down(void) {
  fprintf(stderr, "FIBRE: Link down.\n");
  status_clear(0x10);
}

static void reconnect(void) {
  fprintf(stderr, "FIBRE: Reconnect.\n");
  net_close();
  for (;;) {
    if (net_connect(host, port) < 0)
      sleep(3);
  }
  link_up();
}

static void send(u8 *data, int n) {
  if (net_write(data, n) < 0) {
    link_down();
    //reconnect();
  }
}

void fibre_xmit(int on) {
  fprintf(stderr, "FIBRE: Send xmit %s.\n", on ? "on" : "off");
  u8 x;
  if (on)
    x = FIBRE_XMIT_ON;
  else
    x = FIBRE_XMIT_OFF;
  send(&x, sizeof x);
}

void fibre_int(void) {
  fprintf(stderr, "FIBRE: Send interrupt.\n");
  u8 x = FIBRE_INT;
  send(&x, sizeof x);
}

void fibre_csr(int n, u16 data) {
  fprintf(stderr, "FIBRE: Send CSR%d %04X\n", n, data);
  u8 x[4];
  x[0] = FIBRE_CSR;
  x[1] = n;
  x[2] = data >> 8;
  x[3] = data & 0xFF;
  send(x, sizeof x);
}

u16 fibre_read(u32 address, u8 type) {
  u8 x[5];
  u16 data;
  x[0] = type;
  x[1] = (address >> 24) & 0xFF;
  x[2] = (address >> 16) & 0xFF;
  x[3] = (address >>  8) & 0xFF;
  x[4] = (address >>  0) & 0xFF;
  mem_flag = MEM_WAIT;
  SDL_LockMutex(mutex);
  send(x, sizeof x);
  while (mem_flag == MEM_WAIT)
    SDL_CondWait(cond, mutex);
  switch (mem_flag) {
  case MEM_DATA:
    data = mem_data;
    break;
  case MEM_NXM:
    // todo
    break;
  }
  SDL_UnlockMutex(mutex);
  fprintf(stderr, "FIBRE: Read%s %06X -> %04X\n",
          type == FIBRE_READ8 ? "8" : "16", address, data);
  return data;
}

u8 fibre_read_b(u32 address) {
  return fibre_read(address, FIBRE_READ8);
}

u16 fibre_read_w(u32 address) {
  return fibre_read(address, FIBRE_READ16);
}

void fibre_write_b(u32 address, u8 data) {
  //fprintf(stderr, "FIBRE: Send write8 %06X %02X\n", address, data);
  u8 x[6];
  x[0] = FIBRE_WRITE8;
  x[1] = (address >> 24) & 0xFF;
  x[2] = (address >> 16) & 0xFF;
  x[3] = (address >>  8) & 0xFF;
  x[4] = (address >>  0) & 0xFF;
  x[5] = data;
  send(x, sizeof x);
}

void fibre_write_w(u32 address, u16 data) {
  //fprintf(stderr, "FIBRE: Send write16 %06X %02X\n", address, data);
  u8 x[7];
  x[0] = FIBRE_WRITE16;
  x[1] = (address >> 24) & 0xFF;
  x[2] = (address >> 16) & 0xFF;
  x[3] = (address >>  8) & 0xFF;
  x[4] = (address >>  0) & 0xFF;
  x[5] = data >> 8;
  x[6] = data & 0xFF;
  send(x, sizeof x);
}

static void fibre_receive(void) {
  u8 type;
  u8 message[4];
  u16 x;
  if (net_read(&type, sizeof type) < 0) {
    link_down();
    reconnect();
    return;
  }
  switch(type) {
  case FIBRE_XMIT_ON:
    fprintf(stderr, "FIBRE: Receive Xmit on.\n");
    link_up();
    break;
  case FIBRE_XMIT_OFF:
    fprintf(stderr, "FIBRE: Receive Xmit off.\n");
    link_down();
    break;
  case FIBRE_CSR:
    net_read(message, 3);
    x = message[1] << 8;
    x |= message[2];
    fprintf(stderr, "FIBRE: Receive CSR%d %04X\n", message[0], x);
    host_update_csr(message[0], x);
    break;
  case FIBRE_DATA:
    net_read(message, 2);
    SDL_LockMutex(mutex);
    mem_data = message[0] << 8;
    mem_data |= message[1];
    mem_flag = MEM_DATA;
    //fprintf(stderr, "FIBRE: Receive data %04X\n", mem_data);
    SDL_CondSignal(cond);
    SDL_UnlockMutex(mutex);
    break;
  case FIBRE_NXM:
    fprintf(stderr, "FIBRE: Receive NXM.\n");
    SDL_LockMutex(mutex);
    mem_flag = MEM_NXM;
    SDL_CondSignal(cond);
    SDL_UnlockMutex(mutex);
    break;
  default:
    fprintf(stderr, "FIBRE: Receive bad message %02X.\n", type);
    reconnect();
    break;
  }
}

static int fibre_thread(void *arg) {
  for (;;)
    fibre_receive();
  return 0;
}

void fibre_connect(const char *h, int p) {
  host = h;
  port = p;
  if (net_connect(h, p) < 0) {
    fprintf(stderr, "Error connecting to %s:%d.\n", h, p);
    exit(1);
  }
  SDL_CreateThread(fibre_thread, "VS100: Fibre",  NULL);
}

void fibre_init(void) {
  mutex = SDL_CreateMutex();
  cond = SDL_CreateCond();
}
