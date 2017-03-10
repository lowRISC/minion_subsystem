// See LICENSE for license details.

#include "spi.h"
#include "minion_lib.h"

void spi_init() {
  puts("spi_init");
}


void spi_disable() {
  puts("spi_disable");
}

uint8_t spi_send(uint8_t dat) {
  printf("spi_send %X\n", dat);
  return 0;
}

void spi_send_multi(const uint8_t* dat, uint8_t n) {
  uint8_t i;
  puts("spi_send_multi");
  for(i=0; i<n; i++) spi_send(*(dat++));
}

void spi_recv_multi(uint8_t* dat, uint8_t n) {
  uint8_t i;
  puts("spi_recv_multi");
  for(i=0; i<n; i++) *dat++ = 0;
}

void spi_select_slave(uint8_t id) {
  puts("spi_select_slave");
}

void spi_deselect_slave(uint8_t id) {
  puts("spi_deselect_slave");
}

