#ifndef MINION_H
#define MINION_H

#define UART_TX_IDLE     0
#define UART_TX_TRANSMIT 1

int init(int temp);

void delay();

void to_led(unsigned int data);

int uart_get_status();

void uart_send_buf(const char *buf, const int len);

char uart_recv();

void uart_send(char data);

#endif
