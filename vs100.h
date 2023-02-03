#include <SDL.h>

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef signed char s8;
typedef signed short s16;
typedef signed int s32;

#define DEFDEV(NAME) \
  extern u8 read_##NAME(u32); \
  extern void write_##NAME(u32, u8)

DEFDEV(bba_clear);
DEFDEV(bba_go);
DEFDEV(bba_scratchpad);
DEFDEV(fb);
DEFDEV(fibre_control);
DEFDEV(host_csr);
DEFDEV(host_interrupt);
DEFDEV(host_loopback);
DEFDEV(keyboard);
DEFDEV(mouse);
DEFDEV(status);
DEFDEV(tablet);
DEFDEV(unibus);

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
extern void fibre_csr(int n, u16 data);
extern u8 fibre_read(u32 address);
extern void fibre_write(u32 address, u8 data);

extern int net_connect(const char *host, int port);
extern void net_close(void);
extern int net_read(void *data, int n);
extern int net_write(const void *data, int n);
