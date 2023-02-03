#include <stdio.h>
#include <stdlib.h>

// Firmware 5.0 icons:
//  0530 - Login, "hand and mouse".
//  0990 - Trouble, "crossed over workstation".
//  0D4A - Unable to connect, "cable to question mark".

static unsigned char rom[16*1024];

static void decode(int size, int addr)
{
  char x = '1';
  int i, j = 0, n = 0;

  for (;;)  {
    if (n != 0xFF) {
      n = rom[addr++];
      x ^= 1;
    }
    for (i = 0; i < n; i++) {
      putchar(x);
      if ((++j % size) == 0)
        putchar('\n');
      if (j == size*size)
        return;
    }
  }
}

int main (int argc, char **argv)
{
  int i;

  for (i = 0; i < sizeof rom; i++)
    rom[i] = getchar();

  int addr = strtol (argv[1], NULL, 16);
  int size = rom[addr++];

  printf("P1\n%d %d\n", size, size);

  decode(size, addr);
}
