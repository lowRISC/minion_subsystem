#include "minion.h"

int temp[20] = { 10 } ;

int main() {

  init(temp[0]);

  uart_init();

  char str[] = "Hello minion\n";
  uart_send_buf(str, 13);

  char i = 0;

  while(1) {

    i++;
    to_led(i);

    if(uart_bytes_available() > 0) {
      char c = uart_recv();
      uart_send(c);
    }

    if(from_dip() != 0) {
      uart_send_buf("You pressed a button!\n", 22);
      while(from_dip()) { }
    }

    delay();
  }
}
