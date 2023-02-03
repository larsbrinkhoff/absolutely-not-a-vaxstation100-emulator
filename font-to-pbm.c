#include <stdio.h>
#include <stdlib.h>

// Firmware 5.0 font at ROM offset 1EE2.

static unsigned char rom[16*1024];

static void pixels(unsigned char data)
{
  int i;
  for (i = 0; i < 8; i++) {
    putchar((data & 1) ? '1' : '0');
    data >>= 1;
  }
}

static void row(int addr)
{
  int i, j;

  for (i = 0; i < 15; i++) {
    for (j = 0; j < 32; j++) {
      pixels(rom[addr + j]);
      if ((j % 32) == 0)
        putchar('\n');
    }
    addr += 96;
  }
}

static void decode(int addr)
{
  row(addr);
  row(addr + 32);
  row(addr + 64);
}

int main (int argc, char **argv)
{
  int i;

  for (i = 0; i < sizeof rom; i++)
    rom[i] = getchar();

  int addr = strtol (argv[1], NULL, 16);

  printf("P1\n%d %d\n", 96*8/3, 15*3);

  decode(addr);
}
