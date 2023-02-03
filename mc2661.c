/* Included by lk201.c and tablet.c. */

#define MC2661_SR_TXRDY 0x01
#define MC2661_SR_RXRDY 0x02
#define MC2661_SR_PERR  0x08
#define MC2661_SR_OERR  0x10
#define MC2661_SR_FERR  0x20

#define MC2661_CR_TXEN  0x01
#define MC2661_CR_DTR   0x02
#define MC2661_CR_RXEN  0x04
#define MC2661_CR_BRK   0x08
#define MC2661_CR_RESET 0x10
#define MC2661_CR_MODE  0xC0
#define MC2661_CR_LPBK  0x80

static u8 mc2661_rx;
static u8 mc2661_tx;
static u8 mc2661_sr;
static u8 mc2661_mr1;
static u8 mc2661_mr2;
static u8 mc2661_syn1;
static u8 mc2661_syn2;
static u8 mc2661_dle;
static u8 mc2661_cr;
static u8 *mc2661_mr = &mc2661_mr1;
static u8 *mc2661_syn = &mc2661_syn1;

static void mc2661_receive(u8);

static u8 mc2661_read(u8 a) {
  u8 x = 0;
  switch (a) {
  case 1:
    mc2661_sr &= ~MC2661_SR_RXRDY;
    x = mc2661_rx;
    break;
  case 3:
    x = mc2661_sr;
    break;
  case 5:
    x = *mc2661_mr;
    break;
  case 7:
    x = mc2661_cr;
    break;
  }
  irq_set(2, mc2661_sr & (MC2661_SR_RXRDY|MC2661_SR_TXRDY));
  return x;
}

static void mc2661_write(u8 a, u8 d) {
  switch (a) {
  case 1:
    mc2661_tx = d;
    if (mc2661_cr & MC2661_CR_TXEN) {
      if ((mc2661_cr & MC2661_CR_MODE) == MC2661_CR_LPBK) {
        mc2661_sr |= MC2661_SR_RXRDY|MC2661_SR_TXRDY;
        mc2661_rx = mc2661_tx;
      } else {
        mc2661_sr |= MC2661_SR_TXRDY;
        mc2661_receive(mc2661_tx);
      }
    }
    break;
  case 3:
    *mc2661_syn = d;
    if (mc2661_syn == &mc2661_syn1)
      mc2661_syn = &mc2661_syn2;
    else
      mc2661_syn = &mc2661_dle;
    break;
  case 5:
    *mc2661_mr = d;
    mc2661_mr = &mc2661_mr2;
    break;
  case 7:
    mc2661_cr = d;
    if (mc2661_cr & MC2661_CR_RESET)
      mc2661_sr &= ~(MC2661_SR_OERR|MC2661_SR_PERR|MC2661_SR_FERR);
    if (mc2661_cr & MC2661_CR_TXEN)
      mc2661_sr |= MC2661_SR_TXRDY;
    else
      mc2661_sr &= ~MC2661_SR_TXRDY;
    break;
  }
  irq_set(2, mc2661_sr & (MC2661_SR_RXRDY|MC2661_SR_TXRDY));
}

static void mc2661_send(u8 d) {
  mc2661_rx = d;
  if (mc2661_cr & MC2661_CR_RXEN)
    mc2661_sr |= MC2661_SR_RXRDY;
  irq_set(2, mc2661_sr & (MC2661_SR_RXRDY|MC2661_SR_TXRDY));
}
