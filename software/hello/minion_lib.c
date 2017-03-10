#include <stdint.h>
#include <stdio.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdarg.h>

// See LICENSE for license details.

#include "minion_lib.h"
#include "mini-printf.h"

void exit (int i) {
  while (1);
}

void uart_send(uint8_t data) {
#ifdef __x86_64__
  putchar(data);
#else
  // wait until there is space in the fifo
  while( (*(volatile unsigned int*)(3<<20) & 0x400) != 0);
  // load FIFO
  *(volatile unsigned int*)(2<<20) = data;
#endif
}

void uart_init() {
  uart_send('J');
  uart_send('K');
  uart_send('\r');
  uart_send('\n');
}

void uart_send_buf(const char *buf, const int32_t len) {
  int32_t i;
  for(i=0; i<len; i++) uart_send(*(buf+i));
}

uint8_t uart_recv() {
      while( (*(volatile unsigned int*)(3<<20) & 0x100) == 0);
      *(volatile unsigned int*)(3<<20) = 0;
      int ch =  *(volatile int*)(3<<20);
      return ch & 255;
}

void uart_send_string(const char *str) {
  while(*str != 0) uart_send(*(str++));
  }

void cpu_perf_set(unsigned int counterId, unsigned int value) {
  uart_send_string("cpu_perf_set: not implemented yet\n");
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

char uart_getchar() {
      while( (*(volatile unsigned int*)(3<<20) & 0x100) == 0);
      *(volatile unsigned int*)(3<<20) = 0;
      int ch =  *(volatile int*)(3<<20);
      return ch & 255;
}

void uart_wait_tx_done(void) {
      // wait until there is space in the fifo
      while( (*(volatile unsigned int*)(3<<20) & 0x400) != 0);
}

void uart_sendchar(const char c) {
  // wait until there is space in the fifo
  uart_wait_tx_done();
  // load FIFO
  *(volatile unsigned int*)(2<<20) = c;
}

void mystatus(void)
{
  uart_send_string("E");
  //  asm("ecall");
}

int puts (const char *str)
{
  uart_send_string (str);
  uart_send('\r');
  uart_send('\n');
  return 0;
}

void o_led(unsigned int data)
{
  *(volatile unsigned int*)(7<<20) = data;  
}

int edcl_read(uint64_t addr, int bytes, uint8_t *obuf)
{

}

int edcl_write(uint64_t addr, int bytes, uint8_t *ibuf)
{

}

int stack;
