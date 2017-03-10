// See LICENSE for license details.

#ifndef MEMORY_HEADER_H
#define MEMORY_HEADER_H

#include <stdint.h>
#include "device_map.h"

extern volatile uint64_t * get_bram_base();
extern volatile uint64_t * get_ddr_base();

#endif
