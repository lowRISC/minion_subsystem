#include "junk.h"

void _start(void) // must be first in link order
{
  memcpy((void*)0x10000, (void*)0x810000, 0x10);
  main();
}
