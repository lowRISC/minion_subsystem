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

void *memcpy(void *__restrict__ dst, const void * __restrict__ src, size_t N) {
  char * __restrict__ dst_ = (char * __restrict__ )dst;
  const char * __restrict__ src_ = (char * __restrict__ )src;
  for (size_t i = 0; i != N; ++i)
    dst_[i] = src_[i];
  return dst;
}

int memcmp(const void *x, const void *y, size_t N) {
  if (x == y)
    return 0;

  const char *x_ = (const char *)x;
  const char *y_ = (const char *)y;
  for (size_t i = 0; i != N; ++i) {
    int delta = x_[i] - y_[i];
    if (delta)
      return delta;
  }
  return 0;
}

void *memset(void *dst, int V, size_t N) {
  char *dst_ = (char *) dst;
  for (size_t i = 0; i != N; ++i)
    dst_[i] = V;
  return dst;
}

char *strncpy(char *dest, const char *src, size_t n)
{
  size_t i;
  
  for (i = 0; i < n && src[i] != '\0'; i++)
    dest[i] = src[i];
  for ( ; i < n; i++)
    dest[i] = '\0';
  
  return dest;
}

int strcmp (const char *s1, const char *s2)
 {
  /* No checks for NULL */
  char *s1p = (char *)s1;
  char *s2p = (char *)s2;

  while (*s2p != '\0')
    {
      if (*s1p != *s2p)
        break;

      ++s1p;
      ++s2p;
    }
  return (*s1p - *s2p);
}

char* strcpy (char *s1, const char *s2)
{
  char *s1p = (char *)s1;
  char *s2p = (char *)s2;

  while (*s2p != '\0')
  {
    (*s1p) = (*s2p);

    ++s1p;
    ++s2p;
  }

  return s1;
}

size_t strlen (const char *str)
{
  char *s = (char *)str;
  size_t len = 0;

  if (s == NULL)
    return 0;

  while (*s++ != '\0')
    ++len;
  return len;
}

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

enum edcl_mode {edcl_mode_unknown, edcl_mode_read, edcl_mode_write, edcl_mode_block_read, edcl_max=256};

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

static void poll_shm(void)
{
#if 0
  size_t addr, addr4, last;
  addr = (8<<20);
  last = addr+(edcl_max<<4)+12;
  addr4 = read_code_data8(last);
  if (addr4 == 0xDEADBEEF) hello();
#endif
}

char uart_getchar() {
  while( (*(volatile unsigned int*)(3<<20) & 0x100) == 0) poll_shm();
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
}

int printf (const char *fmt, ...)
{
  char buffer[99];
  va_list va;
  int rslt;
  va_start(va, fmt);
  rslt = mini_vsnprintf(buffer, sizeof(buffer), fmt, va);
  va_end(va);
  uart_send_string(buffer);
  return rslt;
}
