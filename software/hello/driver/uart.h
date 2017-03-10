// See LICENSE for license details.

#ifndef UART_HEADER_H
#define UART_HEADER_H

#include <stdint.h>
#include "device_map.h"

// Xilinx AXI_UART 16550

#define UART_BASE (IO_SPACE_BASE + 0x1000u)

// RBR: Receiver buffer register [Read, LCR[7] == 0]
#define UART_RBR 0x0u

// THR: Transmitter Holding register [Write, LCR[7] == 0]
#define UART_THR 0x0u

// IER: Interrupt enable register [Read/Write, LCR[7] == 0]
#define UART_IER 0x1u

// IIR: Interrupt identification register [Read]
#define UART_IIR 0x2u

// FCR: FIFO control register [Write, Read only when LCR[7] == 1]
#define UART_FCR 0x2u

// LCR: Line control register [Read/Write]
#define UART_LCR 0x3u

// MCR: Modem control register [Read/Write]
#define UART_MCR 0x4u

// LSR: Line status register [Read/Write]
#define UART_LSR 0x5u

// MSR: Modem status register [Read/Write]
#define UART_MSR 0x6u

// SCR: Scratch register [Read/Write]
#define UART_SCR 0x7u

// DLL: Divisor latch (least significant byte) register [Read/Write, LCR[7] == 1]
#define UART_DLL 0x0u

// DLM: Divisor latch (most significant byte) register [Read/Write, LCR[7] == 1]
#define UART_DLM 0x1u

// UART APIs
extern void uart_init();
extern void uart_send(uint8_t);
extern void uart_send_string(const char *str);
extern void uart_send_buf(const char *buf, const int32_t len);
extern uint8_t uart_recv();
extern uint8_t uart_read_irq();
extern uint8_t uart_check_read_irq();
extern void uart_enable_read_irq();
extern void uart_disable_read_irq();

#endif
