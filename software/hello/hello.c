/*
 * The Minimal snprintf() implementation
 *
 * Copyright (c) 2013,2014 Michal Ludvig <michal@logix.cz>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the auhor nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * ----
 *
 * This is a minimal snprintf() implementation optimised
 * for embedded systems with a very limited program memory.
 * mini_snprintf() doesn't support _all_ the formatting
 * the glibc does but on the other hand is a lot smaller.
 * Here are some numbers from my STM32 project (.bin file size):
 *      no snprintf():      10768 bytes
 *      mini snprintf():    11420 bytes     (+  652 bytes)
 *      glibc snprintf():   34860 bytes     (+24092 bytes)
 * Wasting nearly 24kB of memory just for snprintf() on
 * a chip with 32kB flash is crazy. Use mini_snprintf() instead.
 *
 */

#include <stdio.h>
#include <stdint.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdarg.h>

static unsigned int
mini_strlen(const char *s)
{
	unsigned int len = 0;
	while (s[len] != '\0') len++;
	return len;
}

static unsigned int
mini_itoa(int value, unsigned int radix, unsigned int uppercase, unsigned int unsig,
	 char *buffer, unsigned int zero_pad)
{
	char	*pbuffer = buffer;
	int	negative = 0;
	unsigned int	i, len;

	/* No support for unusual radixes. */
	if (radix > 16)
		return 0;

	if (value < 0 && !unsig) {
		negative = 1;
		value = -value;
	}

	/* This builds the string back to front ... */
	do {
		int digit = value % radix;
		*(pbuffer++) = (digit < 10 ? '0' + digit : (uppercase ? 'A' : 'a') + digit - 10);
		value /= radix;
	} while (value > 0);

	for (i = (pbuffer - buffer); i < zero_pad; i++)
		*(pbuffer++) = '0';

	if (negative)
		*(pbuffer++) = '-';

	*(pbuffer) = '\0';

	/* ... now we reverse it (could do it recursively but will
	 * conserve the stack space) */
	len = (pbuffer - buffer);
	for (i = 0; i < len / 2; i++) {
		char j = buffer[i];
		buffer[i] = buffer[len-i-1];
		buffer[len-i-1] = j;
	}

	return len;
}

int
mini_vsnprintf(char *buffer, unsigned int buffer_len, const char *fmt, va_list va)
{
	char *pbuffer = buffer;
	char bf[24];
	char ch;

	int _putc(char ch)
	{
		if ((unsigned int)((pbuffer - buffer) + 1) >= buffer_len)
			return 0;
		*(pbuffer++) = ch;
		*(pbuffer) = '\0';
		return 1;
	}

	int _puts(char *s, unsigned int len)
	{
		unsigned int i;

		if (buffer_len - (pbuffer - buffer) - 1 < len)
			len = buffer_len - (pbuffer - buffer) - 1;

		/* Copy to buffer */
		for (i = 0; i < len; i++)
			*(pbuffer++) = s[i];
		*(pbuffer) = '\0';

		return len;
	}

	while ((ch=*(fmt++))) {
		if ((unsigned int)((pbuffer - buffer) + 1) >= buffer_len)
			break;
		if (ch!='%')
			_putc(ch);
		else {
			char zero_pad = 0;
			char *ptr;
			unsigned int len;

			ch=*(fmt++);

			/* Zero padding requested */
			if (ch=='0') {
				ch=*(fmt++);
				if (ch == '\0')
					goto end;
				if (ch >= '0' && ch <= '9')
					zero_pad = ch - '0';
				ch=*(fmt++);
			}

			switch (ch) {
				case 0:
					goto end;

				case 'u':
				case 'd':
					len = mini_itoa(va_arg(va, unsigned int), 10, 0, (ch=='u'), bf, zero_pad);
					_puts(bf, len);
					break;

				case 'x':
				case 'X':
					len = mini_itoa(va_arg(va, unsigned int), 16, (ch=='X'), 1, bf, zero_pad);
					_puts(bf, len);
					break;

				case 'c' :
					_putc((char)(va_arg(va, int)));
					break;

				case 's' :
					ptr = va_arg(va, char*);
					_puts(ptr, mini_strlen(ptr));
					break;

				default:
					_putc(ch);
					break;
			}
		}
	}
end:
	return pbuffer - buffer;
}


int
mini_snprintf(char* buffer, unsigned int buffer_len, const char *fmt, ...)
{
	int ret;
	va_list va;
	va_start(va, fmt);
	ret = mini_vsnprintf(buffer, buffer_len, fmt, va);
	va_end(va);

	return ret;
}

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

void main(void)
{
  puts("Hello, from bootstrap");
  puts("finish\r\n");
}
