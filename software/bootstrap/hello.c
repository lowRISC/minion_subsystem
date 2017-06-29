#include <stdint.h>

void exit (int i) {
  while (1);
}

void illegal_insn_handler_c(void)
{
  for(;;);
}

void int_time_cmp (void)
{

}

void int_main(void)
{
  // select correct interrupt
  // read cause register to get pending interrupt
  // execute ISR.
}

void uart_set_cfg(int parity, uint16_t clk_counter)
{

}

void __libc_init_array(void)
{

}

enum edcl_mode {
  edcl_mode_unknown,
  edcl_mode_read,
  edcl_mode_write,
  edcl_mode_block_read,
  edcl_mode_bootstrap,
  edcl_max=256};

typedef long size_t;

static void *memcpy(void *__restrict__ dst, const void * __restrict__ src, size_t N) {
  char * __restrict__ dst_ = (char * __restrict__ )dst;
  const char * __restrict__ src_ = (char * __restrict__ )src;
  for (size_t i = 0; i != N; ++i)
    dst_[i] = src_[i];
  return dst;
}

static void myputchar(const char c) {
#ifdef REAL_UART
      // wait until there is space in the fifo
      while( (*(volatile unsigned int*)(3<<20) & 0x400) != 0);
#endif
      // load FIFO
      *(volatile unsigned int*)(2<<20) = c;
}

static void myputs(const char *str)
{
  while (*str)
    {
      myputchar(*str++);
    }
}

static int read_code_data(int addr)
{
  return *(volatile unsigned char *)addr;
}

static size_t read_code_data8(int addr)
{
return read_code_data(addr) |
  (read_code_data(addr+1) << 8) |
  (read_code_data(addr+2) << 16) |
  (read_code_data(addr+3) << 24);
}

static void write_code_data32(int addr, size_t data)
{
  *(volatile size_t *)addr = data;
}

static size_t read_code_data32(int addr)
{
  return *(volatile size_t *)addr;
}

static unsigned int my_stat(int sel)
{
  volatile unsigned int * const my_stat_ = (volatile unsigned int*)(5<<20);
  unsigned int rslt = my_stat_[sel];
  return rslt;
}

void myputhex(unsigned n, unsigned width)
{
  if (width > 1) myputhex(n >> 4, width-1);
  n &= 15;
  if (n > 9) myputchar(n + 'A' - 10);
  else myputchar(n + '0');
}

void hello(void)
{
  int i = 0;
  int j = 0;
  enum edcl_mode mode;
  size_t addr, addr2, addr3, addr4, data, arg, setting, last;
  myputs("Hello, from bootstrap\r\n");
  addr = (8<<20);
  last = addr+(edcl_max<<4)+12;
  do {
    addr4 = read_code_data8(last);
  }
  while ((unsigned)addr4 != 0xDEADBEEF);
  myputs("start\r\n");
  do {
    int cnt = 0;
    int mask, ready = my_stat(0);
    int discard = 0;
    addr3 = addr+(i<<4);
    addr2 = read_code_data8(addr3+4);
    mode = read_code_data8(addr3);
    myputchar(mode+'0');
    if (mode) switch(mode)
	{
	case edcl_mode_bootstrap:
	  {
	    int i;
	    typedef void *fptr(void);
	    myputs("Bootstrapping from ethernet ...\r\n");
	    memcpy((void*)0x2000, (void*)(addr+0x2000), 0x10000-0x2000);
	    for (i = 0; i < 32; i+=4)
	      {
		myputhex(addr2+i, 8);
		myputchar(':');
		myputhex(*((uint32_t *)(addr2+i)), 8);		
		myputchar('\r');
		myputchar('\n');
	      }
	    myputs("Bye.\r\n");
	    (*(fptr *) addr2)();
	    break;
	  }
	case edcl_mode_block_read:
	  mask = read_code_data8(addr3+12);
	  ready = my_stat(0);
	  while (mask & ~ready)
	    {
	      write_code_data32(addr2, 0);
	      data = read_code_data32(addr2);
	      write_code_data32(addr3+16+(cnt++ << 2), data);
	      ready = my_stat(0);
	    }
	  mode = 0;
	  i = cnt;
	  break;
	case edcl_mode_read:
	  data = read_code_data32(addr2);
	  write_code_data32(addr3+12, data);
	  break;
	case edcl_mode_write:
	  data = read_code_data8(addr3+12);
	  write_code_data32(addr2, data);
	  break;
	default:
	  myputs("unknown mode\r\n");
	  return;
	}
      i++;
  } while (mode);
  write_code_data32(addr, i);
  write_code_data32(addr+4, 0);
  write_code_data32(last, 0);
}

static void poll_shm(void)
{
  size_t addr, addr4, last;
  addr = (8<<20);
  last = addr+(edcl_max<<4)+12;
  addr4 = read_code_data8(last);
  if ((unsigned)addr4 == 0xDEADBEEF) hello();
}

enum {max=256};
static int loopback2 = 0; // was 1<<18;
static int loopback = 1<<17;
static int cooked = 0; // 1<<16;
static unsigned char lpbuf[max];

static int mask(int j)
{
  return ((j >= 6) && (j < 12)) ? 0xFF : (j >= 12 ? j-12+0x13 : j);
}

static void eth_test(void)
{
  unsigned i, j, frame_size;
  volatile unsigned int * const led_base = (volatile unsigned int*)(7<<20);
  volatile unsigned int * const tap_base = (volatile unsigned int*)(15<<20);
  tap_base[512+0] = 0x03020100;
  tap_base[512+1] = loopback2+loopback+cooked+0x0504;
  for (i = 0; i < 0x11; i++)
    {
      int j = i*4;
      tap_base[1024+i] = mask(j) | (mask(j+1) << 8) | (mask(j+2) << 16) | (mask(j+3) << 24);
    }
  tap_base[512+2] = 0x42;
  while (tap_base[512+3] & 0x2)
    ; // wait to send packet
  frame_size = tap_base[512+2] >> 16;
  if (frame_size > max) frame_size = max;
  for (i = 0; i < (((frame_size-1)|3)+1)/4; i++)
    {
      unsigned led = tap_base[i];
      for (j = 0; j < 4; j++)
	led_base[0] = led >> (j*8);
    }
}

int main()
{
  volatile unsigned int * const dip_base = (volatile unsigned int*)(7<<20);
  if (dip_base[0] & 0x80)
    eth_test();
  myputs("Hello\n");
  for (;;) poll_shm();
}
