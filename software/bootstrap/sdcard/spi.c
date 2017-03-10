// See LICENSE for license details.

#include "spi.h"
#include "minion_lib.h"

volatile unsigned int * const sd_base = (volatile unsigned int*)(6<<20);
volatile unsigned int * const sd_stat_ = (volatile unsigned int*)(5<<20);

static int led_flag;

void o_led(unsigned int flag, unsigned int data)
{
  led_flag = flag;
  *(volatile unsigned int*)(7<<20) = (flag << 12)|data;  
}

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
  while (delay--) o_led(led_flag, led_flag);
}

void sd_transaction(int cmd, unsigned arg, unsigned setting, unsigned resp[])
  {
    int i, mask = setting > 7 ? 0x700 : 0x100;
    sd_cmd(cmd,arg);
    sd_cmd_setting(setting);
    o_led(2,0);
    mysleep(10);
    sd_cmd_start(1);
    o_led(3,0);
    while ((sd_stat(0) & mask) != mask);
    o_led(4,0);
    mysleep(10);
    for (i = 8; i--; ) resp[i] = sd_resp(i);
    o_led(5,0);
    sd_cmd_start(0);
    sd_cmd_setting(0);
    while ((sd_stat(0) & mask) != 0);
    o_led(6,0);
  }

void spi_init(void)
{
  int i, waiting = 1;
  o_led(1,0);
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
}

void spi_disable() {
  unsigned int dat = 0;
  o_led(2,0);
  //  spi_xfer(1, 0, 3, 0, 0);
}

uint8_t spi_send(uint8_t dat) {
  o_led(3,dat);
  *(volatile unsigned int*)(5<<20) = dat;
  //  spi_xfer(1, 0, 3, 0, 1);
  *(volatile unsigned int*)(4<<20) = 0;
  return *(volatile unsigned int*)(4<<20);  
}

uint8_t spi_recv(void) {
  o_led(5,0);
  //  spi_xfer(1, 0, 3, 1, 0);
  *(volatile unsigned int*)(4<<20) = 0;
  return *(volatile unsigned int*)(4<<20);  
}

void spi_send_multi(const uint8_t* dat, uint8_t n) {
  uint8_t i;
  o_led(6,0);
  for(i=0; i<n; i++) *(volatile unsigned int*)(5<<20) = *(dat++);
  //  spi_xfer(1, n, 3, 0, 1);
}

void spi_recv_multi(uint8_t* dat, uint8_t n) {
  uint8_t i;
  o_led(7,0);
  //  spi_xfer(1, n, 3, 1, 0);
  for(i=0; i<n; i++)
    {
      *(volatile unsigned int*)(4<<20) = 0;
      *dat++ = *(volatile unsigned int*)(4<<20);  
    }
}

void spi_select_slave(uint8_t id) {
  o_led(8,0);
}

void spi_deselect_slave(uint8_t id) {
  o_led(9,0);
}

