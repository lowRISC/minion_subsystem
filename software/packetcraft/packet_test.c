#include "minion.h"

#define TX_FINISHED 0

int temp[20] = { 10 } ;

int main() {

  init(temp[0]);

  uart_init();

  char str[] = "Hello minion\n";
  char pkt[11] = {0x7E, 0x08, 0x02, 0xC0, 0x3C,  0, 0x11, 0x02, 0xFB, 0x7F};
  //uart_send_buf(str, 13);

  int i;
  int *cnt     = 0x100100;
  int *start   = 0x100104;
  int *tx_flag = 0x100108;
  int *tx_ptr  = 0x10010B;

  if(reset_source() == NRM_RST) {
    *cnt = 0;
    *start = 0;
    *tx_flag = 0;
    *tx_ptr = 0;
  }

  while(1) {

    if(uart_tx_status() == UART_TX_IDLE) {
      uart_send(from_dip());
    }

    if(uart_bytes_available() > 0) {
      char c = uart_recv();
      if(c == 0x7E) {
        *start = 1;
        *cnt = 0;
      } else if(c == 0x7F) {
        if(*start) {
          if(*cnt == 10) {
            *tx_flag = 1;
          }
          *start = 0;
          *cnt = 0;
        } else {
          *cnt = 0;
        }
      } else {
        (*cnt)++;
      }
    }

  //  if(uart_tx_status() == UART_TX_IDLE && *tx_ptr != TX_FINISHED) {
//      uart_send(pkt[*tx_ptr]);
//      (*tx_ptr)--;
//    }

    if(*tx_flag) {
      i++;
      to_led(i);
      *tx_ptr = 10;
      *tx_flag = 0;
    }

  }
}
