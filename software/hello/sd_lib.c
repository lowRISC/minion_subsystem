#include "minion_lib.h"
#include "simple_lib.h"
#include "sd_lib.h"

volatile unsigned int * const sd_base = (volatile unsigned int*)(6<<20);
volatile unsigned int * const sd_stat_ = (volatile unsigned int*)(5<<20);

unsigned int sd_resp(int sel)
{
  unsigned int rslt = sd_base[sel];
  return rslt;
}

unsigned int sd_stat(int sel)
{
  unsigned int rslt = sd_stat_[sel];
  return rslt;
}

void sd_align(int d_align)
  {
  sd_base[0] = d_align;
  }
  
void sd_clk_div(int clk_div)
{
  sd_base[1] = clk_div;
}

void sd_cmd(unsigned cmd, unsigned arg)
{
  sd_base[2] = arg;
  sd_base[3] = cmd;
}

void sd_cmd_setting(int sd_cmd_setting)
{
  sd_base[4] = sd_cmd_setting;
}

void sd_cmd_start(int sd_cmd)
{
  sd_base[5] = sd_cmd;
}

void sd_reset(int sd_rst, int clk_rst, int data_rst, int cmd_rst)
{
  sd_base[6] = ((sd_rst&1) << 3)|((clk_rst&1) << 2)|((data_rst&1) << 1)|((cmd_rst&1) << 0);
}

void sd_blkcnt(int d_blkcnt)
{
  sd_base[7] = d_blkcnt&0xFFFF;
}

void sd_blksize(int d_blksize)
{
  sd_base[8] = d_blksize&0xFFF;
}

void sd_timeout(int d_timeout)
{
  sd_base[9] = d_timeout;
}

void mysleep(int delay)
{
  while (delay--) o_led(delay);
}

void sd_transaction(int cmd, unsigned arg, unsigned setting, unsigned resp[])
  {
    int i;
    unsigned mask = setting > 7 ? 0x700 : 0x100;
    sd_cmd(cmd,arg);
    sd_cmd_setting(setting);
    o_led(2);
    mysleep(10);
    sd_cmd_start(1);
    o_led(3);
    while ((sd_stat(0) & mask) != mask);
    o_led(4);
    mysleep(10);
    for (i = 8; i--; ) resp[i] = sd_resp(i);
    o_led(5);
    sd_cmd_start(0);
    sd_cmd_setting(0);
    while ((sd_stat(0) & mask) != 0);
    o_led(6);
  }

unsigned sd_transaction_v(int sdcmd, unsigned arg, unsigned setting)
{
  int i;
  unsigned resp[8];
  char pause = mygetchar();
  myputchar('\r');
  myputchar('\n');
  sd_transaction(sdcmd, arg, setting, resp);
  myputhex(resp[7], 4);
  myputchar(':');
  myputhex(resp[6], 8);
  myputchar('-');
  myputchar('>');
  for (i = 4; i--; )
    {
      myputhex(resp[i], 8);
      myputchar(',');
    }
  myputhex(resp[5], 8);
  myputchar(',');
  myputhex(resp[4], 8);
  return resp[0] & 0xFFFF0000U;
}

void sd_init(void)
{
  int i, rca, busy, waiting = 1;
  o_led(1);
  sd_clk_div(200);
  sd_reset(0,1,0,0);
  mysleep(74);
  sd_blkcnt(1);
  sd_blksize(1);
  sd_align(3);
  sd_timeout(14);
  mysleep(10);
  sd_reset(0,1,1,1);
  mysleep(10);
  sd_transaction_v(0,0x00000000,0x0);
  sd_transaction_v(8,0x000001AA,0x1);
  do {
  sd_transaction_v(55,0x00000000,0x1);
  busy = sd_transaction_v(41,0x40300000,0x1);
  } while (0x80000000U & ~busy);
  sd_transaction_v(2,0x00000000,0x3);
  rca = sd_transaction_v(3,0x00000000,0x1);
  myputchar('\r');
  myputchar('\n');
  myputchar('c');
  myputhex(rca, 8);
  sd_transaction_v(9,rca,0x3);
  sd_transaction_v(13,rca,0x1);
  sd_transaction_v(7,rca,0x1);
  sd_transaction_v(55,rca,0x1);
  sd_transaction_v(51,0x00000000,0x1);
  sd_transaction_v(55,rca,0x1);
  sd_transaction_v(13,0x00000000,0x1);
  for (i = 0; i < 16; i=(i+1)|1)
    {
      sd_transaction_v(16,0x00000200,0x1);
      sd_transaction_v(17,i,0x1);
      sd_transaction_v(16,0x00000200,0x1);
    }
  sd_transaction_v(16,0x00000200,0x1);
  sd_transaction_v(18,0x00000040,0x1);
  sd_transaction_v(12,0x00000000,0x1);
}

