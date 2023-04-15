#include "vs100.h"
#include "check.h"

static u8 test_ram[16*1024*1024];

static u8 read_b_test(u32 a) {
  return test_ram[a];
}

static void write_b_test(u32 a, u8 x) {
  test_ram[a] = x;
}

DEFAULT_READ_W(test)
DEFAULT_WRITE_W(test)

void check(void) {
  int i, j;

  if (tests == 0)
    return;

  mem_region(0, 16*1024*1024,
	     read_b_test, write_b_test,
	     read_w_test, write_w_test);

  for (i = 0; i < tests; i++) {
    const struct check *data = &check_data[i];
    int n = 1 + 2*data->iram[0];
    for (j = 1; j < n;) {
      u32 a = data->iram[j++];
      u8 x = data->iram[j++];
      test_ram[a] = x;
    }
    check_insn(data);
    n = 1 + 2*data->fram[0];
    for (j = 1; j < n;) {
      u32 a = data->fram[j++];
      u8 x = data->fram[j++];
      if (a < 0x800)
	continue;
      if (test_ram[a] != x)
        fprintf(stderr, "Bad memory: %06X is %02X, not %02X\n",
		a, test_ram[a], x);
    }
  }

  exit(0);
}
