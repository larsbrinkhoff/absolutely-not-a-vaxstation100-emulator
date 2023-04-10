struct check {
  const char *name;
  u32 initial[20];
  u32 final[20];
  u16 prefetch[2];
  u32 iram[200];
  u32 fram[200];
};

extern const struct check check_data[];
extern int tests;

extern void check_insn(const struct check *);
