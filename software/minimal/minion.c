#include "minion.h"

#define ADD_UART_TX        0x200000
#define ADD_UART_BAUD      0x200004
#define ADD_UART_STATUS    0x300000
#define ADD_LED_OUT        0x700000

#define SIM_DELAY 250
#define REAL_DELAY 250000

int init(int temp) {
  return temp + 1;
}

void delay() {
 long delay = REAL_DELAY;
 for(long i = 0; i < delay; i++) {  }
}

void to_led(unsigned int data)
{
  *(volatile unsigned int*)(ADD_LED_OUT) = data;
}

void uart_init() {
  uart_set_buad(651);
}

void uart_set_buad(int c) {
  volatile unsigned int *byte = (unsigned int *) ADD_UART_BAUD;
  *byte = c;
}

int uart_tx_status() {
  volatile unsigned int *status = (unsigned int *) ADD_UART_STATUS;
  if((*status & 0x400) == 0) {
    return UART_TX_IDLE;
  } else {
    return UART_TX_TRANSMIT;
  }
}

unsigned int uart_bytes_available() {
  volatile unsigned int *status = (unsigned int *) ADD_UART_STATUS;
  return ((*status >> 16) & 0xFFF);
}

unsigned long int uart_status() {
  volatile unsigned long int *status = (unsigned int *) ADD_UART_STATUS;
  return (*status);
}

void uart_send_buf(const char *buf, const int len) {
  int i;
  for(i=0; i<len; i++) uart_send(*(buf+i));
}

char uart_recv() {
  while( (*(volatile unsigned int*)(ADD_UART_STATUS) & 0x100) == 0);
  *(volatile unsigned int*)(ADD_UART_STATUS) = 0;
  int ch =  *(volatile int*)(ADD_UART_STATUS);
  return ch & 255;
}

void uart_send(char data) {
  // wait until there is space in the fifo
  while( (*(volatile unsigned int*)(ADD_UART_STATUS) & 0x400) != 0);
  // load FIFO
  *(volatile unsigned int*)(ADD_UART_TX) = data;
}
