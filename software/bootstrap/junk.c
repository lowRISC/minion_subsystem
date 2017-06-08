#include "junk.h"

static volatile unsigned int * const led_base = (volatile unsigned int*)(7<<20);
static volatile unsigned int * const uart_base = (volatile unsigned int*)(3<<20);
static volatile unsigned int * const ufifo_base = (volatile unsigned int*)(2<<20);

static void myputled(unsigned c) {
  *led_base = c;
}

static void myputchar(const char c) {
  unsigned stat;
  // wait until there is space in the fifo
  do {
    stat = *uart_base & 0x400;
    myputled(stat);
  }
  while( stat != 0);
  // load FIFO
  *ufifo_base = c;
}

void myputhex(unsigned n, unsigned width)
{
  if (width > 1) myputhex(n >> 4, width-1);
  n &= 15;
  if (n > 9) myputchar(n + 'A' - 10);
  else myputchar(n + '0');
}

static void myputs(const char *str)
{
  while (*str)
    {
      myputchar(*str++);
    }
}

int main(void)
{
  int i, j, tot = 1;
  const char *const goodbye = "Goodbye\r\n";
  myputled(0x55);
  myputchar('H');
  myputchar('e');
  myputchar('l');
  myputchar('l');
  myputchar('o');
  myputchar('\r');
  myputchar('\n');
  myputled(0xAA);
  myputs(goodbye);
  ufifo_base[2] = 1<<31;
}
