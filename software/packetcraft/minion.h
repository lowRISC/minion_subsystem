#ifndef MINION_H
#define MINION_H

#define UART_TX_IDLE     0
#define UART_TX_TRANSMIT 1

#define NRM_RST 0
#define CLS_RST 1

int init(int temp);

unsigned int reset_source();

void delay();

void to_led(unsigned int data);

unsigned int from_dip();

void uart_init();

int uart_get_status();

unsigned int uart_bytes_available();

unsigned long int uart_status();

void uart_send_buf(const char *buf, const int len);

char uart_recv();

void uart_send(char data);

#endif
