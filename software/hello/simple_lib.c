//#include "minion_lib.h"
#include "simple_lib.h"

void myputchar(char ch)
{
   uart_sendchar(ch);
}

void myputhex(unsigned n, unsigned width)
{
  if (width > 1) myputhex(n >> 4, width-1);
  n &= 15;
  if (n > 9) myputchar(n + 'A' - 10);
  else myputchar(n + '0');
}

int mygetchar(void)
{
  int ch = uart_getchar();
  if (echo()) uart_sendchar(ch);
  return ch;
}

void mygets(char *cmd)
{
  int ch;
  char *chp = cmd;
  ch = uart_getchar();
  while (ch != '\r')
    {
      if (ch != '\n') *chp++ = ch;
      if (ch == '\004') return;
      if (echo()) uart_sendchar(ch);
      ch = uart_getchar();
    }
  *chp = 0;
  /*
  myputs("\n**** ");
  myputs(cmd);
  myputs(" ****\n");
  */
}

void myputs(const char *str)
{
  while (*str)
    {
      myputchar(*str++);
    }
}
