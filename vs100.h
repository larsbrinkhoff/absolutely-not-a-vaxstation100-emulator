#include <SDL.h>

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef signed char s8;
typedef signed short s16;
typedef signed int s32;

#define DEFDEV(NAME) \
  extern u8 read_b_##NAME(u32); \
  extern void write_b_##NAME(u32, u8); \
  extern u16 read_w_##NAME(u32); \
  extern void write_w_##NAME(u32, u16)

DEFDEV(bba_control);
DEFDEV(bba_scratchpad);
DEFDEV(fb);
DEFDEV(fibre_control);
DEFDEV(host_csr);
DEFDEV(host_interrupt);
DEFDEV(host_loopback);
DEFDEV(keyboard);
DEFDEV(mouse);
DEFDEV(ram);
DEFDEV(rom);
DEFDEV(status);
DEFDEV(tablet);
DEFDEV(unibus);

#define DEFAULT_READ_W(DEVICE)                                          \
  u16 read_w_##DEVICE(u32 a) {                                          \
    return (((u16)read_b_##DEVICE(a)) << 8) | read_b_##DEVICE(a+1);     \
  }

#define DEFAULT_WRITE_W(DEVICE)                 \
  void write_w_##DEVICE(u32 a, u16 x) {         \
    write_b_##DEVICE(a, x >> 8);                \
    write_b_##DEVICE(a+1, x & 0xFF);            \
  }

#define SAME_READ_W(DEVICE)                     \
  u16 read_w_##DEVICE(u32 a) {                  \
    return read_b_##DEVICE(a);                  \
  }

#define SAME_WRITE_W(DEVICE)                    \
  void write_w_##DEVICE(u32 a, u16 x) {         \
    write_b_##DEVICE(a, x);                     \
  }

extern SDL_mutex *event_mutex;

extern void mc68000_ipl(int level);
extern void irq_set(int level, int flag);
extern void status_set(u8 bits);
extern void status_clear(u8 bits);
extern void status_init(void);

extern void host_init(void);
extern void host_update_csr(u8 r, u16 x);

extern void fibre_init(void);
extern void fibre_connect(const char *h, int p);
extern void fibre_xmit(int on);
extern void fibre_int(void);
extern void fibre_csr(int n, u16 data);
extern u8 fibre_read_b(u32 address);
extern void fibre_write_b(u32 address, u8 data);
extern u16 fibre_read_w(u32 address);
extern void fibre_write_w(u32 address, u16 data);

extern int net_connect(const char *host, int port);
extern void net_close(void);
extern int net_read(void *data, int n);
extern int net_write(const void *data, int n);
