#include <stdio.h>

int main (int argc, char **argv)
{
  FILE *f1 = fopen (argv[1], "rb");
  FILE *f2 = fopen (argv[2], "rb");

  for (;;) {
    int c1 = fgetc(f1);
    int c2 = fgetc(f2);

    if (c1 == EOF || c2 == EOF)
      return 0;

    putchar(c1);
    putchar(c2);
  }

  return 0;
}
