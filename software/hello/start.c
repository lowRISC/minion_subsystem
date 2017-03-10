//#include "minion_lib.h"
#include "simple_lib.h"

void main(void);

void _start(void) // must be first in link order
{
  puts(" ready\r\n");
  main();
}
