#include "junk.h"

void exit (int i) {
  while (1);
}

#if 0
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

void *memcpy(void *__restrict__ dst, const void * __restrict__ src, size_t N) {
  char * __restrict__ dst_ = (char * __restrict__ )dst;
  const char * __restrict__ src_ = (char * __restrict__ )src;
  for (size_t i = 0; i != N; ++i)
    dst_[i] = src_[i];
  return dst;
}

static void myputchar(const char c) {
      // wait until there is space in the fifo
      while( (*(volatile unsigned int*)(3<<20) & 0x400) != 0);
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

void myputhex(unsigned n, unsigned width)
{
  if (width > 1) myputhex(n >> 4, width-1);
  n &= 15;
  if (n > 9) myputchar(n + 'A' - 10);
  else myputchar(n + '0');
}

size_t strlen (const char *str)
{
  char *s = (char *)str;
  size_t len = 0;

  if (!s)
    return 0;

  while (*s++ != '\0')
    ++len;
  return len;
}
#endif

void main()
{
  int i, j, tot = 1;
  const char *const goodbye = "Goodbye\r\n";
  const char *old = goodbye+0x800000;
  myputchar('H');
  myputchar('e');
  myputchar('l');
  myputchar('l');
  myputchar('o');
  myputchar('\r');
  myputchar('\n');
  for (i = 0; i < strlen(goodbye); i++)
    {
      myputhex(goodbye+i, 8);
      myputchar(':');
      myputchar(goodbye[i]);
      myputchar(':');
      myputchar(old[i]);
      myputchar('\r');
      myputchar('\n');
    }
  for(j = 1;j < 1000000;j++)
    {
      for (i = 10000000; i--; ) tot += i*j;
      myputchar('*');
      myputhex(tot, 8);
      myputchar('\r');
      myputchar('\n');
    }
}
