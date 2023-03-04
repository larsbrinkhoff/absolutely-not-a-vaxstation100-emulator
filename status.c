#include "vs100.h"

static u8 status = 0xE3 ^ 2;
static SDL_mutex *mutex;

void status_set(u8 bits) {
  SDL_LockMutex(mutex);
  irq_set(5, (~status & bits) & 0x10);
  status |= bits;
  SDL_UnlockMutex(mutex);
}

void status_clear(u8 bits) {
  SDL_LockMutex(mutex);
  irq_set(5, (status & bits) & 0x10);
  status &= ~bits;
  SDL_UnlockMutex(mutex);
}

u8 read_b_status(u32 a) {
  // 0 = manufacturing mode (0).
  // 1 = BBA present (0).
  // 2 = NXM (1).
  // 3 = Retry overflow (1).
  // 4 = Link available (1).
  // 5 = Left mouse button (0).
  // 6 = Centre mouse button (0).
  // 7 = Right mouse button (0).
  if (a & 1) {
    SDL_LockMutex(mutex);
    u8 x = status;
    status &= ~0x04;
    SDL_UnlockMutex(mutex);
    return x; // ^ 0x10;
  }

  irq_set(5, 0);
  return 0;
}

void write_b_status(u32 a, u8 x) {
}

void status_init(void) {
  mutex = SDL_CreateMutex();
}
